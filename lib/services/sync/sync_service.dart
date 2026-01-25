import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../database/database.dart';
import '../../database/tables/forays_table.dart';
import '../../database/tables/photos_table.dart';
import '../storage/photo_upload_service.dart';
import '../supabase_service.dart';

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(
    ref.watch(supabaseClientProvider),
    ref.watch(databaseProvider),
    ref.watch(photoUploadServiceProvider),
  );
});

/// Exception thrown when sync operations fail due to Supabase being unavailable.
class SyncUnavailableException implements Exception {
  const SyncUnavailableException([this.message = 'Sync unavailable: Supabase not configured']);
  final String message;
  @override
  String toString() => message;
}

class SyncService {
  SyncService(this._supabase, this._db, this._photoUploader);

  final SupabaseClient? _supabase;
  final AppDatabase _db;
  final PhotoUploadService _photoUploader;
  
  /// Whether sync is available (Supabase configured).
  bool get isAvailable => _supabase != null;

  Future<void> pushObservation(String observationId) async {
    if (_supabase == null) {
      throw const SyncUnavailableException();
    }
    
    final observation = await _db.observationsDao.getObservationById(observationId);
    if (observation == null) return;

    final photos = await _db.observationsDao.getPhotosForObservation(observationId);

    for (final photo in photos) {
      if (photo.uploadStatus != UploadStatus.uploaded && photo.remoteUrl == null) {
        try {
          final file = File(photo.localPath);
          if (await file.exists()) {
            final url = await _photoUploader.uploadPhoto(
              file: file,
              observationId: observationId,
            );
            await _db.observationsDao.updatePhotoUploadStatus(
              photo.id,
              UploadStatus.uploaded,
              remoteUrl: url,
            );
          }
        } catch (e) {
          await _db.observationsDao.updatePhotoUploadStatus(
            photo.id,
            UploadStatus.failed,
          );
          rethrow;
        }
      }
    }

    final observationData = _observationToMap(observation);
    
    final response = await _supabase
        .from('observations')
        .upsert(observationData)
        .select()
        .single();

    final remoteId = response['id'] as String;
    
    await _db.observationsDao.updateSyncStatus(
      observationId,
      SyncStatus.synced,
      remoteId: remoteId,
    );

    final updatedPhotos = await _db.observationsDao.getPhotosForObservation(observationId);
    for (final photo in updatedPhotos) {
      if (photo.remoteUrl != null) {
        await _supabase.from('photos').upsert({
          'id': photo.remoteId ?? photo.id,
          'observation_id': remoteId,
          'storage_path': 'observations/$observationId/${photo.id}',
          'url': photo.remoteUrl,
          'sort_order': photo.sortOrder,
          'caption': photo.caption,
        });
      }
    }
  }

  Future<void> pushForay(String forayId) async {
    if (_supabase == null) {
      throw const SyncUnavailableException();
    }
    
    final foray = await _db.foraysDao.getForayById(forayId);
    if (foray == null) return;

    final forayData = {
      'id': foray.remoteId ?? foray.id,
      'creator_id': foray.creatorId,
      'name': foray.name,
      'description': foray.description,
      'date': foray.date.toIso8601String().split('T')[0],
      'location_name': foray.locationName,
      'default_privacy': foray.defaultPrivacy.name,
      'join_code': foray.joinCode,
      'status': foray.status.name,
      'is_solo': foray.isSolo,
      'observations_locked': foray.observationsLocked,
    };

    final response = await _supabase
        .from('forays')
        .upsert(forayData)
        .select()
        .single();

    final remoteId = response['id'] as String;
    
    await _db.foraysDao.updateSyncStatus(
      forayId,
      SyncStatus.synced,
      remoteId: remoteId,
    );
  }

