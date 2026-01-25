import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config/platform_config.dart';
import 'mock_data_seeder.dart';

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

/// Main application database using Drift.
///
/// This database serves as the local SQLite storage for the Foray app.
/// It supports offline-first operation with a sync queue for eventual
/// synchronization with Supabase.
@DriftDatabase(
  tables: [
    // User management
    Users,
    // Foray management
    Forays,
    ForayParticipants,
    // Observations
    Observations,
    Photos,
    // Collaboration
    Identifications,
    IdentificationVotes,
    Comments,
    // Sync
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
  /// Create database with default native connection.
  AppDatabase() : super(_openConnection());

  /// Create database with a specific query executor (for testing).
  AppDatabase.forTesting(super.e);

  /// Database schema version.
  ///
  /// Increment this when making schema changes and add migration logic.
  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Add migration logic here when schema changes.
        // Example:
        // if (from < 2) {
        //   await m.addColumn(observations, observations.newColumn);
        // }
      },
      beforeOpen: (details) async {
        if (kDebugMode) {
          debugPrint('Database beforeOpen: wasCreated=${details.wasCreated}, '
              'hadUpgrade=${details.hadUpgrade}, isWeb=${PlatformConfig.isWeb}');
        }

        // Enable foreign key constraints (not supported on web/IndexedDB)
        if (!PlatformConfig.isWeb) {
          await customStatement('PRAGMA foreign_keys = ON');

          if (kDebugMode) {
            final result = await customSelect('PRAGMA foreign_keys').getSingle();
            assert(
              result.data['foreign_keys'] == 1,
              'Foreign keys should be enabled',
            );
          }
        }

        // Seed demo data on web for first launch
        if (DemoConfig.preSeedData && details.wasCreated) {
          if (kDebugMode) {
            debugPrint('Seeding demo data for web...');
          }
          final seeder = MockDataSeeder(this);
          await seeder.seedAll();
          if (kDebugMode) {
            debugPrint('Demo data seeded for web');
          }
        }

        if (kDebugMode) {
          debugPrint('Database initialization complete');
        }
      },
    );
  }

  /// Delete all data from all tables.
  ///
  /// Use with caution! This is primarily for testing and development.
  Future<void> deleteAllData() async {
    await transaction(() async {
      // Delete in order to respect foreign key constraints
      await delete(syncQueue).go();
      await delete(comments).go();
      await delete(identificationVotes).go();
      await delete(identifications).go();
      await delete(photos).go();
      await delete(observations).go();
      await delete(forayParticipants).go();
      await delete(forays).go();
      await delete(users).go();
    });
  }
}

/// Opens the database connection.
///
/// Uses drift_flutter which automatically handles:
/// - Native platforms (iOS, Android, macOS, Linux, Windows): SQLite file
/// - Web: WebAssembly SQLite with IndexedDB persistence
QueryExecutor _openConnection() {
  return driftDatabase(
    name: 'foray',
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse('sqlite3.wasm'),
      driftWorker: Uri.parse('drift_worker.js'),
      onResult: (result) {
        if (kDebugMode && result.missingFeatures.isNotEmpty) {
          debugPrint('Drift web: Using ${result.chosenImplementation} '
              'due to missing features: ${result.missingFeatures}');
        }
      },
    ),
  );
}

// =============================================================================
// Riverpod Providers
// =============================================================================

/// Provides the main database instance.
///
/// The database is created once and disposed when the provider is disposed.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

/// Provides the UsersDao.
final usersDaoProvider = Provider<UsersDao>((ref) {
  return ref.watch(databaseProvider).usersDao;
});

/// Provides the ForaysDao.
final foraysDaoProvider = Provider<ForaysDao>((ref) {
  return ref.watch(databaseProvider).foraysDao;
});

/// Provides the ObservationsDao.
final observationsDaoProvider = Provider<ObservationsDao>((ref) {
  return ref.watch(databaseProvider).observationsDao;
});

/// Provides the CollaborationDao.
final collaborationDaoProvider = Provider<CollaborationDao>((ref) {
  return ref.watch(databaseProvider).collaborationDao;
});

/// Provides the SyncDao.
final syncDaoProvider = Provider<SyncDao>((ref) {
  return ref.watch(databaseProvider).syncDao;
});
