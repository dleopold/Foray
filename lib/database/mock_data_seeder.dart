import 'package:drift/drift.dart';

import 'database.dart';
import 'tables/forays_table.dart';
import 'tables/observations_table.dart';
import 'tables/photos_table.dart';

/// Seeds the database with mock data for development and testing.
///
/// This class creates a realistic dataset including:
/// - 3 users (Alice, Bob, Carol)
/// - 3 forays (society event, small group hunt, solo)
/// - 5 observations with photos
/// - Sample identifications, votes, and comments
class MockDataSeeder {
  final AppDatabase db;

  MockDataSeeder(this.db);

  /// Check if mock data already exists.
  Future<bool> hasData() async {
    final users = await db.usersDao.getAllUsers();
    return users.isNotEmpty;
  }

  /// Seed all mock data.
  ///
  /// This should only be called in development mode.
  /// Call [hasData] first to avoid duplicate seeding.
  Future<void> seedAll() async {
    await _seedUsers();
    await _seedForays();
    await _seedObservations();
    await _seedIdentifications();
    await _seedComments();
  }

  /// Seed sample users.
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

  /// Seed sample forays.
  Future<void> _seedForays() async {
    // Society foray - large group event
    await db.into(db.forays).insert(
          ForaysCompanion.insert(
            id: 'foray-1',
            creatorId: 'user-1',
            name: 'Pacific Northwest Mycological Society Fall Foray',
            description:
                const Value('Annual fall foray at Mount Rainier area'),
            date: DateTime(2026, 10, 15),
            locationName: const Value('Mount Rainier National Park'),
            defaultPrivacy: const Value(PrivacyLevel.foray),
            joinCode: const Value('PNWMS1'),
            isSolo: const Value(false),
            syncStatus: const Value(SyncStatus.synced),
          ),
        );

    // Small group foray
    await db.into(db.forays).insert(
          ForaysCompanion.insert(
            id: 'foray-2',
            creatorId: 'user-2',
            name: 'Weekend Chanterelle Hunt',
            description: const Value('Looking for golden chanterelles'),
            date: DateTime(2026, 10, 20),
            locationName: const Value('Olympic National Forest'),
            defaultPrivacy: const Value(PrivacyLevel.foray),
            joinCode: const Value('CHAN22'),
            isSolo: const Value(false),
            syncStatus: const Value(SyncStatus.synced),
          ),
        );

    // Solo foray - personal
    await db.into(db.forays).insert(
          ForaysCompanion.insert(
            id: 'foray-3',
            creatorId: 'user-1',
            name: 'My Secret Spots',
            date: DateTime(2026, 1, 1),
            defaultPrivacy: const Value(PrivacyLevel.private),
            isSolo: const Value(true),
            syncStatus: const Value(SyncStatus.local),
          ),
        );

    // Add participants to forays
    // Foray 1: Alice (organizer), Bob, Carol
    await db.into(db.forayParticipants).insert(
          ForayParticipantsCompanion.insert(
            forayId: 'foray-1',
            userId: 'user-1',
            role: const Value(ParticipantRole.organizer),
          ),
        );
    await db.into(db.forayParticipants).insert(
          ForayParticipantsCompanion.insert(
            forayId: 'foray-1',
            userId: 'user-2',
          ),
        );
    await db.into(db.forayParticipants).insert(
          ForayParticipantsCompanion.insert(
            forayId: 'foray-1',
            userId: 'user-3',
          ),
        );

    // Foray 2: Bob (organizer), Alice
    await db.into(db.forayParticipants).insert(
          ForayParticipantsCompanion.insert(
            forayId: 'foray-2',
            userId: 'user-2',
            role: const Value(ParticipantRole.organizer),
          ),
        );
    await db.into(db.forayParticipants).insert(
          ForayParticipantsCompanion.insert(
            forayId: 'foray-2',
            userId: 'user-1',
          ),
        );

    // Foray 3: Alice (solo)
    await db.into(db.forayParticipants).insert(
          ForayParticipantsCompanion.insert(
            forayId: 'foray-3',
            userId: 'user-1',
            role: const Value(ParticipantRole.organizer),
          ),
        );
  }

