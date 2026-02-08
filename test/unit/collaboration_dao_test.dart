import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foray/database/database.dart';
import 'package:foray/database/daos/collaboration_dao.dart';
import 'package:foray/database/tables/comments_table.dart';
import 'package:foray/database/tables/forays_table.dart';
import 'package:foray/database/tables/identifications_table.dart';
import 'package:foray/database/tables/observations_table.dart';

void main() {
  group('CollaborationDao', () {
    late AppDatabase db;
    late CollaborationDao dao;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      dao = db.collaborationDao;
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
    }) async {
      final obs = ObservationsCompanion.insert(
        id: id,
        forayId: forayId,
        collectorId: collectorId,
        latitude: 40.7128,
        longitude: -74.0060,
        privacyLevel: const Value(PrivacyLevel.foray),
        observedAt: DateTime.now(),
      );
      return db.observationsDao.createObservation(obs);
    }

    group('addIdentification', () {
      test('creates identification with correct fields', () async {
        final user = await createTestUser('user-1');
        final foray = await createTestForay('foray-1', user.id);
        final obs = await createTestObservation(
          id: 'obs-1',
          forayId: foray.id,
          collectorId: user.id,
        );

        final id = await dao.addIdentification(
          IdentificationsCompanion.insert(
            id: 'id-1',
            observationId: obs.id,
            identifierId: user.id,
            speciesName: 'Amanita muscaria',
            confidence: const Value(ConfidenceLevel.confident),
          ),
        );

        expect(id.id, equals('id-1'));
        expect(id.observationId, equals(obs.id));
        expect(id.speciesName, equals('Amanita muscaria'));
        expect(id.confidence, equals(ConfidenceLevel.confident));
        expect(id.voteCount, equals(0));
      });
    });

    group('getIdentificationsForObservation', () {
      test('returns identifications sorted by vote count', () async {
        final user = await createTestUser('user-1');
        final foray = await createTestForay('foray-1', user.id);
        final obs = await createTestObservation(
          id: 'obs-1',
          forayId: foray.id,
          collectorId: user.id,
        );

        final id1 = await dao.addIdentification(
          IdentificationsCompanion.insert(
            id: 'id-1',
            observationId: obs.id,
            identifierId: user.id,
            speciesName: 'Species A',
          ),
        );
        final id2 = await dao.addIdentification(
          IdentificationsCompanion.insert(
            id: 'id-2',
            observationId: obs.id,
            identifierId: user.id,
            speciesName: 'Species B',
          ),
        );

        // Add votes to make id2 have more votes
        await dao.addVote(id2.id, user.id);

        final ids = await dao.getIdentificationsForObservation(obs.id);
        expect(ids.length, equals(2));
        expect(ids[0].identification.id, equals(id2.id)); // Higher votes first
        expect(ids[1].identification.id, equals(id1.id));
      });

      test('includes identifier details', () async {
        final user = await createTestUser('user-1');
        final foray = await createTestForay('foray-1', user.id);
        final obs = await createTestObservation(
          id: 'obs-1',
          forayId: foray.id,
          collectorId: user.id,
        );

        await dao.addIdentification(
          IdentificationsCompanion.insert(
            id: 'id-1',
            observationId: obs.id,
            identifierId: user.id,
            speciesName: 'Amanita muscaria',
          ),
        );

        final ids = await dao.getIdentificationsForObservation(obs.id);
        expect(ids.first.identifier, isNotNull);
        expect(ids.first.identifier!.id, equals(user.id));
      });
    });

    group('getIdentificationById', () {
      test('returns identification when exists', () async {
        final user = await createTestUser('user-1');
        final foray = await createTestForay('foray-1', user.id);
        final obs = await createTestObservation(
          id: 'obs-1',
          forayId: foray.id,
          collectorId: user.id,
        );
        await dao.addIdentification(
          IdentificationsCompanion.insert(
            id: 'id-1',
            observationId: obs.id,
            identifierId: user.id,
            speciesName: 'Amanita muscaria',
          ),
        );

        final id = await dao.getIdentificationById('id-1');
        expect(id, isNotNull);
        expect(id!.id, equals('id-1'));
      });

      test('returns null when identification does not exist', () async {
        final id = await dao.getIdentificationById('non-existent');
        expect(id, isNull);
      });
    });

    group('deleteIdentification', () {
      test('deletes identification', () async {
        final user = await createTestUser('user-1');
        final foray = await createTestForay('foray-1', user.id);
        final obs = await createTestObservation(
          id: 'obs-1',
          forayId: foray.id,
          collectorId: user.id,
        );
        await dao.addIdentification(
          IdentificationsCompanion.insert(
            id: 'id-1',
            observationId: obs.id,
            identifierId: user.id,
            speciesName: 'Amanita muscaria',
          ),
        );

        await dao.deleteIdentification('id-1');

        final retrieved = await dao.getIdentificationById('id-1');
        expect(retrieved, isNull);
      });

      test('deletes associated votes', () async {
        final user1 = await createTestUser('user-1');
        final user2 = await createTestUser('user-2');
        final foray = await createTestForay('foray-1', user1.id);
        final obs = await createTestObservation(
          id: 'obs-1',
          forayId: foray.id,
          collectorId: user1.id,
        );
        final id = await dao.addIdentification(
          IdentificationsCompanion.insert(
            id: 'id-1',
            observationId: obs.id,
            identifierId: user1.id,
            speciesName: 'Amanita muscaria',
          ),
        );
        await dao.addVote(id.id, user2.id);

        await dao.deleteIdentification(id.id);

        final voters = await dao.getVotersForIdentification(id.id);
        expect(voters, isEmpty);
      });
    });

    group('addVote', () {
      test('adds vote to identification', () async {
        final user1 = await createTestUser('user-1');
        final user2 = await createTestUser('user-2');
        final foray = await createTestForay('foray-1', user1.id);
        final obs = await createTestObservation(
          id: 'obs-1',
          forayId: foray.id,
          collectorId: user1.id,
        );
        final id = await dao.addIdentification(
          IdentificationsCompanion.insert(
            id: 'id-1',
            observationId: obs.id,
            identifierId: user1.id,
            speciesName: 'Amanita muscaria',
          ),
        );

        await dao.addVote(id.id, user2.id);

        final idWithVotes = await dao.getIdentificationById(id.id);
        expect(idWithVotes!.voteCount, equals(1));
      });

      test('removes previous vote on same observation', () async {
        final user = await createTestUser('user-1');
        final foray = await createTestForay('foray-1', user.id);
        final obs = await createTestObservation(
          id: 'obs-1',
          forayId: foray.id,
          collectorId: user.id,
        );
        final id1 = await dao.addIdentification(
          IdentificationsCompanion.insert(
            id: 'id-1',
            observationId: obs.id,
            identifierId: user.id,
            speciesName: 'Species A',
          ),
        );
        final id2 = await dao.addIdentification(
          IdentificationsCompanion.insert(
            id: 'id-2',
            observationId: obs.id,
            identifierId: user.id,
            speciesName: 'Species B',
          ),
        );

        await dao.addVote(id1.id, user.id);
        await dao.addVote(id2.id, user.id);

        final updatedId1 = await dao.getIdentificationById(id1.id);
        final updatedId2 = await dao.getIdentificationById(id2.id);
        expect(updatedId1!.voteCount, equals(0));
        expect(updatedId2!.voteCount, equals(1));
      });
    });

    group('removeVote', () {
      test('removes vote from identification', () async {
        final user1 = await createTestUser('user-1');
        final user2 = await createTestUser('user-2');
        final foray = await createTestForay('foray-1', user1.id);
        final obs = await createTestObservation(
          id: 'obs-1',
          forayId: foray.id,
          collectorId: user1.id,
        );
        final id = await dao.addIdentification(
          IdentificationsCompanion.insert(
            id: 'id-1',
            observationId: obs.id,
            identifierId: user1.id,
            speciesName: 'Amanita muscaria',
          ),
        );
        await dao.addVote(id.id, user2.id);

        await dao.removeVote(id.id, user2.id);

        final updatedId = await dao.getIdentificationById(id.id);
        expect(updatedId!.voteCount, equals(0));
      });
    });

    group('getUserVoteForObservation', () {
      test('returns identification ID user voted for', () async {
        final user = await createTestUser('user-1');
        final foray = await createTestForay('foray-1', user.id);
        final obs = await createTestObservation(
          id: 'obs-1',
          forayId: foray.id,
          collectorId: user.id,
        );
        final id = await dao.addIdentification(
          IdentificationsCompanion.insert(
            id: 'id-1',
            observationId: obs.id,
            identifierId: user.id,
            speciesName: 'Amanita muscaria',
          ),
        );
        await dao.addVote(id.id, user.id);

        final votedId = await dao.getUserVoteForObservation(obs.id, user.id);
        expect(votedId, equals(id.id));
      });

      test('returns null when user has not voted', () async {
        final user = await createTestUser('user-1');
        final foray = await createTestForay('foray-1', user.id);
        final obs = await createTestObservation(
          id: 'obs-1',
          forayId: foray.id,
          collectorId: user.id,
        );

        final votedId = await dao.getUserVoteForObservation(obs.id, user.id);
        expect(votedId, isNull);
      });
    });

    group('getVotersForIdentification', () {
      test('returns users who voted', () async {
        final user1 = await createTestUser('user-1');
        final user2 = await createTestUser('user-2');
        final foray = await createTestForay('foray-1', user1.id);
        final obs = await createTestObservation(
          id: 'obs-1',
          forayId: foray.id,
          collectorId: user1.id,
        );
        final id = await dao.addIdentification(
          IdentificationsCompanion.insert(
            id: 'id-1',
            observationId: obs.id,
            identifierId: user1.id,
            speciesName: 'Amanita muscaria',
          ),
        );
        await dao.addVote(id.id, user2.id);

        final voters = await dao.getVotersForIdentification(id.id);
        expect(voters.length, equals(1));
        expect(voters.first.id, equals(user2.id));
      });
    });

    group('addComment', () {
      test('creates comment with correct fields', () async {
        final user = await createTestUser('user-1');
        final foray = await createTestForay('foray-1', user.id);
        final obs = await createTestObservation(
          id: 'obs-1',
          forayId: foray.id,
          collectorId: user.id,
        );

        final comment = await dao.addComment(
          CommentsCompanion.insert(
            id: 'comment-1',
            observationId: obs.id,
            authorId: user.id,
            content: 'Great find!',
          ),
        );

        expect(comment.id, equals('comment-1'));
        expect(comment.observationId, equals(obs.id));
        expect(comment.authorId, equals(user.id));
        expect(comment.content, equals('Great find!'));
      });
    });

    group('getCommentsForObservation', () {
      test('returns comments sorted by createdAt', () async {
        final user = await createTestUser('user-1');
        final foray = await createTestForay('foray-1', user.id);
        final obs = await createTestObservation(
          id: 'obs-1',
          forayId: foray.id,
          collectorId: user.id,
        );

        await dao.addComment(
          CommentsCompanion.insert(
            id: 'comment-1',
            observationId: obs.id,
            authorId: user.id,
            content: 'First comment',
          ),
        );
        await Future.delayed(const Duration(milliseconds: 10));
        await dao.addComment(
          CommentsCompanion.insert(
            id: 'comment-2',
            observationId: obs.id,
            authorId: user.id,
            content: 'Second comment',
          ),
        );

        final comments = await dao.getCommentsForObservation(obs.id);
        expect(comments.length, equals(2));
        expect(comments[0].comment.content, equals('First comment'));
        expect(comments[1].comment.content, equals('Second comment'));
      });

      test('includes author details', () async {
        final user = await createTestUser('user-1');
        final foray = await createTestForay('foray-1', user.id);
        final obs = await createTestObservation(
          id: 'obs-1',
          forayId: foray.id,
          collectorId: user.id,
        );

        await dao.addComment(
          CommentsCompanion.insert(
            id: 'comment-1',
            observationId: obs.id,
            authorId: user.id,
            content: 'Great find!',
          ),
        );

        final comments = await dao.getCommentsForObservation(obs.id);
        expect(comments.first.author, isNotNull);
        expect(comments.first.author!.id, equals(user.id));
      });
    });

    group('getCommentById', () {
      test('returns comment when exists', () async {
        final user = await createTestUser('user-1');
        final foray = await createTestForay('foray-1', user.id);
        final obs = await createTestObservation(
          id: 'obs-1',
          forayId: foray.id,
          collectorId: user.id,
        );
        await dao.addComment(
          CommentsCompanion.insert(
            id: 'comment-1',
            observationId: obs.id,
            authorId: user.id,
            content: 'Great find!',
          ),
        );

        final comment = await dao.getCommentById('comment-1');
        expect(comment, isNotNull);
        expect(comment!.id, equals('comment-1'));
      });

      test('returns null when comment does not exist', () async {
        final comment = await dao.getCommentById('non-existent');
        expect(comment, isNull);
      });
    });

    group('deleteComment', () {
      test('deletes comment', () async {
        final user = await createTestUser('user-1');
        final foray = await createTestForay('foray-1', user.id);
        final obs = await createTestObservation(
          id: 'obs-1',
          forayId: foray.id,
          collectorId: user.id,
        );
        await dao.addComment(
          CommentsCompanion.insert(
            id: 'comment-1',
            observationId: obs.id,
            authorId: user.id,
            content: 'Great find!',
          ),
        );

        await dao.deleteComment('comment-1');

        final retrieved = await dao.getCommentById('comment-1');
        expect(retrieved, isNull);
      });
    });

    group('getCommentCount', () {
      test('returns correct count', () async {
        final user = await createTestUser('user-1');
        final foray = await createTestForay('foray-1', user.id);
        final obs = await createTestObservation(
          id: 'obs-1',
          forayId: foray.id,
          collectorId: user.id,
        );

        expect(await dao.getCommentCount(obs.id), equals(0));

        await dao.addComment(
          CommentsCompanion.insert(
            id: 'comment-1',
            observationId: obs.id,
            authorId: user.id,
            content: 'Comment 1',
          ),
        );

        expect(await dao.getCommentCount(obs.id), equals(1));
      });
    });
  });
}
