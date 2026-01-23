import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/comments_table.dart';
import '../tables/forays_table.dart';
import '../tables/identifications_table.dart';
import '../tables/users_table.dart';

part 'collaboration_dao.g.dart';

/// Data Access Object for collaboration features.
///
/// Handles identifications, voting, and comments on observations.
@DriftAccessor(tables: [Identifications, IdentificationVotes, Comments, Users])
class CollaborationDao extends DatabaseAccessor<AppDatabase>
    with _$CollaborationDaoMixin {
  CollaborationDao(super.db);

  // =========================================================================
  // Identifications
  // =========================================================================

  /// Add a new identification to an observation.
  Future<Identification> addIdentification(
      IdentificationsCompanion id) async {
    await into(identifications).insert(id);
    return (select(identifications)..where((i) => i.id.equals(id.id.value)))
        .getSingle();
  }

  /// Get all identifications for an observation with identifier details.
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

  /// Watch identifications for real-time updates.
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

  /// Get an identification by ID.
  Future<Identification?> getIdentificationById(String id) {
    return (select(identifications)..where((i) => i.id.equals(id)))
        .getSingleOrNull();
  }

  /// Delete an identification and its votes.
  Future<void> deleteIdentification(String id) async {
    await (delete(identificationVotes)
          ..where((v) => v.identificationId.equals(id)))
        .go();
    await (delete(identifications)..where((i) => i.id.equals(id))).go();
  }

  /// Update sync status for an identification.
  Future<void> updateIdentificationSyncStatus(String id, SyncStatus status) {
    return (update(identifications)..where((i) => i.id.equals(id))).write(
      IdentificationsCompanion(syncStatus: Value(status)),
    );
  }

  // =========================================================================
  // Voting
  // =========================================================================

  /// Add a vote for an identification.
  ///
  /// Enforces one vote per user per observation by removing any existing
  /// vote on other IDs for the same observation.
  Future<void> addVote(String identificationId, String userId) async {
    // Get the identification to find its observation
    final identification = await (select(identifications)
          ..where((i) => i.id.equals(identificationId)))
        .getSingle();

    // Get all IDs for this observation
    final allIds = await (select(identifications)
          ..where((i) => i.observationId.equals(identification.observationId)))
        .get();

    // Remove any existing votes from this user on this observation's IDs
    for (final id in allIds) {
      await (delete(identificationVotes)
            ..where((v) =>
                v.identificationId.equals(id.id) & v.userId.equals(userId)))
          .go();
      await _updateVoteCount(id.id);
    }

    // Add the new vote
    await into(identificationVotes).insert(
      IdentificationVotesCompanion.insert(
        identificationId: identificationId,
        userId: userId,
      ),
    );
    await _updateVoteCount(identificationId);
  }

  /// Remove a vote from an identification.
  Future<void> removeVote(String identificationId, String userId) async {
    await (delete(identificationVotes)
          ..where((v) =>
              v.identificationId.equals(identificationId) &
              v.userId.equals(userId)))
        .go();
    await _updateVoteCount(identificationId);
  }

  /// Get which identification a user has voted for in an observation.
  Future<String?> getUserVoteForObservation(
      String observationId, String userId) async {
    final allIds = await (select(identifications)
          ..where((i) => i.observationId.equals(observationId)))
        .get();

    for (final id in allIds) {
      final vote = await (select(identificationVotes)
            ..where((v) =>
                v.identificationId.equals(id.id) & v.userId.equals(userId)))
          .getSingleOrNull();
      if (vote != null) {
        return id.id;
      }
    }
    return null;
  }

  /// Get all voters for an identification.
  Future<List<User>> getVotersForIdentification(
      String identificationId) async {
    final query = select(identificationVotes).join([
      innerJoin(users, users.id.equalsExp(identificationVotes.userId)),
    ])
      ..where(identificationVotes.identificationId.equals(identificationId));

    final results = await query.get();
    return results.map((row) => row.readTable(users)).toList();
  }

  /// Update the denormalized vote count for an identification.
  Future<void> _updateVoteCount(String identificationId) async {
    final count = await (select(identificationVotes)
          ..where((v) => v.identificationId.equals(identificationId)))
        .get();
    await (update(identifications)
          ..where((i) => i.id.equals(identificationId)))
        .write(
      IdentificationsCompanion(voteCount: Value(count.length)),
    );
  }

  // =========================================================================
  // Comments
  // =========================================================================

  /// Add a comment to an observation.
  Future<Comment> addComment(CommentsCompanion comment) async {
    await into(comments).insert(comment);
    return (select(comments)..where((c) => c.id.equals(comment.id.value)))
        .getSingle();
  }

  /// Get all comments for an observation with author details.
  Future<List<CommentWithAuthor>> getCommentsForObservation(
      String observationId) async {
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

  /// Watch comments for real-time updates.
  Stream<List<CommentWithAuthor>> watchCommentsForObservation(
      String observationId) {
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

  /// Get a comment by ID.
  Future<Comment?> getCommentById(String id) {
    return (select(comments)..where((c) => c.id.equals(id))).getSingleOrNull();
  }

  /// Delete a comment.
  Future<void> deleteComment(String id) {
    return (delete(comments)..where((c) => c.id.equals(id))).go();
  }

  /// Update sync status for a comment.
  Future<void> updateCommentSyncStatus(String id, SyncStatus status) {
    return (update(comments)..where((c) => c.id.equals(id))).write(
      CommentsCompanion(syncStatus: Value(status)),
    );
  }

  /// Get comment count for an observation.
  Future<int> getCommentCount(String observationId) async {
    final count = countAll();
    final query = selectOnly(comments)
      ..addColumns([count])
      ..where(comments.observationId.equals(observationId));
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }
}

// ============================================================================
// Helper Classes
// ============================================================================

/// An identification with identifier details.
class IdentificationWithDetails {
  final Identification identification;
  final User? identifier;

  IdentificationWithDetails({
    required this.identification,
    this.identifier,
  });
}

/// A comment with author details.
class CommentWithAuthor {
  final Comment comment;
  final User? author;

  CommentWithAuthor({
    required this.comment,
    this.author,
  });
}
