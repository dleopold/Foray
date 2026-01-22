# Specification: Database Schema & Data Layer

**Phase:** 2  
**Estimated Duration:** 4-5 days  
**Dependencies:** Phase 1 complete

---

## 1. Drift Setup & Configuration

### 1.1 Dependencies

Already included in Phase 1 `pubspec.yaml`:
- `drift: ^2.14.0`
- `sqlite3_flutter_libs: ^0.5.18`
- `path_provider: ^2.1.1`
- `path: ^1.8.3`

Dev dependencies:
- `drift_dev: ^2.14.0`
- `build_runner: ^2.4.7`

### 1.2 Database Class (`database/database.dart`)

```dart
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import tables
import 'tables/users_table.dart';
import 'tables/forays_table.dart';
import 'tables/observations_table.dart';
import 'tables/photos_table.dart';
import 'tables/identifications_table.dart';
import 'tables/comments_table.dart';
import 'tables/sync_queue_table.dart';

// Import DAOs
import 'daos/users_dao.dart';
import 'daos/forays_dao.dart';
import 'daos/observations_dao.dart';
import 'daos/collaboration_dao.dart';
import 'daos/sync_dao.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    Users,
    Forays,
    ForayParticipants,
    Observations,
    Photos,
    Identifications,
    IdentificationVotes,
    Comments,
    SyncQueue,
  ],
  daos: [
    UsersDao,
    ForaysDao,
    ObservationsDao,
    CollaborationDao,
    SyncDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Handle migrations here
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'foray.db'));
    return NativeDatabase.createInBackground(file);
  });
}

// Riverpod provider
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});
```

### 1.3 Build Runner Configuration

Run code generation:
```bash
dart run build_runner build --delete-conflicting-outputs
```

Or watch mode:
```bash
dart run build_runner watch --delete-conflicting-outputs
```

---

## 2. User & Auth Tables

### 2.1 Users Table (`database/tables/users_table.dart`)

```dart
import 'package:drift/drift.dart';

class Users extends Table {
  // Local UUID - primary key
  TextColumn get id => text()();
  
  // Remote Supabase UUID (null if not synced)
  TextColumn get remoteId => text().nullable()();
  
  // User info
  TextColumn get displayName => text().withLength(min: 1, max: 100)();
  TextColumn get email => text().nullable()();
  TextColumn get avatarUrl => text().nullable()();
  
  // Anonymous user flag
  BoolColumn get isAnonymous => boolean().withDefault(const Constant(true))();
  
  // Device ID for anonymous users
  TextColumn get deviceId => text().nullable()();
  
  // Timestamps
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  
  // Is this the current user?
  BoolColumn get isCurrent => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
```

### 2.2 Users DAO (`database/daos/users_dao.dart`)

```dart
import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/users_table.dart';

part 'users_dao.g.dart';

@DriftAccessor(tables: [Users])
class UsersDao extends DatabaseAccessor<AppDatabase> with _$UsersDaoMixin {
  UsersDao(super.db);

  // Get current user
  Future<User?> getCurrentUser() {
    return (select(users)..where((u) => u.isCurrent.equals(true)))
        .getSingleOrNull();
  }

  // Create anonymous user
  Future<User> createAnonymousUser({
    required String id,
    required String deviceId,
    required String displayName,
  }) async {
    final user = UsersCompanion.insert(
      id: id,
      deviceId: Value(deviceId),
      displayName: displayName,
      isAnonymous: const Value(true),
      isCurrent: const Value(true),
    );
    await into(users).insert(user);
    return (select(users)..where((u) => u.id.equals(id))).getSingle();
  }

  // Upgrade to authenticated user
  Future<void> upgradeToAuthenticated({
    required String localId,
    required String remoteId,
    required String email,
    String? displayName,
    String? avatarUrl,
  }) {
    return (update(users)..where((u) => u.id.equals(localId))).write(
      UsersCompanion(
        remoteId: Value(remoteId),
        email: Value(email),
        displayName: displayName != null ? Value(displayName) : const Value.absent(),
        avatarUrl: Value(avatarUrl),
        isAnonymous: const Value(false),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // Get user by ID
  Future<User?> getUserById(String id) {
    return (select(users)..where((u) => u.id.equals(id))).getSingleOrNull();
  }

  // Get user by remote ID
  Future<User?> getUserByRemoteId(String remoteId) {
    return (select(users)..where((u) => u.remoteId.equals(remoteId)))
        .getSingleOrNull();
  }

  // Update user
  Future<void> updateUser(String id, UsersCompanion companion) {
    return (update(users)..where((u) => u.id.equals(id))).write(companion);
  }

  // Insert or update user from sync
  Future<void> upsertFromRemote(User user) {
    return into(users).insertOnConflictUpdate(user);
  }

  // Watch current user
  Stream<User?> watchCurrentUser() {
    return (select(users)..where((u) => u.isCurrent.equals(true)))
        .watchSingleOrNull();
  }

  // Clear current user flag
  Future<void> clearCurrentUser() {
    return (update(users)..where((u) => u.isCurrent.equals(true))).write(
      const UsersCompanion(isCurrent: Value(false)),
    );
  }
}
```

---

## 3. Foray Tables

### 3.1 Forays Table (`database/tables/forays_table.dart`)

