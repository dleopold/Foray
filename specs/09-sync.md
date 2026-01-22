# Specification: Sync System

**Phase:** 9  
**Estimated Duration:** 5-6 days  
**Dependencies:** Phase 6 complete  
**Patterns & Pitfalls:** See `PATTERNS_AND_PITFALLS.md` — [Offline-First & Sync](#5-offline-first--sync-patterns), [Supabase Integration](#4-supabase-integration) (RLS)

---

## 1. Supabase Schema Setup

### 1.1 Database Tables (SQL)

```sql
-- Users table
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  display_name TEXT NOT NULL,
  email TEXT UNIQUE,
  avatar_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Forays table
CREATE TABLE forays (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  creator_id UUID REFERENCES users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  date DATE NOT NULL,
  location_name TEXT,
  default_privacy TEXT NOT NULL DEFAULT 'private',
  join_code TEXT UNIQUE,
  status TEXT NOT NULL DEFAULT 'active',
  is_solo BOOLEAN NOT NULL DEFAULT false,
  observations_locked BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Foray participants table
CREATE TABLE foray_participants (
  foray_id UUID REFERENCES forays(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  role TEXT NOT NULL DEFAULT 'participant',
  joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  PRIMARY KEY (foray_id, user_id)
);

-- Observations table
CREATE TABLE observations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  foray_id UUID REFERENCES forays(id) ON DELETE CASCADE,
  collector_id UUID REFERENCES users(id) ON DELETE CASCADE,
  latitude DOUBLE PRECISION NOT NULL,
  longitude DOUBLE PRECISION NOT NULL,
  gps_accuracy DOUBLE PRECISION,
  altitude DOUBLE PRECISION,
  privacy_level TEXT NOT NULL DEFAULT 'private',
  observed_at TIMESTAMP WITH TIME ZONE NOT NULL,
  specimen_id TEXT,
  collection_number TEXT,
  substrate TEXT,
  habitat_notes TEXT,
  field_notes TEXT,
  spore_print_color TEXT,
  preliminary_id TEXT,
  preliminary_id_confidence TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Photos table
CREATE TABLE photos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  observation_id UUID REFERENCES observations(id) ON DELETE CASCADE,
  storage_path TEXT NOT NULL,
  url TEXT,
  sort_order INTEGER NOT NULL DEFAULT 0,
  caption TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Identifications table
CREATE TABLE identifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  observation_id UUID REFERENCES observations(id) ON DELETE CASCADE,
  identifier_id UUID REFERENCES users(id) ON DELETE CASCADE,
  species_name TEXT NOT NULL,
  common_name TEXT,
  confidence TEXT NOT NULL DEFAULT 'likely',
  notes TEXT,
  vote_count INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Identification votes table
CREATE TABLE identification_votes (
  identification_id UUID REFERENCES identifications(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  voted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  PRIMARY KEY (identification_id, user_id)
);

-- Comments table
CREATE TABLE comments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  observation_id UUID REFERENCES observations(id) ON DELETE CASCADE,
  author_id UUID REFERENCES users(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_forays_creator ON forays(creator_id);
CREATE INDEX idx_forays_join_code ON forays(join_code);
CREATE INDEX idx_observations_foray ON observations(foray_id);
CREATE INDEX idx_observations_collector ON observations(collector_id);
CREATE INDEX idx_photos_observation ON photos(observation_id);
CREATE INDEX idx_identifications_observation ON identifications(observation_id);
CREATE INDEX idx_comments_observation ON comments(observation_id);
```

### 1.2 Row Level Security Policies

```sql
-- Enable RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE forays ENABLE ROW LEVEL SECURITY;
ALTER TABLE foray_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE observations ENABLE ROW LEVEL SECURITY;
ALTER TABLE photos ENABLE ROW LEVEL SECURITY;
ALTER TABLE identifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE identification_votes ENABLE ROW LEVEL SECURITY;
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;

-- Users: can read all, update own
CREATE POLICY "Users can read all users" ON users FOR SELECT USING (true);
CREATE POLICY "Users can update own profile" ON users FOR UPDATE USING (auth.uid() = id);

-- Forays: participants can read, creator can modify
CREATE POLICY "Participants can read forays" ON forays FOR SELECT USING (
  EXISTS (SELECT 1 FROM foray_participants WHERE foray_id = id AND user_id = auth.uid())
);
CREATE POLICY "Creator can modify foray" ON forays FOR ALL USING (creator_id = auth.uid());

-- Foray participants
CREATE POLICY "Participants can read participants" ON foray_participants FOR SELECT USING (
  EXISTS (SELECT 1 FROM foray_participants fp WHERE fp.foray_id = foray_id AND fp.user_id = auth.uid())
);
CREATE POLICY "Creator can manage participants" ON foray_participants FOR ALL USING (
  EXISTS (SELECT 1 FROM forays WHERE id = foray_id AND creator_id = auth.uid())
);

-- Observations: respect privacy levels
CREATE POLICY "Read observations based on privacy" ON observations FOR SELECT USING (
  privacy_level = 'public_exact' OR
  privacy_level = 'public_obscured' OR
  collector_id = auth.uid() OR
  (privacy_level IN ('foray', 'private') AND EXISTS (
    SELECT 1 FROM foray_participants WHERE foray_id = observations.foray_id AND user_id = auth.uid()
  ))
);
-- Collectors can INSERT and UPDATE their own observations
CREATE POLICY "Collector can create observations" ON observations FOR INSERT WITH CHECK (collector_id = auth.uid());
CREATE POLICY "Collector can update own observations" ON observations FOR UPDATE USING (collector_id = auth.uid());

-- Only foray organizer can DELETE observations
CREATE POLICY "Organizer can delete observations" ON observations FOR DELETE USING (
  EXISTS (SELECT 1 FROM forays WHERE id = foray_id AND creator_id = auth.uid())
);

-- Photos: same as parent observation
CREATE POLICY "Read photos with observation" ON photos FOR SELECT USING (
  EXISTS (SELECT 1 FROM observations WHERE id = observation_id)
);

-- Identifications: foray participants can read/create
CREATE POLICY "Participants can read identifications" ON identifications FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM observations o
    JOIN foray_participants fp ON fp.foray_id = o.foray_id
    WHERE o.id = observation_id AND fp.user_id = auth.uid()
  )
);
CREATE POLICY "Participants can create identifications" ON identifications FOR INSERT WITH CHECK (
  identifier_id = auth.uid()
);
CREATE POLICY "Creator or organizer can delete identifications" ON identifications FOR DELETE USING (
  identifier_id = auth.uid() OR
  EXISTS (
    SELECT 1 FROM observations o
    JOIN forays f ON f.id = o.foray_id
    WHERE o.id = observation_id AND f.creator_id = auth.uid()
  )
);

-- Similar policies for votes and comments...
```

---

## 2. Photo Upload

### 2.1 Photo Upload Service

```dart
// lib/services/storage/photo_upload_service.dart
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import 'package:image/image.dart' as img;
import 'package:foray/core/constants/app_constants.dart';
import 'package:foray/services/supabase_service.dart';

final photoUploadServiceProvider = Provider<PhotoUploadService>((ref) {
  return PhotoUploadService(ref.watch(supabaseClientProvider));
});

class PhotoUploadService {
  PhotoUploadService(this._supabase);

  final SupabaseClient _supabase;
  final _uuid = const Uuid();

  Future<String> uploadPhoto({
    required File file,
    required String observationId,
    void Function(double)? onProgress,
  }) async {
    // Compress if needed
    final compressedFile = await _compressIfNeeded(file);

    // Generate storage path
    final extension = p.extension(file.path);
    final fileName = '${_uuid.v4()}$extension';
    final storagePath = 'observations/$observationId/$fileName';

    // Upload
    await _supabase.storage.from('photos').upload(
      storagePath,
      compressedFile,
      fileOptions: const FileOptions(
        cacheControl: '3600',
        upsert: false,
      ),
    );

    // Get public URL
    final url = _supabase.storage.from('photos').getPublicUrl(storagePath);

    return url;
  }

  Future<File> _compressIfNeeded(File file) async {
    final bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) return file;

    // Check if compression needed
    final maxDim = AppConstants.photoMaxDimension;
    if (image.width <= maxDim && image.height <= maxDim) {
      // Just re-encode with quality setting
      final compressed = img.encodeJpg(image, quality: AppConstants.photoCompressionQuality);
      final compressedFile = File('${file.path}.compressed.jpg');
      await compressedFile.writeAsBytes(compressed);
      return compressedFile;
    }

    // Resize
    final resized = img.copyResize(
      image,
      width: image.width > image.height ? maxDim : null,
      height: image.height >= image.width ? maxDim : null,
    );

    final compressed = img.encodeJpg(resized, quality: AppConstants.photoCompressionQuality);
    final compressedFile = File('${file.path}.compressed.jpg');
    await compressedFile.writeAsBytes(compressed);
    return compressedFile;
  }

  Future<void> deletePhoto(String storagePath) async {
    await _supabase.storage.from('photos').remove([storagePath]);
  }
}
```

---

## 3-4. Observation Sync (Push/Pull)

### 3.1 Sync Service

```dart
// lib/services/sync/sync_service.dart
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:foray/database/database.dart';
import 'package:foray/services/supabase_service.dart';
import 'package:foray/services/storage/photo_upload_service.dart';

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(
    ref.watch(supabaseClientProvider),
    ref.watch(databaseProvider),
    ref.watch(photoUploadServiceProvider),
  );
});

class SyncService {
  SyncService(this._supabase, this._db, this._photoUploader);

  final SupabaseClient _supabase;
  final AppDatabase _db;
  final PhotoUploadService _photoUploader;

  // Push observation to Supabase
  Future<void> pushObservation(String observationId) async {
    final observation = await _db.observationsDao.getObservationById(observationId);
    if (observation == null) return;

    final photos = await _db.observationsDao.getPhotosForObservation(observationId);

    // Upload photos first
    final uploadedUrls = <String, String>{};
    for (final photo in photos) {
      if (photo.uploadStatus != UploadStatus.uploaded) {
        try {
          final file = File(photo.localPath);
          final url = await _photoUploader.uploadPhoto(
            file: file,
            observationId: observationId,
          );
          uploadedUrls[photo.id] = url;
          await _db.observationsDao.updatePhotoUploadStatus(
            photo.id,
            UploadStatus.uploaded,
            remoteUrl: url,
          );
        } catch (e) {
          await _db.observationsDao.updatePhotoUploadStatus(
            photo.id,
            UploadStatus.failed,
          );
          rethrow;
        }
      }
    }

    // Upload observation
    final observationData = {
      'id': observation.remoteId ?? observation.id,
      'foray_id': observation.forayId, // Assumes foray is already synced
      'collector_id': observation.collectorId, // Assumes user is already synced
      'latitude': observation.latitude,
      'longitude': observation.longitude,
      'gps_accuracy': observation.gpsAccuracy,
      'altitude': observation.altitude,
      'privacy_level': observation.privacyLevel.name,
      'observed_at': observation.observedAt.toIso8601String(),
      'specimen_id': observation.specimenId,
      'collection_number': observation.collectionNumber,
      'substrate': observation.substrate,
      'habitat_notes': observation.habitatNotes,
      'field_notes': observation.fieldNotes,
      'spore_print_color': observation.sporePrintColor,
      'preliminary_id': observation.preliminaryId,
      'preliminary_id_confidence': observation.preliminaryIdConfidence?.name,
    };

    final response = await _supabase
        .from('observations')
        .upsert(observationData)
        .select()
        .single();

    final remoteId = response['id'] as String;

    // Update local observation with remote ID
    await _db.observationsDao.updateSyncStatus(
      observationId,
      SyncStatus.synced,
      remoteId: remoteId,
    );

    // Upload photo records
    for (final photo in photos) {
      final url = uploadedUrls[photo.id] ?? photo.remoteUrl;
      if (url != null) {
        await _supabase.from('photos').upsert({
          'id': photo.remoteId ?? photo.id,
          'observation_id': remoteId,
          'storage_path': 'observations/$observationId/${photo.id}',
          'url': url,
          'sort_order': photo.sortOrder,
          'caption': photo.caption,
        });
      }
    }
  }

  // Pull observations for foray
  Future<void> pullForayObservations(String forayId) async {
    final foray = await _db.foraysDao.getForayById(forayId);
    if (foray?.remoteId == null) return;

    final response = await _supabase
        .from('observations')
        .select('*, photos(*)')
        .eq('foray_id', foray!.remoteId!);

    for (final row in response as List) {
      await _mergeObservation(row);
    }
  }

  Future<void> _mergeObservation(Map<String, dynamic> remote) async {
    final remoteId = remote['id'] as String;
    
    // Check if we already have this observation locally
    // by remote ID or by matching local ID
    final existing = await _db.observationsDao.getObservationById(remoteId);
    
    if (existing == null) {
      // Create new local observation from remote
      // ... implementation details
    } else {
      // Merge - compare timestamps, take newer
      // ... implementation details
    }
  }
}
```

---

## 5. Collaboration Data Sync

Similar patterns for identifications, votes, and comments.

---

## 6. Conflict Resolution

### 6.1 Conflict Detection

```dart
// lib/services/sync/conflict_resolver.dart
enum ConflictResolution { local, remote, merge }

class ConflictResolver {
  /// Simple last-write-wins resolution
  static ConflictResolution resolveByTimestamp(
    DateTime localUpdated,
    DateTime remoteUpdated,
  ) {
    return localUpdated.isAfter(remoteUpdated)
        ? ConflictResolution.local
        : ConflictResolution.remote;
  }

  /// For text fields, could implement merge
  static String? mergeTextFields(String? local, String? remote) {
    if (local == null) return remote;
    if (remote == null) return local;
    if (local == remote) return local;
    
    // Simple: take remote (server wins)
    // Could implement more sophisticated merge
    return remote;
  }
}
```

---

## 7. Background Sync

### 7.1 Sync Queue Processor

```dart
// lib/services/sync/sync_queue_processor.dart
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foray/database/database.dart';
import 'package:foray/services/sync/sync_service.dart';
import 'package:foray/core/constants/app_constants.dart';

final syncQueueProcessorProvider = Provider<SyncQueueProcessor>((ref) {
  return SyncQueueProcessor(
    ref.watch(databaseProvider),
    ref.watch(syncServiceProvider),
  );
});

class SyncQueueProcessor {
  SyncQueueProcessor(this._db, this._syncService);

  final AppDatabase _db;
  final SyncService _syncService;
  
  Timer? _processingTimer;
  StreamSubscription? _connectivitySubscription;
  bool _isProcessing = false;

  void start() {
    // Process queue periodically
    _processingTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => processQueue(),
    );

    // Process when connectivity changes
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        processQueue();
      }
    });

    // Initial process
    processQueue();
  }

  void stop() {
    _processingTimer?.cancel();
    _connectivitySubscription?.cancel();
  }

  Future<void> processQueue() async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      // Check connectivity
      final connectivity = await Connectivity().checkConnectivity();
      if (connectivity == ConnectivityResult.none) return;

      // Get pending items
      final items = await _db.syncDao.getPendingItems(limit: 10);

      for (final item in items) {
        await _processItem(item);
      }

      // Retry failed items
      final failedItems = await _db.syncDao.getFailedItemsForRetry(
        maxRetries: AppConstants.syncRetryMaxAttempts,
      );

      for (final item in failedItems) {
        await _processItem(item);
      }

      // Clean up completed items
      await _db.syncDao.deleteCompleted();
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> _processItem(SyncQueueData item) async {
    await _db.syncDao.markProcessing(item.id);

    try {
      switch (item.entityType) {
        case 'observation':
          await _syncService.pushObservation(item.entityId);
          break;
        case 'foray':
          // await _syncService.pushForay(item.entityId);
          break;
        case 'identification':
          // await _syncService.pushIdentification(item.entityId);
          break;
        case 'comment':
          // await _syncService.pushComment(item.entityId);
          break;
        default:
          break;
      }

      await _db.syncDao.markCompleted(item.id);
    } catch (e) {
      await _db.syncDao.markFailed(item.id, e.toString());
    }
  }
}
```

---

## 8. Sync Status UI

### 8.1 Sync Status Banner

```dart
// lib/features/sync/presentation/widgets/sync_status_banner.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foray/core/theme/app_spacing.dart';
import 'package:foray/core/theme/app_colors.dart';
import 'package:foray/database/database.dart';

final pendingSyncCountProvider = StreamProvider<int>((ref) {
  final db = ref.watch(databaseProvider);
  return db.syncDao.watchPendingCount();
});

class SyncStatusBanner extends ConsumerWidget {
  const SyncStatusBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingCount = ref.watch(pendingSyncCountProvider);

    return pendingCount.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (count) {
        if (count == 0) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          color: AppColors.syncPending.withOpacity(0.2),
          child: Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text('$count item${count > 1 ? 's' : ''} waiting to sync'),
              const Spacer(),
              TextButton(
                onPressed: () {
                  ref.read(syncQueueProcessorProvider).processQueue();
                },
                child: const Text('Sync Now'),
              ),
            ],
          ),
        );
      },
    );
  }
}
```

---

## Acceptance Criteria

Phase 9 is complete when:

1. [ ] Supabase tables created with correct schema
2. [ ] Row Level Security policies enforce privacy
3. [ ] Photos upload to Supabase Storage
4. [ ] Photos compress correctly before upload
5. [ ] Observations push to Supabase
6. [ ] Observations pull from Supabase
7. [ ] Identifications sync correctly
8. [ ] Votes sync correctly
9. [ ] Comments sync correctly
10. [ ] Conflicts resolve with last-write-wins
11. [ ] Background sync processes queue automatically
12. [ ] Sync triggers on connectivity restore
13. [ ] Sync status banner shows pending count
14. [ ] "Sync Now" button triggers immediate sync
