import 'package:drift/drift.dart';

/// Users table for storing user accounts.
///
/// Supports both anonymous (local-only) users and authenticated Supabase users.
/// The [isCurrent] flag identifies the currently logged-in user.
class Users extends Table {
  /// Local UUID - primary key, client-generated.
  TextColumn get id => text()();

  /// Remote Supabase UUID (null if not synced yet).
  TextColumn get remoteId => text().nullable()();

  /// User display name.
  TextColumn get displayName => text().withLength(min: 1, max: 100)();

  /// Email address (null for anonymous users).
  TextColumn get email => text().nullable()();

  /// Avatar image URL.
  TextColumn get avatarUrl => text().nullable()();

  /// Whether this is an anonymous (local-only) user.
  BoolColumn get isAnonymous => boolean().withDefault(const Constant(true))();

  /// Device ID for anonymous users (used for data migration on account creation).
  TextColumn get deviceId => text().nullable()();

  /// Timestamp when the user was created.
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// Timestamp when the user was last updated.
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  /// Whether this is the currently active user on this device.
  BoolColumn get isCurrent => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