```dart
import 'package:drift/drift.dart';

// Privacy level enum for database
class PrivacyLevelConverter extends TypeConverter<PrivacyLevel, String> {
  const PrivacyLevelConverter();
  
  @override
  PrivacyLevel fromSql(String fromDb) {
    return PrivacyLevel.values.firstWhere((e) => e.name == fromDb);
  }
  
  @override
  String toSql(PrivacyLevel value) => value.name;
}

enum PrivacyLevel { private, foray, publicExact, publicObscured }

// Foray status enum
class ForayStatusConverter extends TypeConverter<ForayStatus, String> {
  const ForayStatusConverter();
  
  @override
  ForayStatus fromSql(String fromDb) {
    return ForayStatus.values.firstWhere((e) => e.name == fromDb);
  }
  
  @override
  String toSql(ForayStatus value) => value.name;
}

enum ForayStatus { active, completed }

// Sync status enum
class SyncStatusConverter extends TypeConverter<SyncStatus, String> {
  const SyncStatusConverter();
  
  @override
  SyncStatus fromSql(String fromDb) {
    return SyncStatus.values.firstWhere((e) => e.name == fromDb);
  }
  
  @override
  String toSql(SyncStatus value) => value.name;
}

enum SyncStatus { local, pending, synced, failed }

class Forays extends Table {
  // Local UUID
  TextColumn get id => text()();
  
  // Remote Supabase UUID
  TextColumn get remoteId => text().nullable()();
  
  // Creator/organizer
  TextColumn get creatorId => text().references(Users, #id)();
  
  // Foray details
  TextColumn get name => text().withLength(min: 1, max: 200)();
  TextColumn get description => text().nullable()();
  DateTimeColumn get date => dateTime()();
  TextColumn get locationName => text().nullable()();
  
  // Privacy
  TextColumn get defaultPrivacy => text()
      .map(const PrivacyLevelConverter())
      .withDefault(const Constant('private'))();
  
  // Join code (6 characters)
  TextColumn get joinCode => text().withLength(min: 6, max: 6).nullable()();
  
  // Status
  TextColumn get status => text()
      .map(const ForayStatusConverter())
      .withDefault(const Constant('active'))();
  
  // Solo foray flag
  BoolColumn get isSolo => boolean().withDefault(const Constant(false))();
  
  // Observations locked
  BoolColumn get observationsLocked => boolean().withDefault(const Constant(false))();
  
  // Timestamps
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  
  // Sync
  TextColumn get syncStatus => text()
      .map(const SyncStatusConverter())
      .withDefault(const Constant('local'))();

  @override
  Set<Column> get primaryKey => {id};
}

// Participant roles
class ParticipantRoleConverter extends TypeConverter<ParticipantRole, String> {
  const ParticipantRoleConverter();
  
  @override
  ParticipantRole fromSql(String fromDb) {
    return ParticipantRole.values.firstWhere((e) => e.name == fromDb);
  }
  
  @override
  String toSql(ParticipantRole value) => value.name;
}

enum ParticipantRole { organizer, participant }

class ForayParticipants extends Table {
  TextColumn get forayId => text().references(Forays, #id)();
  TextColumn get userId => text().references(Users, #id)();
  
  TextColumn get role => text()
      .map(const ParticipantRoleConverter())
      .withDefault(const Constant('participant'))();
  
  DateTimeColumn get joinedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {forayId, userId};
}
```

### 3.2 Forays DAO (`database/daos/forays_dao.dart`)

```dart
import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/forays_table.dart';
import '../tables/users_table.dart';

part 'forays_dao.g.dart';

@DriftAccessor(tables: [Forays, ForayParticipants, Users])
class ForaysDao extends DatabaseAccessor<AppDatabase> with _$ForaysDaoMixin {
  ForaysDao(super.db);

  // Create foray
  Future<Foray> createForay(ForaysCompanion foray) async {
    await into(forays).insert(foray);
    return (select(forays)..where((f) => f.id.equals(foray.id.value))).getSingle();
  }

  // Get foray by ID
  Future<Foray?> getForayById(String id) {
    return (select(forays)..where((f) => f.id.equals(id))).getSingleOrNull();
  }

  // Get foray by join code
  Future<Foray?> getForayByJoinCode(String code) {
    return (select(forays)..where((f) => f.joinCode.equals(code.toUpperCase())))
        .getSingleOrNull();
  }

  // Get forays for user
  Future<List<ForayWithRole>> getForaysForUser(String userId) async {
    final query = select(forays).join([
      innerJoin(
        forayParticipants,
        forayParticipants.forayId.equalsExp(forays.id),
      ),
    ])
      ..where(forayParticipants.userId.equals(userId))
      ..orderBy([OrderingTerm.desc(forays.date)]);

    final results = await query.get();
    return results.map((row) {
      return ForayWithRole(
        foray: row.readTable(forays),
        role: row.readTable(forayParticipants).role,
      );
    }).toList();
  }

  // Watch forays for user
  Stream<List<ForayWithRole>> watchForaysForUser(String userId) {
    final query = select(forays).join([
      innerJoin(
        forayParticipants,
        forayParticipants.forayId.equalsExp(forays.id),
      ),
    ])
      ..where(forayParticipants.userId.equals(userId))
      ..orderBy([OrderingTerm.desc(forays.date)]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return ForayWithRole(
          foray: row.readTable(forays),
          role: row.readTable(forayParticipants).role,
        );
      }).toList();
    });
  }

  // Add participant
  Future<void> addParticipant({
    required String forayId,
    required String userId,
    required ParticipantRole role,
  }) {
    return into(forayParticipants).insert(
      ForayParticipantsCompanion.insert(
        forayId: forayId,
        userId: userId,
        role: Value(role),
      ),
    );
  }

  // Remove participant
  Future<void> removeParticipant(String forayId, String userId) {
    return (delete(forayParticipants)
          ..where((p) => p.forayId.equals(forayId) & p.userId.equals(userId)))
        .go();
  }

  // Get participants for foray
  Future<List<ParticipantWithUser>> getParticipants(String forayId) async {
    final query = select(forayParticipants).join([
      innerJoin(users, users.id.equalsExp(forayParticipants.userId)),
    ])
      ..where(forayParticipants.forayId.equals(forayId));

    final results = await query.get();
    return results.map((row) {
      return ParticipantWithUser(
        participant: row.readTable(forayParticipants),
        user: row.readTable(users),
      );
    }).toList();
  }

  // Update foray
  Future<void> updateForay(String id, ForaysCompanion companion) {
    return (update(forays)..where((f) => f.id.equals(id))).write(companion);
  }

  // Update foray status
  Future<void> updateForayStatus(String id, ForayStatus status) {
    return (update(forays)..where((f) => f.id.equals(id))).write(
      ForaysCompanion(
        status: Value(status),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // Lock observations
  Future<void> setObservationsLocked(String id, bool locked) {
    return (update(forays)..where((f) => f.id.equals(id))).write(
      ForaysCompanion(
        observationsLocked: Value(locked),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // Delete foray
  Future<void> deleteForay(String id) async {
    await (delete(forayParticipants)..where((p) => p.forayId.equals(id))).go();
    await (delete(forays)..where((f) => f.id.equals(id))).go();
  }

  // Get forays pending sync
  Future<List<Foray>> getForaysPendingSync() {
    return (select(forays)..where((f) => f.syncStatus.equals('pending'))).get();
  }

  // Update sync status
  Future<void> updateSyncStatus(String id, SyncStatus status, {String? remoteId}) {
    return (update(forays)..where((f) => f.id.equals(id))).write(
      ForaysCompanion(
        syncStatus: Value(status),
        remoteId: remoteId != null ? Value(remoteId) : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}

// Helper classes
class ForayWithRole {
  final Foray foray;
  final ParticipantRole role;

  ForayWithRole({required this.foray, required this.role});
}

class ParticipantWithUser {
  final ForayParticipant participant;
  final User user;

  ParticipantWithUser({required this.participant, required this.user});
}
```

