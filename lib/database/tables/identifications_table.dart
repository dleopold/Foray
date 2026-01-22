import 'package:drift/drift.dart';

import 'forays_table.dart';
import 'observations_table.dart';
import 'users_table.dart';

// ============================================================================
// Tables
// ============================================================================

/// Identifications table - species IDs proposed for observations.
///
/// Multiple users can propose IDs, which are then voted on.
/// The [voteCount] is denormalized for efficient sorting.
class Identifications extends Table {
  /// Local UUID - client-generated.
  TextColumn get id => text()();

  /// Remote UUID (null until synced).
  TextColumn get remoteId => text().nullable()();

  /// Foreign key to the observation being identified.
  TextColumn get observationId => text().references(Observations, #id)();

  /// Foreign key to the user who made this identification.
  TextColumn get identifierId => text().references(Users, #id)();

  /// Scientific species name.
  TextColumn get speciesName => text()();

  /// Common name (optional).
  TextColumn get commonName => text().nullable()();

  /// Confidence level in this identification.
  TextColumn get confidence => text()
      .map(const ConfidenceLevelConverter())
      .withDefault(const Constant('likely'))();

  /// Optional notes explaining the reasoning.
  TextColumn get notes => text().nullable()();

  /// Denormalized vote count for efficient sorting.
  IntColumn get voteCount => integer().withDefault(const Constant(0))();

  /// Timestamp when created.
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// Sync status.
  TextColumn get syncStatus => text()
      .map(const SyncStatusConverter())
      .withDefault(const Constant('local'))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Votes on identifications.
///
/// Each user can vote for one ID per observation.
/// Composite primary key ensures one vote per user per identification.
class IdentificationVotes extends Table {
  /// Foreign key to the identification being voted on.
  TextColumn get identificationId => text().references(Identifications, #id)();

  /// Foreign key to the voting user.
  TextColumn get userId => text().references(Users, #id)();

  /// Timestamp when the vote was cast.
  DateTimeColumn get votedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {identificationId, userId};
}
