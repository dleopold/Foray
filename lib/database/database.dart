import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

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
        // Enable foreign key constraints.
        // CRITICAL: Without this, foreign key references are not enforced!
        await customStatement('PRAGMA foreign_keys = ON');

        if (kDebugMode) {
          // Verify foreign keys are enabled
          final result = await customSelect('PRAGMA foreign_keys').getSingle();
          assert(
            result.data['foreign_keys'] == 1,
            'Foreign keys should be enabled',
          );
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
/// On mobile/desktop, creates a file-based database in the app's documents directory.
/// The database is created in a background isolate for better performance.
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'foray.db'));

    if (kDebugMode) {
      // ignore: avoid_print
      print('Database path: ${file.path}');
    }

    return NativeDatabase.createInBackground(file);
  });
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