  Future<void> pushIdentification(String identificationId) async {
    if (_supabase == null) {
      throw const SyncUnavailableException();
    }
    
    final id = await _db.collaborationDao.getIdentificationById(identificationId);
    if (id == null) return;

    final idData = {
      'id': id.remoteId ?? id.id,
      'observation_id': id.observationId,
      'identifier_id': id.identifierId,
      'species_name': id.speciesName,
      'common_name': id.commonName,
      'confidence': id.confidence.name,
      'notes': id.notes,
      'vote_count': id.voteCount,
    };

    await _supabase.from('identifications').upsert(idData);
    
    await _db.collaborationDao.updateIdentificationSyncStatus(
      identificationId,
      SyncStatus.synced,
    );
  }

  Future<void> pushComment(String commentId) async {
    if (_supabase == null) {
      throw const SyncUnavailableException();
    }
    
    final comment = await _db.collaborationDao.getCommentById(commentId);
    if (comment == null) return;

    final commentData = {
      'id': comment.remoteId ?? comment.id,
      'observation_id': comment.observationId,
      'author_id': comment.authorId,
      'content': comment.content,
    };

    await _supabase.from('comments').upsert(commentData);
    
    await _db.collaborationDao.updateCommentSyncStatus(
      commentId,
      SyncStatus.synced,
    );
  }

  Future<void> pullForayObservations(String forayId) async {
    if (_supabase == null) {
      throw const SyncUnavailableException();
    }
    
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
    final existing = await _db.observationsDao.getObservationByRemoteId(remoteId);
    
    if (existing == null) {
      await _createLocalObservation(remote);
    } else {
      await _updateLocalObservation(existing, remote);
    }
  }

  Future<void> _createLocalObservation(Map<String, dynamic> remote) async {
    await _db.observationsDao.createFromRemote(
      remoteId: remote['id'],
      forayId: remote['foray_id'],
      collectorId: remote['collector_id'],
      latitude: remote['latitude'],
      longitude: remote['longitude'],
      gpsAccuracy: remote['gps_accuracy'],
      altitude: remote['altitude'],
      privacyLevel: remote['privacy_level'],
      observedAt: DateTime.parse(remote['observed_at']),
      specimenId: remote['specimen_id'],
      collectionNumber: remote['collection_number'],
      substrate: remote['substrate'],
      habitatNotes: remote['habitat_notes'],
      fieldNotes: remote['field_notes'],
      sporePrintColor: remote['spore_print_color'],
      preliminaryId: remote['preliminary_id'],
      preliminaryIdConfidence: remote['preliminary_id_confidence'],
    );

    final photos = remote['photos'] as List? ?? [];
    for (final photo in photos) {
      await _db.observationsDao.createPhotoFromRemote(
        remoteId: photo['id'],
        observationId: remote['id'],
        storagePath: photo['storage_path'],
        remoteUrl: photo['url'],
        sortOrder: photo['sort_order'] ?? 0,
        caption: photo['caption'],
      );
    }
  }

  Future<void> _updateLocalObservation(Observation existing, Map<String, dynamic> remote) async {
    final remoteUpdated = DateTime.parse(remote['updated_at']);
    
    if (remoteUpdated.isAfter(existing.updatedAt)) {
      await _db.observationsDao.updateFromRemote(
        localId: existing.id,
        latitude: remote['latitude'],
        longitude: remote['longitude'],
        gpsAccuracy: remote['gps_accuracy'],
        altitude: remote['altitude'],
        privacyLevel: remote['privacy_level'],
        specimenId: remote['specimen_id'],
        collectionNumber: remote['collection_number'],
        substrate: remote['substrate'],
        habitatNotes: remote['habitat_notes'],
        fieldNotes: remote['field_notes'],
        sporePrintColor: remote['spore_print_color'],
        preliminaryId: remote['preliminary_id'],
        preliminaryIdConfidence: remote['preliminary_id_confidence'],
      );
    }
  }

  Map<String, dynamic> _observationToMap(Observation observation) {
    return {
      'id': observation.remoteId ?? observation.id,
      'foray_id': observation.forayId,
      'collector_id': observation.collectorId,
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
  }
}