---

## 4. Observation Tables

### 4.1 Observations Table (`database/tables/observations_table.dart`)

```dart
import 'package:drift/drift.dart';
import 'forays_table.dart';

// Confidence level enum
class ConfidenceLevelConverter extends TypeConverter<ConfidenceLevel, String> {
  const ConfidenceLevelConverter();
  
  @override
  ConfidenceLevel fromSql(String fromDb) {
    return ConfidenceLevel.values.firstWhere((e) => e.name == fromDb);
  }
  
  @override
  String toSql(ConfidenceLevel value) => value.name;
}

enum ConfidenceLevel { guess, likely, confident }

class Observations extends Table {
  // Local UUID
  TextColumn get id => text()();
  
  // Remote Supabase UUID
  TextColumn get remoteId => text().nullable()();
  
  // Relationships
  TextColumn get forayId => text().references(Forays, #id)();
  TextColumn get collectorId => text().references(Users, #id)();
  
  // Location
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  RealColumn get gpsAccuracy => real().nullable()();
  RealColumn get altitude => real().nullable()();
  
  // Privacy
  TextColumn get privacyLevel => text()
      .map(const PrivacyLevelConverter())
      .withDefault(const Constant('private'))();
  
  // Timestamps
  DateTimeColumn get observedAt => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  
  // Specimen ID (for physical specimen lookup)
  TextColumn get specimenId => text().nullable()();
  
  // Collection number
  TextColumn get collectionNumber => text().nullable()();
  
  // Field data
  TextColumn get substrate => text().nullable()();
  TextColumn get habitatNotes => text().nullable()();
  TextColumn get fieldNotes => text().nullable()();
  TextColumn get sporePrintColor => text().nullable()();
  
  // Preliminary ID by collector
  TextColumn get preliminaryId => text().nullable()();
  TextColumn get preliminaryIdConfidence => text()
      .map(const ConfidenceLevelConverter())
      .nullable()();
  
  // Draft status
  BoolColumn get isDraft => boolean().withDefault(const Constant(true))();
  
  // Sync
  TextColumn get syncStatus => text()
      .map(const SyncStatusConverter())
      .withDefault(const Constant('local'))();
  
  // Last viewed timestamp (for "updated" indicator)
  DateTimeColumn get lastViewedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
```

### 4.2 Photos Table (`database/tables/photos_table.dart`)

```dart
import 'package:drift/drift.dart';
import 'forays_table.dart';

class UploadStatusConverter extends TypeConverter<UploadStatus, String> {
  const UploadStatusConverter();
  
  @override
  UploadStatus fromSql(String fromDb) {
    return UploadStatus.values.firstWhere((e) => e.name == fromDb);
  }
  
  @override
  String toSql(UploadStatus value) => value.name;
}

enum UploadStatus { pending, uploading, uploaded, failed }

class Photos extends Table {
  // Local UUID
  TextColumn get id => text()();
  
  // Remote UUID
  TextColumn get remoteId => text().nullable()();
  
  // Relationship
  TextColumn get observationId => text().references(Observations, #id)();
  
  // Local file path
  TextColumn get localPath => text()();
  
  // Remote URL (after upload)
  TextColumn get remoteUrl => text().nullable()();
  
  // Display order
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  
  // Optional caption
  TextColumn get caption => text().nullable()();
  
  // Upload status
  TextColumn get uploadStatus => text()
      .map(const UploadStatusConverter())
      .withDefault(const Constant('pending'))();
  
  // Timestamps
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
```

### 4.3 Observations DAO (`database/daos/observations_dao.dart`)

