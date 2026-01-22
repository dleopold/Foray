import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/users_table.dart';

part 'users_dao.g.dart';

/// Data Access Object for [Users] table.
///
/// Handles all user-related database operations including
/// anonymous user creation and account upgrades.
@DriftAccessor(tables: [Users])
class UsersDao extends DatabaseAccessor<AppDatabase> with _$UsersDaoMixin {
  UsersDao(super.db);

  /// Get the currently active user on this device.
  Future<User?> getCurrentUser() {
    return (select(users)..where((u) => u.isCurrent.equals(true)))
        .getSingleOrNull();
  }

  /// Watch the current user for changes.
  Stream<User?> watchCurrentUser() {
    return (select(users)..where((u) => u.isCurrent.equals(true)))
        .watchSingleOrNull();
  }

  /// Create a new anonymous user.
  ///
  /// This is called on first app launch when no account exists.
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

  /// Upgrade an anonymous user to an authenticated account.
  ///
  /// Called after successful registration or login.
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
        displayName:
            displayName != null ? Value(displayName) : const Value.absent(),
        avatarUrl: Value(avatarUrl),
        isAnonymous: const Value(false),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Get a user by their local ID.
  Future<User?> getUserById(String id) {
    return (select(users)..where((u) => u.id.equals(id))).getSingleOrNull();
  }

  /// Get a user by their remote (Supabase) ID.
  Future<User?> getUserByRemoteId(String remoteId) {
    return (select(users)..where((u) => u.remoteId.equals(remoteId)))
        .getSingleOrNull();
  }

  /// Update a user's profile.
  Future<void> updateUser(String id, UsersCompanion companion) {
    return (update(users)..where((u) => u.id.equals(id))).write(
      companion.copyWith(updatedAt: Value(DateTime.now())),
    );
  }

  /// Insert or update a user from remote sync.
  Future<void> upsertFromRemote(User user) {
    return into(users).insertOnConflictUpdate(user);
  }

  /// Clear the current user flag from all users.
  Future<void> clearCurrentUser() {
    return (update(users)..where((u) => u.isCurrent.equals(true))).write(
      const UsersCompanion(isCurrent: Value(false)),
    );
  }

  /// Set a specific user as the current user.
  Future<void> setCurrentUser(String id) async {
    await clearCurrentUser();
    await (update(users)..where((u) => u.id.equals(id))).write(
      const UsersCompanion(isCurrent: Value(true)),
    );
  }

  /// Get all users (for debugging/admin).
  Future<List<User>> getAllUsers() {
    return select(users).get();
  }
}