  /// Seed sample observations.
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
        daysAgo: 5,
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
        daysAgo: 5,
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
        daysAgo: 5,
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
        daysAgo: 2,
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
        daysAgo: 1,
      ),
    ];

    for (final obs in observations) {
      await db.into(db.observations).insert(obs);
    }

    // Add mock photos (pointing to placeholder paths)
    for (var i = 1; i <= 5; i++) {
      await db.into(db.photos).insert(
            PhotosCompanion.insert(
              id: 'photo-$i-1',
              observationId: 'obs-$i',
              localPath: 'assets/images/mock/mushroom_$i.jpg',
              sortOrder: const Value(0),
              uploadStatus: const Value(UploadStatus.uploaded),
            ),
          );

      // Add a second photo to some observations
      if (i <= 3) {
        await db.into(db.photos).insert(
              PhotosCompanion.insert(
                id: 'photo-$i-2',
                observationId: 'obs-$i',
                localPath: 'assets/images/mock/mushroom_${i}_detail.jpg',
                sortOrder: const Value(1),
                caption: const Value('Detail shot'),
                uploadStatus: const Value(UploadStatus.uploaded),
              ),
            );
      }
    }
  }

  /// Helper to create observation companions.
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
    int daysAgo = 0,
  }) {
    return ObservationsCompanion.insert(
      id: id,
      forayId: forayId,
      collectorId: collectorId,
      latitude: lat,
      longitude: lon,
      gpsAccuracy: const Value(5.0),
      altitude: const Value(500.0),
      observedAt: DateTime.now().subtract(Duration(days: daysAgo)),
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

  /// Seed sample identifications and votes.
  Future<void> _seedIdentifications() async {
    // Identification for obs-1: Confirmed chanterelle
    await db.into(db.identifications).insert(
          IdentificationsCompanion.insert(
            id: 'id-1',
            observationId: 'obs-1',
            identifierId: 'user-2',
            speciesName: 'Cantharellus formosus',
            commonName: const Value('Pacific Golden Chanterelle'),
            confidence: const Value(ConfidenceLevel.confident),
            notes: const Value('False gills clearly visible, classic form'),
            voteCount: const Value(2),
            syncStatus: const Value(SyncStatus.synced),
          ),
        );

    // Identification for obs-3: Western fly agaric
    await db.into(db.identifications).insert(
          IdentificationsCompanion.insert(
            id: 'id-2',
            observationId: 'obs-3',
            identifierId: 'user-1',
            speciesName: 'Amanita muscaria var. flavivolvata',
            commonName: const Value('Western Fly Agaric'),
            confidence: const Value(ConfidenceLevel.confident),
            notes: const Value('Western variety has yellow warts'),
            voteCount: const Value(1),
            syncStatus: const Value(SyncStatus.synced),
          ),
        );

    // Alternative ID for obs-3 (shows voting in action)
    await db.into(db.identifications).insert(
          IdentificationsCompanion.insert(
            id: 'id-3',
            observationId: 'obs-3',
            identifierId: 'user-3',
            speciesName: 'Amanita muscaria var. muscaria',
            commonName: const Value('European Fly Agaric'),
            confidence: const Value(ConfidenceLevel.likely),
            notes: const Value('Could be the European variety?'),
            voteCount: const Value(0),
            syncStatus: const Value(SyncStatus.synced),
          ),
        );

    // Add votes
    await db.into(db.identificationVotes).insert(
          IdentificationVotesCompanion.insert(
            identificationId: 'id-1',
            userId: 'user-1',
          ),
        );
    await db.into(db.identificationVotes).insert(
          IdentificationVotesCompanion.insert(
            identificationId: 'id-1',
            userId: 'user-3',
          ),
        );
    await db.into(db.identificationVotes).insert(
          IdentificationVotesCompanion.insert(
            identificationId: 'id-2',
            userId: 'user-2',
          ),
        );
  }

  /// Seed sample comments.
  Future<void> _seedComments() async {
    await db.into(db.comments).insert(
          CommentsCompanion.insert(
            id: 'comment-1',
            observationId: 'obs-1',
            authorId: 'user-3',
            content: 'Beautiful specimen! The false gills are very distinct.',
            syncStatus: const Value(SyncStatus.synced),
          ),
        );

    await db.into(db.comments).insert(
          CommentsCompanion.insert(
            id: 'comment-2',
            observationId: 'obs-2',
            authorId: 'user-1',
            content: 'Great find! How high up on the tree was it?',
            syncStatus: const Value(SyncStatus.synced),
          ),
        );

    await db.into(db.comments).insert(
          CommentsCompanion.insert(
            id: 'comment-3',
            observationId: 'obs-2',
            authorId: 'user-2',
            content: 'About 4 feet up, easy to reach. Still very fresh.',
            syncStatus: const Value(SyncStatus.synced),
          ),
        );

    await db.into(db.comments).insert(
          CommentsCompanion.insert(
            id: 'comment-4',
            observationId: 'obs-3',
            authorId: 'user-2',
            content:
                'Classic! Remember these are toxic - great for photography though.',
            syncStatus: const Value(SyncStatus.synced),
          ),
        );
  }

  /// Clear all mock data.
  ///
  /// This removes all data from all tables.
  Future<void> clearAll() async {
    await db.deleteAllData();
  }
}