```dart
import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/observations_table.dart';
import '../tables/photos_table.dart';
import '../tables/forays_table.dart';
import '../tables/users_table.dart';

part 'observations_dao.g.dart';

@DriftAccessor(tables: [Observations, Photos, Forays, Users])
class ObservationsDao extends DatabaseAccessor<AppDatabase> with _$ObservationsDaoMixin {
  ObservationsDao(super.db);

  // Create observation
  Future<Observation> createObservation(ObservationsCompanion observation) async {
    await into(observations).insert(observation);
    return (select(observations)..where((o) => o.id.equals(observation.id.value)))
        .getSingle();
  }

  // Get observation by ID
  Future<Observation?> getObservationById(String id) {
    return (select(observations)..where((o) => o.id.equals(id))).getSingleOrNull();
  }

  // Get observation by specimen ID
  Future<Observation?> getObservationBySpecimenId(String forayId, String specimenId) {
    return (select(observations)
          ..where((o) => o.forayId.equals(forayId) & o.specimenId.equals(specimenId)))
        .getSingleOrNull();
  }

  // Get observations for foray
  Future<List<ObservationWithDetails>> getObservationsForForay(String forayId) async {
    final query = select(observations).join([
      leftOuterJoin(users, users.id.equalsExp(observations.collectorId)),
    ])
      ..where(observations.forayId.equals(forayId))
      ..orderBy([OrderingTerm.desc(observations.observedAt)]);

    final results = await query.get();
    final observationIds = results.map((r) => r.readTable(observations).id).toList();
    
    // Get photos for all observations
    final photosQuery = select(photos)
      ..where((p) => p.observationId.isIn(observationIds))
      ..orderBy([(p) => OrderingTerm.asc(p.sortOrder)]);
    final allPhotos = await photosQuery.get();
    
    return results.map((row) {
      final obs = row.readTable(observations);
      return ObservationWithDetails(
        observation: obs,
        collector: row.readTableOrNull(users),
        photos: allPhotos.where((p) => p.observationId == obs.id).toList(),
      );
    }).toList();
  }

  // Watch observations for foray
  Stream<List<ObservationWithDetails>> watchObservationsForForay(String forayId) {
    final obsQuery = select(observations)
      ..where((o) => o.forayId.equals(forayId))
      ..orderBy([(o) => OrderingTerm.desc(o.observedAt)]);

    return obsQuery.watch().asyncMap((obsList) async {
      final details = <ObservationWithDetails>[];
      for (final obs in obsList) {
        final collector = await (select(users)..where((u) => u.id.equals(obs.collectorId)))
            .getSingleOrNull();
        final obsPhotos = await (select(photos)
              ..where((p) => p.observationId.equals(obs.id))
              ..orderBy([(p) => OrderingTerm.asc(p.sortOrder)]))
            .get();
        details.add(ObservationWithDetails(
          observation: obs,
          collector: collector,
          photos: obsPhotos,
        ));
      }
      return details;
    });
  }

  // Get observations for user
  Future<List<Observation>> getObservationsForUser(String userId) {
    return (select(observations)
          ..where((o) => o.collectorId.equals(userId))
          ..orderBy([(o) => OrderingTerm.desc(o.observedAt)]))
        .get();
  }

  // Update observation
  Future<void> updateObservation(String id, ObservationsCompanion companion) {
    return (update(observations)..where((o) => o.id.equals(id))).write(
      companion.copyWith(updatedAt: Value(DateTime.now())),
    );
  }

  // Delete observation
  Future<void> deleteObservation(String id) async {
    await (delete(photos)..where((p) => p.observationId.equals(id))).go();
    await (delete(observations)..where((o) => o.id.equals(id))).go();
  }

  // Mark as viewed
  Future<void> markAsViewed(String id) {
    return (update(observations)..where((o) => o.id.equals(id))).write(
      ObservationsCompanion(lastViewedAt: Value(DateTime.now())),
    );
  }

  // Photo operations
  Future<void> addPhoto(PhotosCompanion photo) {
    return into(photos).insert(photo);
  }

  Future<void> deletePhoto(String id) {
    return (delete(photos)..where((p) => p.id.equals(id))).go();
  }

  Future<List<Photo>> getPhotosForObservation(String observationId) {
    return (select(photos)
          ..where((p) => p.observationId.equals(observationId))
          ..orderBy([(p) => OrderingTerm.asc(p.sortOrder)]))
        .get();
  }

  Future<void> updatePhotoUploadStatus(String id, UploadStatus status, {String? remoteUrl}) {
    return (update(photos)..where((p) => p.id.equals(id))).write(
      PhotosCompanion(
        uploadStatus: Value(status),
        remoteUrl: remoteUrl != null ? Value(remoteUrl) : const Value.absent(),
      ),
    );
  }

  // Sync operations
  Future<List<Observation>> getObservationsPendingSync() {
    return (select(observations)
          ..where((o) => o.syncStatus.equals('pending') & o.isDraft.equals(false)))
        .get();
  }

  Future<void> updateSyncStatus(String id, SyncStatus status, {String? remoteId}) {
    return (update(observations)..where((o) => o.id.equals(id))).write(
      ObservationsCompanion(
        syncStatus: Value(status),
        remoteId: remoteId != null ? Value(remoteId) : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // Get next collection number for foray
  Future<int> getNextCollectionNumber(String forayId) async {
    final result = await customSelect(
      'SELECT MAX(CAST(collection_number AS INTEGER)) as max_num FROM observations WHERE foray_id = ?',
      variables: [Variable.withString(forayId)],
    ).getSingle();
    final maxNum = result.data['max_num'] as int?;
    return (maxNum ?? 0) + 1;
  }
}

// Helper class
class ObservationWithDetails {
  final Observation observation;
  final User? collector;
  final List<Photo> photos;

  ObservationWithDetails({
    required this.observation,
    this.collector,
    required this.photos,
  });
}
```

---

## 5. Collaboration Tables

### 5.1 Identifications Table (`database/tables/identifications_table.dart`)

