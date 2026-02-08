import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foray/database/database.dart';
import 'package:foray/database/daos/observations_dao.dart';
import 'package:foray/database/tables/forays_table.dart';
import 'package:foray/database/tables/observations_table.dart';
import 'package:foray/database/tables/photos_table.dart';

void main() {
  group('ObservationsDao', () {
    late AppDatabase db;
    late ObservationsDao dao;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      dao = db.observationsDao;
    });

    tearDown(() => db.close());

    // Helper to create a user
    Future<User> createTestUser(String id) async {
      return db.usersDao.createAnonymousUser(
        id: id,
        deviceId: 'device-$id',
        displayName: 'User $id',
      );
    }

    // Helper to create a foray
    Future<Foray> createTestForay(String id, String creatorId) async {
      final foray = await db.foraysDao.createForay(
        ForaysCompanion.insert(
          id: id,
          creatorId: creatorId,
          name: 'Test Foray',
          date: DateTime.now(),
        ),
      );
      await db.foraysDao.addParticipant(forayId: foray.id, userId: creatorId);
      return foray;
    }

    // Helper to create an observation
    Future<Observation> createTestObservation({
      required String id,
      required String forayId,
      required String collectorId,
      String? specimenId,
      bool isDraft = false,
    }) async {
      final obs = ObservationsCompanion.insert(
        id: id,
        forayId: forayId,
        collectorId: collectorId,
        latitude: 40.7128,
        longitude: -74.0060,
        privacyLevel: const Value(PrivacyLevel.foray),
        observedAt: DateTime.now(),
        specimenId:
            specimenId != null ? Value(specimenId) : const Value.absent(),
        isDraft: Value(isDraft),
      );
      return dao.createObservation(obs);
    }

    group('createObservation', () {
      test('creates observation with correct fields', () async {
        final user = await createTestUser('user-1');
        final foray = await createTestForay('foray-1', user.id);

        final obs = await createTestObservation(
          id: 'obs-1',
          forayId: foray.id,
          collectorId: user.id,
        );

        expect(obs.id, equals('obs-1'));
        expect(obs.forayId, equals(foray.id));
        expect(obs.collectorId, equals(user.id));
        expect(obs.latitude, equals(40.7128));
        expect(obs.longitude, equals(-74.0060));
        expect(obs.privacyLevel, equals(PrivacyLevel.foray));
        expect(obs.isDraft, isFalse);
        expect(obs.syncStatus, equals(SyncStatus.local));
      });

      test('created observation can be retrieved', () async {
        final user = await createTestUser('user-1');
        final foray = await createTestForay('foray-1', user.id);
        await createTestObservation(
            id: 'obs-1', forayId: foray.id, collectorId: user.id);

        final retrieved = await dao.getObservationById('obs-1');
        expect(retrieved, isNotNull);
        expect(retrieved!.id, equals('obs-1'));
      });
    });

    group('getObservationById', () {
      test('returns observation when exists', () async {
        final user = await createTestUser('user-1');
        final foray = await createTestForay('foray-1', user.id);
        await createTestObservation(
            id: 'obs-1', forayId: foray.id, collectorId: user.id);

        final obs = await dao.getObservationById('obs-1');
        expect(obs, isNotNull);
        expect(obs!.id, equals('obs-1'));
      });

      test('returns null when observation does not exist', () async {
        final obs = await dao.getObservationById('non-existent');
        expect(obs, isNull);
      });
    });

    group('getObservationBySpecimenId', () {
      test('returns observation when specimen ID exists', () async {
        final user = await createTestUser('user-1');
        final foray = await createTestForay('foray-1', user.id);
        await createTestObservation(
          id: 'obs-1',
          forayId: foray.id,
          collectorId: user.id,
          specimenId: 'SPEC-001',
        );

        final obs = await dao.getObservationBySpecimenId(foray.id, 'SPEC-001');
        expect(obs, isNotNull);
        expect(obs!.specimenId, equals('SPEC-001'));
      });

      test('returns null when specimen ID does not exist in foray', () async {
        final user = await createTestUser('user-1');
        final foray = await createTestForay('foray-1', user.id);

        final obs =
            await dao.getObservationBySpecimenId(foray.id, 'NONEXISTENT');
        expect(obs, isNull);
      });
    });

    group('getObservationsForForay', () {
      test('returns empty list when no observations', () async {
        final user = await createTestUser('user-1');
        final foray = await createTestForay('foray-1', user.id);

        final observations = await dao.getObservationsForForay(foray.id);
        expect(observations, isEmpty);
      });

      test('returns observations with details', () async {
        final user = await createTestUser('user-1');
        final foray = await createTestForay('foray-1', user.id);
        await createTestObservation(
            id: 'obs-1', forayId: foray.id, collectorId: user.id);

        final observations = await dao.getObservationsForForay(foray.id);
        expect(observations.length, equals(1));
        expect(observations.first.observation.id, equals('obs-1'));
        expect(observations.first.collector, isNotNull);
      });

      test('includes photos in details', () async {
        final user = await createTestUser('user-1');
        final foray = await createTestForay('foray-1', user.id);
        final obs = await createTestObservation(
            id: 'obs-1', forayId: foray.id, collectorId: user.id);

        await dao.addPhoto(PhotosCompanion.insert(
          id: 'photo-1',
          observationId: obs.id,
          localPath: '/path/to/photo.jpg',
        ));

        final observations = await dao.getObservationsForForay(foray.id);
        expect(observations.first.photos.length, equals(1));
        expect(observations.first.photos.first.id, equals('photo-1'));
      });
    });

    group('getObservationsForUser', () {
      test('returns observations for specific user', () async {
        final user1 = await createTestUser('user-1');
        final user2 = await createTestUser('user-2');
        final foray = await createTestForay('foray-1', user1.id);
        await createTestObservation(
            id: 'obs-1', forayId: foray.id, collectorId: user1.id);
        await createTestObservation(
            id: 'obs-2', forayId: foray.id, collectorId: user2.id);

        final observations = await dao.getObservationsForUser(user1.id);
        expect(observations.length, equals(1));
        expect(observations.first.id, equals('obs-1'));
      });
    });

    group('updateObservation', () {
      test('updates specified fields', () async {
        final user = await createTestUser('user-1');
        final foray = await createTestForay('foray-1', user.id);
        await createTestObservation(
            id: 'obs-1', forayId: foray.id, collectorId: user.id);

        await dao.updateObservation(
          'obs-1',
          const ObservationsCompanion(fieldNotes: Value('Updated notes')),
        );

        final obs = await dao.getObservationById('obs-1');
        expect(obs!.fieldNotes, equals('Updated notes'));
      });
    });

    group('deleteObservation', () {
      test('deletes observation', () async {
        final user = await createTestUser('user-1');
        final foray = await createTestForay('foray-1', user.id);
        await createTestObservation(
            id: 'obs-1', forayId: foray.id, collectorId: user.id);

        await dao.deleteObservation('obs-1');

        final retrieved = await dao.getObservationById('obs-1');
        expect(retrieved, isNull);
      });

      test('deletes associated photos', () async {
        final user = await createTestUser('user-1');
        final foray = await createTestForay('foray-1', user.id);
        final obs = await createTestObservation(
            id: 'obs-1', forayId: foray.id, collectorId: user.id);
        await dao.addPhoto(PhotosCompanion.insert(
          id: 'photo-1',
          observationId: obs.id,
          localPath: '/path/to/photo.jpg',
        ));

        await dao.deleteObservation('obs-1');

        final photos = await dao.getPhotosForObservation(obs.id);
        expect(photos, isEmpty);
      });
    });

    group('markAsViewed', () {
      test('updates lastViewedAt timestamp', () async {
        final user = await createTestUser('user-1');
        final foray = await createTestForay('foray-1', user.id);
        await createTestObservation(
            id: 'obs-1', forayId: foray.id, collectorId: user.id);

        final before = DateTime.now();
        await Future.delayed(const Duration(milliseconds: 50));
        await dao.markAsViewed('obs-1');

        final obs = await dao.getObservationById('obs-1');
        // Allow small buffer for SQLite timestamp truncation
        expect(obs!.lastViewedAt!.difference(before).inMilliseconds >= -1000,
            isTrue);
      });
    });

    group('addPhoto', () {
      test('adds photo to observation', () async {
        final user = await createTestUser('user-1');
        final foray = await createTestForay('foray-1', user.id);
        final obs = await createTestObservation(
            id: 'obs-1', forayId: foray.id, collectorId: user.id);

        await dao.addPhoto(PhotosCompanion.insert(
          id: 'photo-1',
          observationId: obs.id,
          localPath: '/path/to/photo.jpg',
        ));

        final photos = await dao.getPhotosForObservation(obs.id);
        expect(photos.length, equals(1));
        expect(photos.first.id, equals('photo-1'));
      });
    });

    group('deletePhoto', () {
      test('deletes photo', () async {
        final user = await createTestUser('user-1');
        final foray = await createTestForay('foray-1', user.id);
        final obs = await createTestObservation(
            id: 'obs-1', forayId: foray.id, collectorId: user.id);
        await dao.addPhoto(PhotosCompanion.insert(
          id: 'photo-1',
          observationId: obs.id,
          localPath: '/path/to/photo.jpg',
        ));

        await dao.deletePhoto('photo-1');

        final photos = await dao.getPhotosForObservation(obs.id);
        expect(photos, isEmpty);
      });
    });

    group('updatePhotoUploadStatus', () {
      test('updates upload status and remote URL', () async {
        final user = await createTestUser('user-1');
        final foray = await createTestForay('foray-1', user.id);
        final obs = await createTestObservation(
            id: 'obs-1', forayId: foray.id, collectorId: user.id);
        await dao.addPhoto(PhotosCompanion.insert(
          id: 'photo-1',
          observationId: obs.id,
          localPath: '/path/to/photo.jpg',
        ));

        await dao.updatePhotoUploadStatus(
          'photo-1',
          UploadStatus.uploaded,
          remoteUrl: 'https://example.com/photo.jpg',
        );

        final photos = await dao.getPhotosForObservation(obs.id);
        expect(photos.first.uploadStatus, equals(UploadStatus.uploaded));
        expect(photos.first.remoteUrl, equals('https://example.com/photo.jpg'));
      });
    });

    group('getPhotosPendingUpload', () {
      test('returns only pending photos', () async {
        final user = await createTestUser('user-1');
        final foray = await createTestForay('foray-1', user.id);
        final obs = await createTestObservation(
            id: 'obs-1', forayId: foray.id, collectorId: user.id);

        await dao.addPhoto(PhotosCompanion.insert(
          id: 'photo-1',
          observationId: obs.id,
          localPath: '/path/to/photo1.jpg',
        ));
        await dao.addPhoto(PhotosCompanion.insert(
          id: 'photo-2',
          observationId: obs.id,
          localPath: '/path/to/photo2.jpg',
          uploadStatus: const Value(UploadStatus.uploaded),
        ));

        final pending = await dao.getPhotosPendingUpload();
        expect(pending.length, equals(1));
        expect(pending.first.id, equals('photo-1'));
      });
    });

    group('reorderPhotos', () {
      test('updates photo sort order', () async {
        final user = await createTestUser('user-1');
        final foray = await createTestForay('foray-1', user.id);
        final obs = await createTestObservation(
            id: 'obs-1', forayId: foray.id, collectorId: user.id);

        await dao.addPhoto(PhotosCompanion.insert(
          id: 'photo-1',
          observationId: obs.id,
          localPath: '/path/to/photo1.jpg',
          sortOrder: const Value(0),
        ));
        await dao.addPhoto(PhotosCompanion.insert(
          id: 'photo-2',
          observationId: obs.id,
          localPath: '/path/to/photo2.jpg',
          sortOrder: const Value(1),
        ));

        await dao.reorderPhotos(obs.id, ['photo-2', 'photo-1']);

        final photos = await dao.getPhotosForObservation(obs.id);
        expect(photos[0].id, equals('photo-2'));
        expect(photos[0].sortOrder, equals(0));
        expect(photos[1].id, equals('photo-1'));
        expect(photos[1].sortOrder, equals(1));
      });
    });

    group('updateSyncStatus', () {
      test('updates sync status and remote ID', () async {
        final user = await createTestUser('user-1');
        final foray = await createTestForay('foray-1', user.id);
        await createTestObservation(
            id: 'obs-1', forayId: foray.id, collectorId: user.id);

        await dao.updateSyncStatus('obs-1', SyncStatus.synced,
            remoteId: 'remote-123');

        final obs = await dao.getObservationById('obs-1');
        expect(obs!.syncStatus, equals(SyncStatus.synced));
        expect(obs.remoteId, equals('remote-123'));
      });

      test('getObservationsPendingSync excludes drafts', () async {
        final user = await createTestUser('user-1');
        final foray = await createTestForay('foray-1', user.id);
        await createTestObservation(
            id: 'obs-1',
            forayId: foray.id,
            collectorId: user.id,
            isDraft: true);
        final obs2 = await createTestObservation(
            id: 'obs-2',
            forayId: foray.id,
            collectorId: user.id,
            isDraft: false);
        // Set to pending (default is local)
        await dao.updateSyncStatus(obs2.id, SyncStatus.pending);

        final pending = await dao.getObservationsPendingSync();
        expect(pending.length, equals(1));
        expect(pending.first.id, equals('obs-2'));
      });
    });

    group('getNextCollectionNumber', () {
      test('returns 1 for first observation', () async {
        final user = await createTestUser('user-1');
        final foray = await createTestForay('foray-1', user.id);

        final nextNum = await dao.getNextCollectionNumber(foray.id);
        expect(nextNum, equals(1));
      });

      test('returns next number after existing', () async {
        final user = await createTestUser('user-1');
        final foray = await createTestForay('foray-1', user.id);
        await createTestObservation(
          id: 'obs-1',
          forayId: foray.id,
          collectorId: user.id,
        );
        await dao.updateObservation(
          'obs-1',
          const ObservationsCompanion(collectionNumber: Value('5')),
        );

        final nextNum = await dao.getNextCollectionNumber(foray.id);
        expect(nextNum, equals(6));
      });
    });

    group('isSpecimenIdUnique', () {
      test('returns true when specimen ID is unique', () async {
        final user = await createTestUser('user-1');
        final foray = await createTestForay('foray-1', user.id);

        final isUnique =
            await dao.isSpecimenIdUnique(foray.id, 'SPEC-001', null);
        expect(isUnique, isTrue);
      });

      test('returns false when specimen ID exists', () async {
        final user = await createTestUser('user-1');
        final foray = await createTestForay('foray-1', user.id);
        await createTestObservation(
          id: 'obs-1',
          forayId: foray.id,
          collectorId: user.id,
          specimenId: 'SPEC-001',
        );

        final isUnique =
            await dao.isSpecimenIdUnique(foray.id, 'SPEC-001', null);
        expect(isUnique, isFalse);
      });

      test('returns true when excluding self', () async {
        final user = await createTestUser('user-1');
        final foray = await createTestForay('foray-1', user.id);
        await createTestObservation(
          id: 'obs-1',
          forayId: foray.id,
          collectorId: user.id,
          specimenId: 'SPEC-001',
        );

        final isUnique =
            await dao.isSpecimenIdUnique(foray.id, 'SPEC-001', 'obs-1');
        expect(isUnique, isTrue);
      });
    });
  });
}
