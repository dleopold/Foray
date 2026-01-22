import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/forays_table.dart';
import '../tables/users_table.dart';

part 'forays_dao.g.dart';

/// Data Access Object for [Forays] and [ForayParticipants] tables.
///
/// Handles foray CRUD operations, participant management,
/// and status updates.
@DriftAccessor(tables: [Forays, ForayParticipants, Users])
class ForaysDao extends DatabaseAccessor<AppDatabase> with _$ForaysDaoMixin {
  ForaysDao(super.db);

  // =========================================================================
  // Foray CRUD
  // =========================================================================

  /// Create a new foray.
  Future<Foray> createForay(ForaysCompanion foray) async {
    await into(forays).insert(foray);
    return (select(forays)..where((f) => f.id.equals(foray.id.value)))
        .getSingle();
  }

  /// Get a foray by its local ID.
  Future<Foray?> getForayById(String id) {
    return (select(forays)..where((f) => f.id.equals(id))).getSingleOrNull();
  }

  /// Get a foray by its join code.
  Future<Foray?> getForayByJoinCode(String code) {
    return (select(forays)
          ..where((f) => f.joinCode.equals(code.toUpperCase())))
        .getSingleOrNull();
  }

  /// Get all forays a user participates in.
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

  /// Watch all forays for a user with real-time updates.
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

  /// Update a foray.
  Future<void> updateForay(String id, ForaysCompanion companion) {
    return (update(forays)..where((f) => f.id.equals(id))).write(
      companion.copyWith(updatedAt: Value(DateTime.now())),
    );
  }

  /// Delete a foray and all its participants.
  Future<void> deleteForay(String id) async {
    await (delete(forayParticipants)..where((p) => p.forayId.equals(id))).go();
    await (delete(forays)..where((f) => f.id.equals(id))).go();
  }

  // =========================================================================
  // Status Management
  // =========================================================================

  /// Update foray status (active/completed).
  Future<void> updateForayStatus(String id, ForayStatus status) {
    return (update(forays)..where((f) => f.id.equals(id))).write(
      ForaysCompanion(
        status: Value(status),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Set whether observations are locked.
  Future<void> setObservationsLocked(String id, bool locked) {
    return (update(forays)..where((f) => f.id.equals(id))).write(
      ForaysCompanion(
        observationsLocked: Value(locked),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // =========================================================================
  // Participant Management
  // =========================================================================

  /// Add a participant to a foray.
  Future<void> addParticipant({
    required String forayId,
    required String userId,
    ParticipantRole role = ParticipantRole.participant,
  }) {
    return into(forayParticipants).insert(
      ForayParticipantsCompanion.insert(
        forayId: forayId,
        userId: userId,
        role: Value(role),
      ),
    );
  }

  /// Remove a participant from a foray.
  Future<void> removeParticipant(String forayId, String userId) {
    return (delete(forayParticipants)
          ..where((p) => p.forayId.equals(forayId) & p.userId.equals(userId)))
        .go();
  }

  /// Get all participants for a foray with user details.
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

  /// Watch participants for real-time updates.
  Stream<List<ParticipantWithUser>> watchParticipants(String forayId) {
    final query = select(forayParticipants).join([
      innerJoin(users, users.id.equalsExp(forayParticipants.userId)),
    ])
      ..where(forayParticipants.forayId.equals(forayId));

    return query.watch().map((rows) {
      return rows.map((row) {
        return ParticipantWithUser(
          participant: row.readTable(forayParticipants),
          user: row.readTable(users),
        );
      }).toList();
    });
  }

  /// Check if a user is a participant in a foray.
  Future<bool> isParticipant(String forayId, String userId) async {
    final result = await (select(forayParticipants)
          ..where((p) => p.forayId.equals(forayId) & p.userId.equals(userId)))
        .getSingleOrNull();
    return result != null;
  }

  /// Get a user's role in a foray.
  Future<ParticipantRole?> getUserRole(String forayId, String userId) async {
    final result = await (select(forayParticipants)
          ..where((p) => p.forayId.equals(forayId) & p.userId.equals(userId)))
        .getSingleOrNull();
    return result?.role;
  }

  // =========================================================================
  // Sync Operations
  // =========================================================================

  /// Get forays pending sync.
  Future<List<Foray>> getForaysPendingSync() {
    return (select(forays)..where((f) => f.syncStatus.equals('pending'))).get();
  }

  /// Update sync status for a foray.
  Future<void> updateSyncStatus(String id, SyncStatus status,
      {String? remoteId}) {
    return (update(forays)..where((f) => f.id.equals(id))).write(
      ForaysCompanion(
        syncStatus: Value(status),
        remoteId: remoteId != null ? Value(remoteId) : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}

// ============================================================================
// Helper Classes
// ============================================================================

/// A foray with the current user's role.
class ForayWithRole {
  final Foray foray;
  final ParticipantRole role;

  ForayWithRole({required this.foray, required this.role});

  bool get isOrganizer => role == ParticipantRole.organizer;
}

/// A participant with their user details.
class ParticipantWithUser {
  final ForayParticipant participant;
  final User user;

  ParticipantWithUser({required this.participant, required this.user});

  bool get isOrganizer => participant.role == ParticipantRole.organizer;
}