```dart
import 'package:drift/drift.dart';
import 'observations_table.dart';
import 'forays_table.dart';

class Identifications extends Table {
  // Local UUID
  TextColumn get id => text()();
  
  // Remote UUID
  TextColumn get remoteId => text().nullable()();
  
  // Relationships
  TextColumn get observationId => text().references(Observations, #id)();
  TextColumn get identifierId => text().references(Users, #id)();
  
  // Species identification
  TextColumn get speciesName => text()();
  TextColumn get commonName => text().nullable()();
  
  // Confidence
  TextColumn get confidence => text()
      .map(const ConfidenceLevelConverter())
      .withDefault(const Constant('likely'))();
  
  // Optional notes/reasoning
  TextColumn get notes => text().nullable()();
  
  // Vote count (denormalized for performance)
  IntColumn get voteCount => integer().withDefault(const Constant(0))();
  
  // Timestamps
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  
  // Sync
  TextColumn get syncStatus => text()
      .map(const SyncStatusConverter())
      .withDefault(const Constant('local'))();

  @override
  Set<Column> get primaryKey => {id};
}

class IdentificationVotes extends Table {
  TextColumn get identificationId => text().references(Identifications, #id)();
  TextColumn get userId => text().references(Users, #id)();
  DateTimeColumn get votedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {identificationId, userId};
}
```

### 5.2 Comments Table (`database/tables/comments_table.dart`)

```dart
import 'package:drift/drift.dart';
import 'forays_table.dart';

class Comments extends Table {
  // Local UUID
  TextColumn get id => text()();
  
  // Remote UUID
  TextColumn get remoteId => text().nullable()();
  
  // Relationships
  TextColumn get observationId => text().references(Observations, #id)();
  TextColumn get authorId => text().references(Users, #id)();
  
  // Content
  TextColumn get content => text().withLength(min: 1, max: 2000)();
  
  // Timestamps
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  
  // Sync
  TextColumn get syncStatus => text()
      .map(const SyncStatusConverter())
      .withDefault(const Constant('local'))();

  @override
  Set<Column> get primaryKey => {id};
}
```

### 5.3 Collaboration DAO (`database/daos/collaboration_dao.dart`)

```dart
import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/identifications_table.dart';
import '../tables/comments_table.dart';
import '../tables/users_table.dart';
import '../tables/forays_table.dart';

part 'collaboration_dao.g.dart';

@DriftAccessor(tables: [Identifications, IdentificationVotes, Comments, Users])
class CollaborationDao extends DatabaseAccessor<AppDatabase> with _$CollaborationDaoMixin {
  CollaborationDao(super.db);

  // === IDENTIFICATIONS ===

  // Add identification
  Future<Identification> addIdentification(IdentificationsCompanion id) async {
    await into(identifications).insert(id);
    return (select(identifications)..where((i) => i.id.equals(id.id.value)))
        .getSingle();
  }

  // Get identifications for observation
  Future<List<IdentificationWithDetails>> getIdentificationsForObservation(
      String observationId) async {
    final query = select(identifications).join([
      leftOuterJoin(users, users.id.equalsExp(identifications.identifierId)),
    ])
      ..where(identifications.observationId.equals(observationId))
      ..orderBy([OrderingTerm.desc(identifications.voteCount)]);

    final results = await query.get();
    return results.map((row) {
      return IdentificationWithDetails(
        identification: row.readTable(identifications),
        identifier: row.readTableOrNull(users),
      );
    }).toList();
  }

  // Watch identifications for observation
  Stream<List<IdentificationWithDetails>> watchIdentificationsForObservation(
      String observationId) {
    final query = select(identifications).join([
      leftOuterJoin(users, users.id.equalsExp(identifications.identifierId)),
    ])
      ..where(identifications.observationId.equals(observationId))
      ..orderBy([OrderingTerm.desc(identifications.voteCount)]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return IdentificationWithDetails(
          identification: row.readTable(identifications),
          identifier: row.readTableOrNull(users),
        );
      }).toList();
    });
  }

  // Delete identification
  Future<void> deleteIdentification(String id) async {
    await (delete(identificationVotes)..where((v) => v.identificationId.equals(id))).go();
    await (delete(identifications)..where((i) => i.id.equals(id))).go();
  }

  // === VOTING ===

  // Add vote
  Future<void> addVote(String identificationId, String userId) async {
    // Remove any existing vote from this user for this observation
    final identification = await (select(identifications)
          ..where((i) => i.id.equals(identificationId)))
        .getSingle();
    
    // Get all IDs for this observation
    final allIds = await (select(identifications)
          ..where((i) => i.observationId.equals(identification.observationId)))
        .get();
    
    // Remove votes from this user on any ID for this observation
    for (final id in allIds) {
      await (delete(identificationVotes)
            ..where((v) => v.identificationId.equals(id.id) & v.userId.equals(userId)))
          .go();
      await _updateVoteCount(id.id);
    }
    
    // Add new vote
    await into(identificationVotes).insert(
      IdentificationVotesCompanion.insert(
        identificationId: identificationId,
        userId: userId,
      ),
    );
    await _updateVoteCount(identificationId);
  }

  // Remove vote
  Future<void> removeVote(String identificationId, String userId) async {
    await (delete(identificationVotes)
          ..where((v) => v.identificationId.equals(identificationId) & v.userId.equals(userId)))
        .go();
    await _updateVoteCount(identificationId);
  }

  // Check if user has voted
  Future<String?> getUserVoteForObservation(String observationId, String userId) async {
    final allIds = await (select(identifications)
          ..where((i) => i.observationId.equals(observationId)))
        .get();
    
    for (final id in allIds) {
      final vote = await (select(identificationVotes)
            ..where((v) => v.identificationId.equals(id.id) & v.userId.equals(userId)))
          .getSingleOrNull();
      if (vote != null) {
        return id.id;
      }
    }
    return null;
  }

  // Get voters for identification
  Future<List<User>> getVotersForIdentification(String identificationId) async {
    final query = select(identificationVotes).join([
      innerJoin(users, users.id.equalsExp(identificationVotes.userId)),
    ])
      ..where(identificationVotes.identificationId.equals(identificationId));

    final results = await query.get();
    return results.map((row) => row.readTable(users)).toList();
  }

  // Update vote count
  Future<void> _updateVoteCount(String identificationId) async {
    final count = await (select(identificationVotes)
          ..where((v) => v.identificationId.equals(identificationId)))
        .get();
    await (update(identifications)..where((i) => i.id.equals(identificationId))).write(
      IdentificationsCompanion(voteCount: Value(count.length)),
    );
  }

  // === COMMENTS ===

  // Add comment
  Future<Comment> addComment(CommentsCompanion comment) async {
    await into(comments).insert(comment);
    return (select(comments)..where((c) => c.id.equals(comment.id.value))).getSingle();
  }

  // Get comments for observation
  Future<List<CommentWithAuthor>> getCommentsForObservation(String observationId) async {
    final query = select(comments).join([
      leftOuterJoin(users, users.id.equalsExp(comments.authorId)),
    ])
      ..where(comments.observationId.equals(observationId))
      ..orderBy([OrderingTerm.asc(comments.createdAt)]);

    final results = await query.get();
    return results.map((row) {
      return CommentWithAuthor(
        comment: row.readTable(comments),
        author: row.readTableOrNull(users),
      );
    }).toList();
  }

  // Watch comments for observation
  Stream<List<CommentWithAuthor>> watchCommentsForObservation(String observationId) {
    final query = select(comments).join([
      leftOuterJoin(users, users.id.equalsExp(comments.authorId)),
    ])
      ..where(comments.observationId.equals(observationId))
      ..orderBy([OrderingTerm.asc(comments.createdAt)]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return CommentWithAuthor(
          comment: row.readTable(comments),
          author: row.readTableOrNull(users),
        );
      }).toList();
    });
  }

  // Delete comment
  Future<void> deleteComment(String id) {
    return (delete(comments)..where((c) => c.id.equals(id))).go();
  }
}

// Helper classes
class IdentificationWithDetails {
  final Identification identification;
  final User? identifier;

  IdentificationWithDetails({required this.identification, this.identifier});
}

class CommentWithAuthor {
  final Comment comment;
  final User? author;

  CommentWithAuthor({required this.comment, this.author});
}
```

