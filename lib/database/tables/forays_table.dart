import 'package:drift/drift.dart';

import 'users_table.dart';

// ============================================================================
// Enums and Type Converters
// ============================================================================

/// Privacy levels for observations and forays.
enum PrivacyLevel {
  /// Only the creator can see.
  private,

  /// Visible to foray participants.
  foray,

  /// Public with exact location.
  publicExact,

  /// Public with obscured location (~10km).
  publicObscured,
}

/// Converter for [PrivacyLevel] to/from database string.
class PrivacyLevelConverter extends TypeConverter<PrivacyLevel, String> {
  const PrivacyLevelConverter();

  @override
  PrivacyLevel fromSql(String fromDb) {
    return PrivacyLevel.values.firstWhere((e) => e.name == fromDb);
  }

  @override
  String toSql(PrivacyLevel value) => value.name;
}

/// Status of a foray.
enum ForayStatus {
  /// Foray is active and accepting observations.
  active,

  /// Foray has been completed.
  completed,
}

/// Converter for [ForayStatus] to/from database string.
class ForayStatusConverter extends TypeConverter<ForayStatus, String> {
  const ForayStatusConverter();

  @override
  ForayStatus fromSql(String fromDb) {
    return ForayStatus.values.firstWhere((e) => e.name == fromDb);
  }

  @override
  String toSql(ForayStatus value) => value.name;
}

/// Sync status for entities.
enum SyncStatus {
  /// Only exists locally, not yet synced.
  local,

  /// Queued for sync.
  pending,

  /// Successfully synced to remote.
  synced,

  /// Sync failed (will retry).
  failed,
}

/// Converter for [SyncStatus] to/from database string.
class SyncStatusConverter extends TypeConverter<SyncStatus, String> {
  const SyncStatusConverter();

  @override
  SyncStatus fromSql(String fromDb) {
    return SyncStatus.values.firstWhere((e) => e.name == fromDb);
  }

  @override
  String toSql(SyncStatus value) => value.name;
}

/// Participant role in a foray.
enum ParticipantRole {
  /// Creator/organizer with full permissions.
  organizer,

  /// Regular participant.
  participant,
}

/// Converter for [ParticipantRole] to/from database string.
class ParticipantRoleConverter extends TypeConverter<ParticipantRole, String> {
  const ParticipantRoleConverter();

  @override
  ParticipantRole fromSql(String fromDb) {
    return ParticipantRole.values.firstWhere((e) => e.name == fromDb);
  }

  @override
  String toSql(ParticipantRole value) => value.name;
}

// ============================================================================
// Tables
// ============================================================================

/// Forays table - represents a collection event or expedition.
///
/// A foray can be solo (personal) or group (with participants).
/// Group forays have a join code for easy sharing.
class Forays extends Table {
  /// Local UUID - client-generated.
  TextColumn get id => text()();

  /// Remote Supabase UUID (null until synced).
  TextColumn get remoteId => text().nullable()();

  /// Creator/organizer user ID.
  TextColumn get creatorId => text().references(Users, #id)();

  /// Name of the foray.
  TextColumn get name => text().withLength(min: 1, max: 200)();

  /// Optional description.
  TextColumn get description => text().nullable()();

  /// Date of the foray.
  DateTimeColumn get date => dateTime()();

  /// Human-readable location name.
  TextColumn get locationName => text().nullable()();

  /// Default privacy level for observations in this foray.
  TextColumn get defaultPrivacy => text()
      .map(const PrivacyLevelConverter())
      .withDefault(const Constant('private'))();

  /// 6-character join code for group forays.
  TextColumn get joinCode => text().withLength(min: 6, max: 6).nullable()();

  /// Current status of the foray.
  TextColumn get status => text()
      .map(const ForayStatusConverter())
      .withDefault(const Constant('active'))();

  /// Whether this is a solo (personal) foray.
  BoolColumn get isSolo => boolean().withDefault(const Constant(false))();

  /// Whether new observations/edits are locked.
  BoolColumn get observationsLocked =>
      boolean().withDefault(const Constant(false))();

  /// Timestamp when created.
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// Timestamp when last updated.
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  /// Sync status.
  TextColumn get syncStatus => text()
      .map(const SyncStatusConverter())
      .withDefault(const Constant('local'))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Junction table linking forays to their participants.
class ForayParticipants extends Table {
  /// Foreign key to foray.
  TextColumn get forayId => text().references(Forays, #id)();

  /// Foreign key to user.
  TextColumn get userId => text().references(Users, #id)();

  /// Role of this participant.
  TextColumn get role => text()
      .map(const ParticipantRoleConverter())
      .withDefault(const Constant('participant'))();

  /// When the user joined this foray.
  DateTimeColumn get joinedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {forayId, userId};
}
