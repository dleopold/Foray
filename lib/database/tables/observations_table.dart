import 'package:drift/drift.dart';

import 'forays_table.dart';
import 'users_table.dart';

// ============================================================================
// Enums and Type Converters
// ============================================================================

/// Confidence level for species identifications.
enum ConfidenceLevel {
  /// A guess, not confident.
  guess,

  /// Probably correct.
  likely,

  /// Very confident in the identification.
  confident,
}

/// Converter for [ConfidenceLevel] to/from database string.
class ConfidenceLevelConverter extends TypeConverter<ConfidenceLevel, String> {
  const ConfidenceLevelConverter();

  @override
  ConfidenceLevel fromSql(String fromDb) {
    return ConfidenceLevel.values.firstWhere((e) => e.name == fromDb);
  }

  @override
  String toSql(ConfidenceLevel value) => value.name;
}

// ============================================================================
// Tables
// ============================================================================

/// Observations table - a single fungal find/collection.
///
/// Core data entity containing location, field notes, and metadata.
/// Photos are stored separately and linked via [observationId].
class Observations extends Table {
  /// Local UUID - client-generated.
  TextColumn get id => text()();

  /// Remote Supabase UUID (null until synced).
  TextColumn get remoteId => text().nullable()();

  /// Foreign key to parent foray.
  TextColumn get forayId => text().references(Forays, #id)();

  /// Foreign key to collector/creator.
  TextColumn get collectorId => text().references(Users, #id)();

  // Location data
  /// Latitude in decimal degrees.
  RealColumn get latitude => real()();

  /// Longitude in decimal degrees.
  RealColumn get longitude => real()();

  /// GPS accuracy in meters (null if unknown).
  RealColumn get gpsAccuracy => real().nullable()();

  /// Altitude in meters (null if unavailable).
  RealColumn get altitude => real().nullable()();

  /// Privacy level for this observation.
  TextColumn get privacyLevel => text()
      .map(const PrivacyLevelConverter())
      .withDefault(const Constant('private'))();

  // Timestamps
  /// When the observation was made in the field.
  DateTimeColumn get observedAt => dateTime()();

  /// When the record was created.
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// When the record was last updated.
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  // Specimen tracking
  /// Physical specimen ID (for lookup by barcode/QR).
  TextColumn get specimenId => text().nullable()();

  /// Collection number within the foray.
  TextColumn get collectionNumber => text().nullable()();

  // Field data
  /// Substrate type (wood, soil, etc.).
  TextColumn get substrate => text().nullable()();

  /// Habitat/environment notes.
  TextColumn get habitatNotes => text().nullable()();

  /// General field notes.
  TextColumn get fieldNotes => text().nullable()();

  /// Spore print color if taken.
  TextColumn get sporePrintColor => text().nullable()();

  // Preliminary identification by collector
  /// Species name suggested by collector.
  TextColumn get preliminaryId => text().nullable()();

  /// Confidence in preliminary ID.
  TextColumn get preliminaryIdConfidence =>
      text().map(const ConfidenceLevelConverter()).nullable()();

  /// Whether this is a draft (not yet submitted).
  BoolColumn get isDraft => boolean().withDefault(const Constant(true))();

  /// Sync status.
  TextColumn get syncStatus => text()
      .map(const SyncStatusConverter())
      .withDefault(const Constant('local'))();

  /// Last time the user viewed this observation (for "updated" indicator).
  DateTimeColumn get lastViewedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