---

## 6. Sync Queue Table

### 6.1 Sync Queue Table (`database/tables/sync_queue_table.dart`)

```dart
import 'package:drift/drift.dart';

class SyncOperationConverter extends TypeConverter<SyncOperation, String> {
  const SyncOperationConverter();
  
  @override
  SyncOperation fromSql(String fromDb) {
    return SyncOperation.values.firstWhere((e) => e.name == fromDb);
  }
  
  @override
  String toSql(SyncOperation value) => value.name;
}

enum SyncOperation { create, update, delete }

class SyncQueueStatusConverter extends TypeConverter<SyncQueueStatus, String> {
  const SyncQueueStatusConverter();
  
  @override
  SyncQueueStatus fromSql(String fromDb) {
    return SyncQueueStatus.values.firstWhere((e) => e.name == fromDb);
  }
  
  @override
  String toSql(SyncQueueStatus value) => value.name;
}

enum SyncQueueStatus { pending, processing, completed, failed }

class SyncQueue extends Table {
  // Auto-increment ID for ordering
  IntColumn get id => integer().autoIncrement()();
  
  // Entity info
  TextColumn get entityType => text()(); // 'foray', 'observation', 'identification', 'comment', 'vote'
  TextColumn get entityId => text()();
  
  // Operation
  TextColumn get operation => text().map(const SyncOperationConverter())();
  
  // Payload (JSON)
  TextColumn get payload => text().nullable()();
  
  // Status
  TextColumn get status => text()
      .map(const SyncQueueStatusConverter())
      .withDefault(const Constant('pending'))();
  
  // Retry tracking
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastAttempt => dateTime().nullable()();
  TextColumn get lastError => text().nullable()();
  
  // Timestamps
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
```

### 6.2 Sync DAO (`database/daos/sync_dao.dart`)

```dart
import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/sync_queue_table.dart';

part 'sync_dao.g.dart';

@DriftAccessor(tables: [SyncQueue])
class SyncDao extends DatabaseAccessor<AppDatabase> with _$SyncDaoMixin {
  SyncDao(super.db);

  // Add to queue
  Future<void> enqueue({
    required String entityType,
    required String entityId,
    required SyncOperation operation,
    String? payload,
  }) {
    return into(syncQueue).insert(
      SyncQueueCompanion.insert(
        entityType: entityType,
        entityId: entityId,
        operation: operation,
        payload: Value(payload),
      ),
    );
  }

  // Get pending items
  Future<List<SyncQueueData>> getPendingItems({int limit = 50}) {
    return (select(syncQueue)
          ..where((q) => q.status.equals('pending'))
          ..orderBy([(q) => OrderingTerm.asc(q.id)])
          ..limit(limit))
        .get();
  }

  // Get failed items for retry
  Future<List<SyncQueueData>> getFailedItemsForRetry({int maxRetries = 3}) {
    return (select(syncQueue)
          ..where((q) => q.status.equals('failed') & q.retryCount.isSmallerThanValue(maxRetries))
          ..orderBy([(q) => OrderingTerm.asc(q.lastAttempt)]))
        .get();
  }

  // Mark as processing
  Future<void> markProcessing(int id) {
    return (update(syncQueue)..where((q) => q.id.equals(id))).write(
      SyncQueueCompanion(
        status: const Value(SyncQueueStatus.processing),
        lastAttempt: Value(DateTime.now()),
      ),
    );
  }

  // Mark as completed
  Future<void> markCompleted(int id) {
    return (update(syncQueue)..where((q) => q.id.equals(id))).write(
      const SyncQueueCompanion(status: Value(SyncQueueStatus.completed)),
    );
  }

  // Mark as failed
  Future<void> markFailed(int id, String error) async {
    final item = await (select(syncQueue)..where((q) => q.id.equals(id))).getSingle();
    await (update(syncQueue)..where((q) => q.id.equals(id))).write(
      SyncQueueCompanion(
        status: const Value(SyncQueueStatus.failed),
        retryCount: Value(item.retryCount + 1),
        lastError: Value(error),
      ),
    );
  }

  // Reset to pending (for retry)
  Future<void> resetToPending(int id) {
    return (update(syncQueue)..where((q) => q.id.equals(id))).write(
      const SyncQueueCompanion(status: Value(SyncQueueStatus.pending)),
    );
  }

  // Delete completed items
  Future<void> deleteCompleted() {
    return (delete(syncQueue)..where((q) => q.status.equals('completed'))).go();
  }

  // Get queue count by status
  Future<int> getCountByStatus(SyncQueueStatus status) async {
    final count = countAll();
    final query = selectOnly(syncQueue)
      ..addColumns([count])
      ..where(syncQueue.status.equals(status.name));
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  // Watch pending count
  Stream<int> watchPendingCount() {
    final count = countAll();
    final query = selectOnly(syncQueue)
      ..addColumns([count])
      ..where(syncQueue.status.equals('pending'));
    return query.watchSingle().map((row) => row.read(count) ?? 0);
  }

  // Remove duplicate entries (same entity, same operation)
  Future<void> deduplicateQueue() async {
    // Keep only the latest entry for each entity+operation combination
    await customStatement('''
      DELETE FROM sync_queue 
      WHERE id NOT IN (
        SELECT MAX(id) 
        FROM sync_queue 
        WHERE status = 'pending'
        GROUP BY entity_type, entity_id, operation
      ) AND status = 'pending'
    ''');
  }
}
```

