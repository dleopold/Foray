import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foray/database/database.dart';
import 'package:foray/database/daos/forays_dao.dart';
import 'package:foray/database/tables/forays_table.dart';

void main() {
  group('ForaysDao', () {
    late AppDatabase db;
    late ForaysDao dao;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      dao = db.foraysDao;
    });

    tearDown(() => db.close());

    // Helper to create a user first
    Future<User> createTestUser(String id) async {
      return db.usersDao.createAnonymousUser(
        id: id,
        deviceId: 'device-$id',
        displayName: 'User $id',
      );
    }

    // Helper to create a foray
    Future<Foray> createTestForay({
      required String id,
      required String creatorId,
      String name = 'Test Foray',
    }) async {
      final foray = ForaysCompanion.insert(
        id: id,
        creatorId: creatorId,
        name: name,
        date: DateTime.now(),
      );
      return dao.createForay(foray);
    }

    group('createForay', () {
      test('creates foray with correct fields', () async {
        final user = await createTestUser('user-1');
        final foray = await createTestForay(
          id: 'foray-1',
          creatorId: user.id,
          name: 'My Foray',
        );

        expect(foray.id, equals('foray-1'));
        expect(foray.creatorId, equals(user.id));
        expect(foray.name, equals('My Foray'));
        expect(foray.status, equals(ForayStatus.active));
        expect(foray.isSolo, isFalse);
        expect(foray.observationsLocked, isFalse);
      });

      test('created foray can be retrieved', () async {
        final user = await createTestUser('user-1');
        await createTestForay(id: 'foray-1', creatorId: user.id);

        final retrieved = await dao.getForayById('foray-1');
        expect(retrieved, isNotNull);
        expect(retrieved!.id, equals('foray-1'));
      });
    });

    group('getForayById', () {
      test('returns foray when exists', () async {
        final user = await createTestUser('user-1');
        await createTestForay(id: 'foray-1', creatorId: user.id);

        final foray = await dao.getForayById('foray-1');
        expect(foray, isNotNull);
        expect(foray!.id, equals('foray-1'));
      });

      test('returns null when foray does not exist', () async {
        final foray = await dao.getForayById('non-existent');
        expect(foray, isNull);
      });
    });

    group('getForayByJoinCode', () {
      test('returns foray when join code exists', () async {
        final user = await createTestUser('user-1');
        await createTestForay(id: 'foray-1', creatorId: user.id);
        await dao.updateForay(
          'foray-1',
          const ForaysCompanion(joinCode: Value('ABC123')),
        );

        final foray = await dao.getForayByJoinCode('ABC123');
        expect(foray, isNotNull);
        expect(foray!.id, equals('foray-1'));
      });

      test('is case insensitive', () async {
        final user = await createTestUser('user-1');
        await createTestForay(id: 'foray-1', creatorId: user.id);
        await dao.updateForay(
          'foray-1',
          const ForaysCompanion(joinCode: Value('ABC123')),
        );

        final foray = await dao.getForayByJoinCode('abc123');
        expect(foray, isNotNull);
      });

      test('returns null when join code does not exist', () async {
        final foray = await dao.getForayByJoinCode('NONEXISTENT');
        expect(foray, isNull);
      });
    });

    group('getForaysForUser', () {
      test('returns empty list when user has no forays', () async {
        final user = await createTestUser('user-1');

        final forays = await dao.getForaysForUser(user.id);
        expect(forays, isEmpty);
      });

      test('returns forays user participates in', () async {
        final user1 = await createTestUser('user-1');
        final user2 = await createTestUser('user-2');
        final foray = await createTestForay(id: 'foray-1', creatorId: user1.id);

        await dao.addParticipant(forayId: foray.id, userId: user2.id);

        final forays = await dao.getForaysForUser(user2.id);
        expect(forays.length, equals(1));
        expect(forays.first.foray.id, equals('foray-1'));
      });

      test('returns correct role for user', () async {
        final user = await createTestUser('user-1');
        final foray = await createTestForay(id: 'foray-1', creatorId: user.id);
        await dao.addParticipant(
          forayId: foray.id,
          userId: user.id,
          role: ParticipantRole.organizer,
        );

        final forays = await dao.getForaysForUser(user.id);
        expect(forays.first.role, equals(ParticipantRole.organizer));
        expect(forays.first.isOrganizer, isTrue);
      });

      test('orders by date descending', () async {
        final user = await createTestUser('user-1');
        final foray1 = await createTestForay(
          id: 'foray-1',
          creatorId: user.id,
        );
        await dao.addParticipant(forayId: foray1.id, userId: user.id);

        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        final foray2 = ForaysCompanion.insert(
          id: 'foray-2',
          creatorId: user.id,
          name: 'Older Foray',
          date: yesterday,
        );
        final createdForay2 = await dao.createForay(foray2);
        await dao.addParticipant(forayId: createdForay2.id, userId: user.id);

        final forays = await dao.getForaysForUser(user.id);
        expect(forays.length, equals(2));
        expect(forays[0].foray.id, equals('foray-1')); // Newer first
        expect(forays[1].foray.id, equals('foray-2')); // Older second
      });
    });

    group('watchForaysForUser', () {
      test('emits updates when foray added', () async {
        final user = await createTestUser('user-1');
        final stream = dao.watchForaysForUser(user.id);

        expect(await stream.first, isEmpty);

        final foray = await createTestForay(id: 'foray-1', creatorId: user.id);
        await dao.addParticipant(forayId: foray.id, userId: user.id);

        final forays = await stream.first;
        expect(forays.length, equals(1));
      });
    });

    group('updateForay', () {
      test('updates specified fields', () async {
        final user = await createTestUser('user-1');
        await createTestForay(
            id: 'foray-1', creatorId: user.id, name: 'Original',);

        await dao.updateForay(
          'foray-1',
          const ForaysCompanion(name: Value('Updated')),
        );

        final foray = await dao.getForayById('foray-1');
        expect(foray!.name, equals('Updated'));
      });

      test('updates updatedAt timestamp', () async {
        final user = await createTestUser('user-1');
        await createTestForay(id: 'foray-1', creatorId: user.id);

        // Wait a bit, then capture "before" time right before update
        await Future.delayed(const Duration(milliseconds: 100));
        final before = DateTime.now();

        await dao.updateForay(
          'foray-1',
          const ForaysCompanion(name: Value('Updated')),
        );

        final foray = await dao.getForayById('foray-1');
        // Allow small buffer for SQLite timestamp truncation
        expect(foray!.updatedAt.difference(before).inMilliseconds >= -1000,
            isTrue,);
      });
    });

    group('deleteForay', () {
      test('deletes foray', () async {
        final user = await createTestUser('user-1');
        final foray = await createTestForay(id: 'foray-1', creatorId: user.id);
        await dao.addParticipant(forayId: foray.id, userId: user.id);

        await dao.deleteForay('foray-1');

        final retrieved = await dao.getForayById('foray-1');
        expect(retrieved, isNull);
      });

      test('deletes associated participants', () async {
        final user = await createTestUser('user-1');
        final foray = await createTestForay(id: 'foray-1', creatorId: user.id);
        await dao.addParticipant(forayId: foray.id, userId: user.id);

        await dao.deleteForay('foray-1');

        final isParticipant = await dao.isParticipant(foray.id, user.id);
        expect(isParticipant, isFalse);
      });
    });

    group('updateForayStatus', () {
      test('updates status to completed', () async {
        final user = await createTestUser('user-1');
        await createTestForay(id: 'foray-1', creatorId: user.id);

        await dao.updateForayStatus('foray-1', ForayStatus.completed);

        final foray = await dao.getForayById('foray-1');
        expect(foray!.status, equals(ForayStatus.completed));
      });
    });

    group('setObservationsLocked', () {
      test('locks observations', () async {
        final user = await createTestUser('user-1');
        await createTestForay(id: 'foray-1', creatorId: user.id);

        await dao.setObservationsLocked('foray-1', true);

        final foray = await dao.getForayById('foray-1');
        expect(foray!.observationsLocked, isTrue);
      });

      test('unlocks observations', () async {
        final user = await createTestUser('user-1');
        await createTestForay(id: 'foray-1', creatorId: user.id);
        await dao.setObservationsLocked('foray-1', true);

        await dao.setObservationsLocked('foray-1', false);

        final foray = await dao.getForayById('foray-1');
        expect(foray!.observationsLocked, isFalse);
      });
    });

    group('addParticipant', () {
      test('adds participant with default role', () async {
        final user1 = await createTestUser('user-1');
        final user2 = await createTestUser('user-2');
        final foray = await createTestForay(id: 'foray-1', creatorId: user1.id);

        await dao.addParticipant(forayId: foray.id, userId: user2.id);

        final role = await dao.getUserRole(foray.id, user2.id);
        expect(role, equals(ParticipantRole.participant));
      });

      test('adds participant with organizer role', () async {
        final user1 = await createTestUser('user-1');
        final user2 = await createTestUser('user-2');
        final foray = await createTestForay(id: 'foray-1', creatorId: user1.id);

        await dao.addParticipant(
          forayId: foray.id,
          userId: user2.id,
          role: ParticipantRole.organizer,
        );

        final role = await dao.getUserRole(foray.id, user2.id);
        expect(role, equals(ParticipantRole.organizer));
      });
    });

    group('removeParticipant', () {
      test('removes participant from foray', () async {
        final user1 = await createTestUser('user-1');
        final user2 = await createTestUser('user-2');
        final foray = await createTestForay(id: 'foray-1', creatorId: user1.id);
        await dao.addParticipant(forayId: foray.id, userId: user2.id);

        await dao.removeParticipant(foray.id, user2.id);

        final isParticipant = await dao.isParticipant(foray.id, user2.id);
        expect(isParticipant, isFalse);
      });
    });

    group('getParticipants', () {
      test('returns participants with user details', () async {
        final user1 = await createTestUser('user-1');
        final user2 = await createTestUser('user-2');
        final foray = await createTestForay(id: 'foray-1', creatorId: user1.id);
        await dao.addParticipant(forayId: foray.id, userId: user1.id);
        await dao.addParticipant(forayId: foray.id, userId: user2.id);

        final participants = await dao.getParticipants(foray.id);
        expect(participants.length, equals(2));
        expect(
          participants.map((p) => p.user.id),
          containsAll([user1.id, user2.id]),
        );
      });
    });

    group('isParticipant', () {
      test('returns true when user is participant', () async {
        final user1 = await createTestUser('user-1');
        final user2 = await createTestUser('user-2');
        final foray = await createTestForay(id: 'foray-1', creatorId: user1.id);
        await dao.addParticipant(forayId: foray.id, userId: user2.id);

        final isParticipant = await dao.isParticipant(foray.id, user2.id);
        expect(isParticipant, isTrue);
      });

      test('returns false when user is not participant', () async {
        final user1 = await createTestUser('user-1');
        final user2 = await createTestUser('user-2');
        final foray = await createTestForay(id: 'foray-1', creatorId: user1.id);

        final isParticipant = await dao.isParticipant(foray.id, user2.id);
        expect(isParticipant, isFalse);
      });
    });

    group('getUserRole', () {
      test('returns role when user is participant', () async {
        final user1 = await createTestUser('user-1');
        final user2 = await createTestUser('user-2');
        final foray = await createTestForay(id: 'foray-1', creatorId: user1.id);
        await dao.addParticipant(
          forayId: foray.id,
          userId: user2.id,
          role: ParticipantRole.organizer,
        );

        final role = await dao.getUserRole(foray.id, user2.id);
        expect(role, equals(ParticipantRole.organizer));
      });

      test('returns null when user is not participant', () async {
        final user1 = await createTestUser('user-1');
        final user2 = await createTestUser('user-2');
        final foray = await createTestForay(id: 'foray-1', creatorId: user1.id);

        final role = await dao.getUserRole(foray.id, user2.id);
        expect(role, isNull);
      });
    });

    group('updateSyncStatus', () {
      test('updates sync status', () async {
        final user = await createTestUser('user-1');
        await createTestForay(id: 'foray-1', creatorId: user.id);

        await dao.updateSyncStatus('foray-1', SyncStatus.synced,
            remoteId: 'remote-123',);

        final foray = await dao.getForayById('foray-1');
        expect(foray!.syncStatus, equals(SyncStatus.synced));
        expect(foray.remoteId, equals('remote-123'));
      });

      test('getForaysPendingSync returns only pending forays', () async {
        final user = await createTestUser('user-1');
        await createTestForay(id: 'foray-1', creatorId: user.id);
        await createTestForay(id: 'foray-2', creatorId: user.id);
        // Set one to synced, one to pending (default is local)
        await dao.updateSyncStatus('foray-1', SyncStatus.synced);
        await dao.updateSyncStatus('foray-2', SyncStatus.pending);

        final pending = await dao.getForaysPendingSync();
        expect(pending.length, equals(1));
        expect(pending.first.id, equals('foray-2'));
      });
    });
  });
}
