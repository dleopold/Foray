import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/forays_table.dart';
import '../tables/observations_table.dart';
import '../tables/photos_table.dart';
import '../tables/users_table.dart';

part 'observations_dao.g.dart';

/// Data Access Object for [Observations] and [Photos] tables.
///
/// Handles observation CRUD, photo management, and sync operations.
@DriftAccessor(tables: [Observations, Photos, Forays, Users])
class ObservationsDao extends DatabaseAccessor<AppDatabase>
    with _$ObservationsDaoMixin {
  ObservationsDao(super.db);

  // =========================================================================
  // Observation CRUD
  // =========================================================================

  /// Create a new observation.
  Future<Observation> createObservation(
      ObservationsCompanion observation) async {
    await into(observations).insert(observation);
    return (select(observations)
          ..where((o) => o.id.equals(observation.id.value)))
        .getSingle();
  }

  /// Get an observation by its local ID.
  Future<Observation?> getObservationById(String id) {
    return (select(observations)..where((o) => o.id.equals(id)))
        .getSingleOrNull();
  }

  /// Get an observation by specimen ID within a foray.
  Future<Observation?> getObservationBySpecimenId(
      String forayId, String specimenId) {
    return (select(observations)
          ..where(
              (o) => o.forayId.equals(forayId) & o.specimenId.equals(specimenId)))
        .getSingleOrNull();
  }

  /// Get all observations for a foray with collector and photos.
  Future<List<ObservationWithDetails>> getObservationsForForay(
      String forayId) async {
    final query = select(observations).join([
      leftOuterJoin(users, users.id.equalsExp(observations.collectorId)),
    ])
      ..where(observations.forayId.equals(forayId))
      ..orderBy([OrderingTerm.desc(observations.observedAt)]);

    final results = await query.get();
    final observationIds =
        results.map((r) => r.readTable(observations).id).toList();

    // Get photos for all observations in one query
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

  /// Watch observations for a foray with real-time updates.
  Stream<List<ObservationWithDetails>> watchObservationsForForay(
      String forayId) {
    final obsQuery = select(observations)
      ..where((o) => o.forayId.equals(forayId))
      ..orderBy([(o) => OrderingTerm.desc(o.observedAt)]);

    return obsQuery.watch().asyncMap((obsList) async {
      final details = <ObservationWithDetails>[];
      for (final obs in obsList) {
        final collector = await (select(users)
              ..where((u) => u.id.equals(obs.collectorId)))
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

  /// Get all observations by a specific user.
  Future<List<Observation>> getObservationsForUser(String userId) {
    return (select(observations)
          ..where((o) => o.collectorId.equals(userId))
          ..orderBy([(o) => OrderingTerm.desc(o.observedAt)]))
        .get();
  }

  /// Update an observation.
  Future<void> updateObservation(String id, ObservationsCompanion companion) {
    return (update(observations)..where((o) => o.id.equals(id))).write(
      companion.copyWith(updatedAt: Value(DateTime.now())),
    );
  }

  /// Delete an observation and its photos.
  Future<void> deleteObservation(String id) async {
    await (delete(photos)..where((p) => p.observationId.equals(id))).go();
    await (delete(observations)..where((o) => o.id.equals(id))).go();
  }

  /// Mark an observation as viewed.
  Future<void> markAsViewed(String id) {
    return (update(observations)..where((o) => o.id.equals(id))).write(
      ObservationsCompanion(lastViewedAt: Value(DateTime.now())),
    );
  }

  // =========================================================================
  // Photo Operations
  // =========================================================================

  /// Add a photo to an observation.
  Future<void> addPhoto(PhotosCompanion photo) {
    return into(photos).insert(photo);
  }

  /// Delete a photo.
  Future<void> deletePhoto(String id) {
    return (delete(photos)..where((p) => p.id.equals(id))).go();
  }

  /// Get all photos for an observation.
  Future<List<Photo>> getPhotosForObservation(String observationId) {
    return (select(photos)
          ..where((p) => p.observationId.equals(observationId))
          ..orderBy([(p) => OrderingTerm.asc(p.sortOrder)]))
        .get();
  }

  /// Update photo upload status.
  Future<void> updatePhotoUploadStatus(String id, UploadStatus status,
      {String? remoteUrl}) {
    return (update(photos)..where((p) => p.id.equals(id))).write(
      PhotosCompanion(
        uploadStatus: Value(status),
        remoteUrl: remoteUrl != null ? Value(remoteUrl) : const Value.absent(),
      ),
    );
  }

  /// Get photos pending upload.
  Future<List<Photo>> getPhotosPendingUpload() {
    return (select(photos)..where((p) => p.uploadStatus.equals('pending')))
        .get();
  }

  /// Reorder photos for an observation.
  Future<void> reorderPhotos(
      String observationId, List<String> photoIds) async {
    await transaction(() async {
      for (var i = 0; i < photoIds.length; i++) {
        await (update(photos)..where((p) => p.id.equals(photoIds[i]))).write(
          PhotosCompanion(sortOrder: Value(i)),
        );
      }
    });
  }

  // =========================================================================
  // Sync Operations
  // =========================================================================

  /// Get observations pending sync.
  Future<List<Observation>> getObservationsPendingSync() {
    return (select(observations)
          ..where(
              (o) => o.syncStatus.equals('pending') & o.isDraft.equals(false)))
        .get();
  }

  /// Update sync status for an observation.
  Future<void> updateSyncStatus(String id, SyncStatus status,
      {String? remoteId}) {
    return (update(observations)..where((o) => o.id.equals(id))).write(
      ObservationsCompanion(
        syncStatus: Value(status),
        remoteId: remoteId != null ? Value(remoteId) : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // =========================================================================
  // Collection Numbers
  // =========================================================================

  /// Get the next collection number for a foray.
  Future<int> getNextCollectionNumber(String forayId) async {
    final result = await customSelect(
      'SELECT MAX(CAST(collection_number AS INTEGER)) as max_num '
      'FROM observations WHERE foray_id = ?',
      variables: [Variable.withString(forayId)],
    ).getSingle();
    final maxNum = result.data['max_num'] as int?;
    return (maxNum ?? 0) + 1;
  }

  /// Check if a specimen ID is unique within a foray.
  Future<bool> isSpecimenIdUnique(
      String forayId, String specimenId, String? excludeId) async {
    var query = select(observations)
      ..where(
          (o) => o.forayId.equals(forayId) & o.specimenId.equals(specimenId));

    if (excludeId != null) {
      query = query..where((o) => o.id.equals(excludeId).not());
    }

    final existing = await query.getSingleOrNull();
    return existing == null;
  }
}

// ============================================================================
// Helper Classes
// ============================================================================

/// An observation with its collector and photos.
class ObservationWithDetails {
  final Observation observation;
  final User? collector;
  final List<Photo> photos;

  ObservationWithDetails({
    required this.observation,
    this.collector,
    required this.photos,
  });

  /// Get the primary (first) photo, if any.
  Photo? get primaryPhoto => photos.isNotEmpty ? photos.first : null;

  /// Whether this observation has been updated since last viewed.
  bool get hasUpdates =>
      observation.lastViewedAt == null ||
      observation.updatedAt.isAfter(observation.lastViewedAt!);
}