---

## 7. Mock Data Seeding

### 7.1 Mock Data Seeder (`database/mock_data_seeder.dart`)

```dart
import 'package:uuid/uuid.dart';
import 'database.dart';
import 'tables/forays_table.dart';
import 'tables/observations_table.dart';
import 'tables/photos_table.dart';

class MockDataSeeder {
  final AppDatabase db;
  final _uuid = const Uuid();

  MockDataSeeder(this.db);

  Future<void> seedAll() async {
    await _seedUsers();
    await _seedForays();
    await _seedObservations();
    await _seedIdentifications();
    await _seedComments();
  }

  Future<void> _seedUsers() async {
    final users = [
      UsersCompanion.insert(
        id: 'user-1',
        displayName: 'Alice Mycologist',
        email: const Value('alice@example.com'),
        isAnonymous: const Value(false),
        isCurrent: const Value(true),
      ),
      UsersCompanion.insert(
        id: 'user-2',
        displayName: 'Bob Forager',
        email: const Value('bob@example.com'),
        isAnonymous: const Value(false),
      ),
      UsersCompanion.insert(
        id: 'user-3',
        displayName: 'Carol Chen',
        email: const Value('carol@example.com'),
        isAnonymous: const Value(false),
      ),
    ];

    for (final user in users) {
      await db.into(db.users).insert(user);
    }
  }

  Future<void> _seedForays() async {
    // Society foray
    await db.into(db.forays).insert(ForaysCompanion.insert(
      id: 'foray-1',
      creatorId: 'user-1',
      name: 'Pacific Northwest Mycological Society Fall Foray',
      description: const Value('Annual fall foray at Mount Rainier area'),
      date: DateTime(2026, 10, 15),
      locationName: const Value('Mount Rainier National Park'),
      defaultPrivacy: const Value(PrivacyLevel.foray),
      joinCode: const Value('PNWMS1'),
      isSolo: const Value(false),
    ));

    // Small group foray
    await db.into(db.forays).insert(ForaysCompanion.insert(
      id: 'foray-2',
      creatorId: 'user-2',
      name: 'Weekend Chanterelle Hunt',
      description: const Value('Looking for golden chanterelles'),
      date: DateTime(2026, 10, 20),
      locationName: const Value('Olympic National Forest'),
      defaultPrivacy: const Value(PrivacyLevel.foray),
      joinCode: const Value('CHAN22'),
      isSolo: const Value(false),
    ));

    // Solo foray
    await db.into(db.forays).insert(ForaysCompanion.insert(
      id: 'foray-3',
      creatorId: 'user-1',
      name: 'My Secret Spots',
      date: DateTime(2026, 1, 1),
      defaultPrivacy: const Value(PrivacyLevel.private),
      isSolo: const Value(true),
    ));

    // Add participants
    await db.into(db.forayParticipants).insert(ForayParticipantsCompanion.insert(
      forayId: 'foray-1',
      userId: 'user-1',
      role: const Value(ParticipantRole.organizer),
    ));
    await db.into(db.forayParticipants).insert(ForayParticipantsCompanion.insert(
      forayId: 'foray-1',
      userId: 'user-2',
    ));
    await db.into(db.forayParticipants).insert(ForayParticipantsCompanion.insert(
      forayId: 'foray-1',
      userId: 'user-3',
    ));

    await db.into(db.forayParticipants).insert(ForayParticipantsCompanion.insert(
      forayId: 'foray-2',
      userId: 'user-2',
      role: const Value(ParticipantRole.organizer),
    ));
    await db.into(db.forayParticipants).insert(ForayParticipantsCompanion.insert(
      forayId: 'foray-2',
      userId: 'user-1',
    ));

    await db.into(db.forayParticipants).insert(ForayParticipantsCompanion.insert(
      forayId: 'foray-3',
      userId: 'user-1',
      role: const Value(ParticipantRole.organizer),
    ));
  }

  Future<void> _seedObservations() async {
    final observations = [
      _createObservation(
        id: 'obs-1',
        forayId: 'foray-1',
        collectorId: 'user-1',
        lat: 46.8523,
        lon: -121.7603,
        specimenId: 'PNWMS-001',
        collectionNumber: '1',
        substrate: 'Conifer (fallen log)',
        preliminaryId: 'Cantharellus formosus',
        fieldNotes: 'Golden color, fruity apricot smell, under Douglas fir',
      ),
      _createObservation(
        id: 'obs-2',
        forayId: 'foray-1',
        collectorId: 'user-2',
        lat: 46.8531,
        lon: -121.7612,
        specimenId: 'PNWMS-002',
        collectionNumber: '2',
        substrate: 'Hardwood (fallen log)',
        preliminaryId: 'Laetiporus conifericola',
        fieldNotes: 'Chicken of the woods! Large cluster on hemlock',
      ),
      _createObservation(
        id: 'obs-3',
        forayId: 'foray-1',
        collectorId: 'user-3',
        lat: 46.8515,
        lon: -121.7598,
        specimenId: 'PNWMS-003',
        collectionNumber: '3',
        substrate: 'Soil (forest floor)',
        preliminaryId: 'Amanita muscaria',
        fieldNotes: 'Classic red cap with white spots, under pine',
      ),
      _createObservation(
        id: 'obs-4',
        forayId: 'foray-2',
        collectorId: 'user-2',
        lat: 47.8021,
        lon: -123.6012,
        specimenId: 'CHAN-001',
        collectionNumber: '1',
        substrate: 'Soil (forest floor)',
        preliminaryId: 'Cantharellus cascadensis',
        fieldNotes: 'Cascade chanterelle, smaller than formosus',
        privacyLevel: PrivacyLevel.foray,
      ),
      _createObservation(
        id: 'obs-5',
        forayId: 'foray-3',
        collectorId: 'user-1',
        lat: 47.6062,
        lon: -122.3321,
        collectionNumber: '1',
        substrate: 'Wood chips/mulch',
        preliminaryId: 'Stropharia rugosoannulata',
        fieldNotes: 'Wine cap in garden mulch, excellent condition',
        privacyLevel: PrivacyLevel.private,
      ),
    ];

    for (final obs in observations) {
      await db.into(db.observations).insert(obs);
    }

    // Add mock photos
    for (var i = 1; i <= 5; i++) {
      await db.into(db.photos).insert(PhotosCompanion.insert(
        id: 'photo-$i-1',
        observationId: 'obs-$i',
        localPath: 'assets/images/mock/mushroom_$i.jpg',
        sortOrder: const Value(0),
        uploadStatus: const Value(UploadStatus.uploaded),
      ));
    }
  }

  ObservationsCompanion _createObservation({
    required String id,
    required String forayId,
    required String collectorId,
    required double lat,
    required double lon,
    String? specimenId,
    String? collectionNumber,
    String? substrate,
    String? preliminaryId,
    String? fieldNotes,
    PrivacyLevel privacyLevel = PrivacyLevel.foray,
  }) {
    return ObservationsCompanion.insert(
      id: id,
      forayId: forayId,
      collectorId: collectorId,
      latitude: lat,
      longitude: lon,
      gpsAccuracy: const Value(5.0),
      observedAt: DateTime.now().subtract(Duration(days: id.hashCode % 30)),
      specimenId: Value(specimenId),
      collectionNumber: Value(collectionNumber),
      substrate: Value(substrate),
      preliminaryId: Value(preliminaryId),
      preliminaryIdConfidence: const Value(ConfidenceLevel.likely),
      fieldNotes: Value(fieldNotes),
      privacyLevel: Value(privacyLevel),
      isDraft: const Value(false),
      syncStatus: const Value(SyncStatus.synced),
    );
  }

  Future<void> _seedIdentifications() async {
    // Add some IDs to observations
    await db.into(db.identifications).insert(IdentificationsCompanion.insert(
      id: 'id-1',
      observationId: 'obs-1',
      identifierId: 'user-2',
      speciesName: 'Cantharellus formosus',
      commonName: const Value('Pacific Golden Chanterelle'),
      confidence: const Value(ConfidenceLevel.confident),
      voteCount: const Value(2),
    ));

    await db.into(db.identifications).insert(IdentificationsCompanion.insert(
      id: 'id-2',
      observationId: 'obs-3',
      identifierId: 'user-1',
      speciesName: 'Amanita muscaria var. flavivolvata',
      commonName: const Value('Western Fly Agaric'),
      notes: const Value('Western variety has yellow warts'),
      confidence: const Value(ConfidenceLevel.confident),
      voteCount: const Value(1),
    ));

    // Add votes
    await db.into(db.identificationVotes).insert(IdentificationVotesCompanion.insert(
      identificationId: 'id-1',
      userId: 'user-1',
    ));
    await db.into(db.identificationVotes).insert(IdentificationVotesCompanion.insert(
      identificationId: 'id-1',
      userId: 'user-3',
    ));
    await db.into(db.identificationVotes).insert(IdentificationVotesCompanion.insert(
      identificationId: 'id-2',
      userId: 'user-2',
    ));
  }

  Future<void> _seedComments() async {
    await db.into(db.comments).insert(CommentsCompanion.insert(
      id: 'comment-1',
      observationId: 'obs-1',
      authorId: 'user-3',
      content: 'Beautiful specimen! The false gills are very distinct.',
    ));

    await db.into(db.comments).insert(CommentsCompanion.insert(
      id: 'comment-2',
      observationId: 'obs-2',
      authorId: 'user-1',
      content: 'Great find! How high up on the tree was it?',
    ));

    await db.into(db.comments).insert(CommentsCompanion.insert(
      id: 'comment-3',
      observationId: 'obs-2',
      authorId: 'user-2',
      content: 'About 4 feet up, easy to reach. Still very fresh.',
    ));
  }
}
```

---

## Acceptance Criteria

Phase 2 is complete when:

1. [ ] Drift database initializes without errors
2. [ ] All tables create successfully
3. [ ] All DAOs perform CRUD operations correctly
4. [ ] Relationships work (foray → observations → photos)
5. [ ] Sync queue tracks changes
6. [ ] Mock data seeds successfully
7. [ ] Unit tests pass for all DAOs
8. [ ] Watch streams update on data changes
