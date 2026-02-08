import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foray/database/database.dart';
import 'package:foray/database/daos/users_dao.dart';
import 'package:foray/database/tables/users_table.dart';

void main() {
  group('UsersDao', () {
    late AppDatabase db;
    late UsersDao dao;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      dao = db.usersDao;
    });

    tearDown(() => db.close());

    group('createAnonymousUser', () {
      test('creates anonymous user with correct fields', () async {
        final user = await dao.createAnonymousUser(
          id: 'user-1',
          deviceId: 'device-123',
          displayName: 'Anonymous User',
        );

        expect(user.id, equals('user-1'));
        expect(user.deviceId, equals('device-123'));
        expect(user.displayName, equals('Anonymous User'));
        expect(user.isAnonymous, isTrue);
        expect(user.isCurrent, isTrue);
        expect(user.email, isNull);
      });

      test('created user can be retrieved', () async {
        await dao.createAnonymousUser(
          id: 'user-1',
          deviceId: 'device-123',
          displayName: 'Test User',
        );

        final retrieved = await dao.getUserById('user-1');
        expect(retrieved, isNotNull);
        expect(retrieved!.id, equals('user-1'));
      });
    });

    group('getCurrentUser', () {
      test('returns null when no current user exists', () async {
        final user = await dao.getCurrentUser();
        expect(user, isNull);
      });

      test('returns the current user', () async {
        await dao.createAnonymousUser(
          id: 'user-1',
          deviceId: 'device-123',
          displayName: 'Current User',
        );

        final current = await dao.getCurrentUser();
        expect(current, isNotNull);
        expect(current!.isCurrent, isTrue);
        expect(current.displayName, equals('Current User'));
      });

      test('returns null when user exists but none is current', () async {
        await dao.createAnonymousUser(
          id: 'user-1',
          deviceId: 'device-123',
          displayName: 'User',
        );
        await dao.clearCurrentUser();

        final current = await dao.getCurrentUser();
        expect(current, isNull);
      });
    });

    group('watchCurrentUser', () {
      test('emits null initially', () async {
        final stream = dao.watchCurrentUser();
        expect(await stream.first, isNull);
      });

      test('emits user when created', () async {
        final stream = dao.watchCurrentUser();

        await dao.createAnonymousUser(
          id: 'user-1',
          deviceId: 'device-123',
          displayName: 'User',
        );

        final user = await stream.first;
        expect(user, isNotNull);
        expect(user!.id, equals('user-1'));
      });
    });

    group('getUserById', () {
      test('returns user when exists', () async {
        await dao.createAnonymousUser(
          id: 'user-1',
          deviceId: 'device-123',
          displayName: 'User',
        );

        final user = await dao.getUserById('user-1');
        expect(user, isNotNull);
        expect(user!.id, equals('user-1'));
      });

      test('returns null when user does not exist', () async {
        final user = await dao.getUserById('non-existent');
        expect(user, isNull);
      });
    });

    group('getUserByRemoteId', () {
      test('returns user when remote ID exists', () async {
        await dao.createAnonymousUser(
          id: 'user-1',
          deviceId: 'device-123',
          displayName: 'User',
        );
        await dao.upgradeToAuthenticated(
          localId: 'user-1',
          remoteId: 'remote-123',
          email: 'test@example.com',
        );

        final user = await dao.getUserByRemoteId('remote-123');
        expect(user, isNotNull);
        expect(user!.remoteId, equals('remote-123'));
      });

      test('returns null when remote ID does not exist', () async {
        final user = await dao.getUserByRemoteId('non-existent');
        expect(user, isNull);
      });
    });

    group('upgradeToAuthenticated', () {
      test('upgrades anonymous user to authenticated', () async {
        await dao.createAnonymousUser(
          id: 'user-1',
          deviceId: 'device-123',
          displayName: 'Anonymous',
        );

        await dao.upgradeToAuthenticated(
          localId: 'user-1',
          remoteId: 'remote-123',
          email: 'test@example.com',
          displayName: 'Authenticated User',
        );

        final user = await dao.getUserById('user-1');
        expect(user!.isAnonymous, isFalse);
        expect(user.remoteId, equals('remote-123'));
        expect(user.email, equals('test@example.com'));
        expect(user.displayName, equals('Authenticated User'));
      });

      test('updates updatedAt timestamp', () async {
        final before = DateTime.now();

        await dao.createAnonymousUser(
          id: 'user-1',
          deviceId: 'device-123',
          displayName: 'Anonymous',
        );

        await Future.delayed(const Duration(milliseconds: 10));

        await dao.upgradeToAuthenticated(
          localId: 'user-1',
          remoteId: 'remote-123',
          email: 'test@example.com',
        );

        final user = await dao.getUserById('user-1');
        expect(
            user!.updatedAt.difference(before).inMilliseconds >= -1000, isTrue);
      });
    });

    group('updateUser', () {
      test('updates specified fields', () async {
        await dao.createAnonymousUser(
          id: 'user-1',
          deviceId: 'device-123',
          displayName: 'Original',
        );

        await dao.updateUser(
          'user-1',
          const UsersCompanion(displayName: Value('Updated')),
        );

        final user = await dao.getUserById('user-1');
        expect(user!.displayName, equals('Updated'));
      });

      test('updates updatedAt timestamp', () async {
        await dao.createAnonymousUser(
          id: 'user-1',
          deviceId: 'device-123',
          displayName: 'Original',
        );

        final before = DateTime.now();
        await Future.delayed(const Duration(milliseconds: 10));

        await dao.updateUser(
          'user-1',
          const UsersCompanion(displayName: Value('Updated')),
        );

        final user = await dao.getUserById('user-1');
        expect(
            user!.updatedAt.difference(before).inMilliseconds >= -1000, isTrue);
      });
    });

    group('clearCurrentUser', () {
      test('clears current flag from all users', () async {
        await dao.createAnonymousUser(
          id: 'user-1',
          deviceId: 'device-123',
          displayName: 'User',
        );

        await dao.clearCurrentUser();

        final user = await dao.getUserById('user-1');
        expect(user!.isCurrent, isFalse);
      });
    });

    group('setCurrentUser', () {
      test('sets specified user as current', () async {
        await dao.createAnonymousUser(
          id: 'user-1',
          deviceId: 'device-123',
          displayName: 'User 1',
        );
        await dao.clearCurrentUser();

        await dao.setCurrentUser('user-1');

        final user = await dao.getUserById('user-1');
        expect(user!.isCurrent, isTrue);
      });

      test('clears current from other users', () async {
        await dao.createAnonymousUser(
          id: 'user-1',
          deviceId: 'device-123',
          displayName: 'User 1',
        );
        await dao.createAnonymousUser(
          id: 'user-2',
          deviceId: 'device-456',
          displayName: 'User 2',
        );

        await dao.setCurrentUser('user-2');

        final user1 = await dao.getUserById('user-1');
        final user2 = await dao.getUserById('user-2');
        expect(user1!.isCurrent, isFalse);
        expect(user2!.isCurrent, isTrue);
      });
    });

    group('getAllUsers', () {
      test('returns empty list when no users', () async {
        final users = await dao.getAllUsers();
        expect(users, isEmpty);
      });

      test('returns all users', () async {
        await dao.createAnonymousUser(
          id: 'user-1',
          deviceId: 'device-123',
          displayName: 'User 1',
        );
        await dao.createAnonymousUser(
          id: 'user-2',
          deviceId: 'device-456',
          displayName: 'User 2',
        );

        final users = await dao.getAllUsers();
        expect(users.length, equals(2));
        expect(users.map((u) => u.id), containsAll(['user-1', 'user-2']));
      });
    });

    group('upsertFromRemote', () {
      test('inserts new user from remote', () async {
        final remoteUser = User(
          id: 'user-1',
          remoteId: 'remote-123',
          email: 'test@example.com',
          displayName: 'Remote User',
          isAnonymous: false,
          isCurrent: false,
          deviceId: null,
          avatarUrl: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await dao.upsertFromRemote(remoteUser);

        final user = await dao.getUserById('user-1');
        expect(user, isNotNull);
        expect(user!.email, equals('test@example.com'));
      });

      test('updates existing user from remote', () async {
        await dao.createAnonymousUser(
          id: 'user-1',
          deviceId: 'device-123',
          displayName: 'Local User',
        );

        final remoteUser = User(
          id: 'user-1',
          remoteId: 'remote-123',
          email: 'updated@example.com',
          displayName: 'Updated User',
          isAnonymous: false,
          isCurrent: false,
          deviceId: null,
          avatarUrl: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await dao.upsertFromRemote(remoteUser);

        final user = await dao.getUserById('user-1');
        expect(user!.email, equals('updated@example.com'));
        expect(user.displayName, equals('Updated User'));
      });
    });
  });
}
