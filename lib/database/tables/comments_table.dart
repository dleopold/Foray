import 'package:drift/drift.dart';

import 'forays_table.dart';
import 'observations_table.dart';
import 'users_table.dart';

// ============================================================================
// Tables
// ============================================================================

/// Comments table - discussion threads on observations.
///
/// Simple flat comment structure (no threading/replies).
/// Comments are ordered by [createdAt] timestamp.
class Comments extends Table {
  /// Local UUID - client-generated.
  TextColumn get id => text()();

  /// Remote UUID (null until synced).
  TextColumn get remoteId => text().nullable()();

  /// Foreign key to the observation being discussed.
  TextColumn get observationId => text().references(Observations, #id)();

  /// Foreign key to the comment author.
  TextColumn get authorId => text().references(Users, #id)();

  /// Comment content (1-2000 characters).
  TextColumn get content => text().withLength(min: 1, max: 2000)();

  /// Timestamp when created.
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// Sync status.
  TextColumn get syncStatus => text()
      .map(const SyncStatusConverter())
      .withDefault(const Constant('local'))();

  @override
  Set<Column> get primaryKey => {id};
}
