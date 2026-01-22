import 'package:drift/drift.dart';

// ============================================================================
// Enums and Type Converters
// ============================================================================

/// Type of sync operation.
enum SyncOperation {
  /// Create new entity on remote.
  create,

  /// Update existing entity on remote.
  update,

  /// Delete entity from remote.
  delete,
}

/// Converter for [SyncOperation] to/from database string.
class SyncOperationConverter extends TypeConverter<SyncOperation, String> {
  const SyncOperationConverter();

  @override
  SyncOperation fromSql(String fromDb) {
    return SyncOperation.values.firstWhere((e) => e.name == fromDb);
  }

  @override
  String toSql(SyncOperation value) => value.name;
}

/// Status of a sync queue item.
enum SyncQueueStatus {
  /// Waiting to be processed.
  pending,

  /// Currently being processed.
  processing,

  /// Successfully completed.
  completed,

  /// Failed (may retry).
  failed,
}

/// Converter for [SyncQueueStatus] to/from database string.
class SyncQueueStatusConverter extends TypeConverter<SyncQueueStatus, String> {
  const SyncQueueStatusConverter();

  @override
  SyncQueueStatus fromSql(String fromDb) {
    return SyncQueueStatus.values.firstWhere((e) => e.name == fromDb);
  }

  @override
  String toSql(SyncQueueStatus value) => value.name;
}

// ============================================================================
// Tables
// ============================================================================

/// Sync queue table - tracks pending sync operations.
///
/// Operations are processed FIFO (by auto-increment [id]).
/// Failed operations are retried with exponential backoff.
class SyncQueue extends Table {
  /// Auto-increment ID for FIFO ordering.
  IntColumn get id => integer().autoIncrement()();

  /// Type of entity being synced (foray, observation, identification, etc.).
  TextColumn get entityType => text()();

  /// Local ID of the entity.
  TextColumn get entityId => text()();

  /// Type of operation (create, update, delete).
  TextColumn get operation => text().map(const SyncOperationConverter())();

  /// Optional JSON payload with additional data.
  TextColumn get payload => text().nullable()();

  /// Current processing status.
  TextColumn get status => text()
      .map(const SyncQueueStatusConverter())
      .withDefault(const Constant('pending'))();

  /// Number of retry attempts.
  IntColumn get retryCount => integer().withDefault(const Constant(0))();

  /// Timestamp of last sync attempt.
  DateTimeColumn get lastAttempt => dateTime().nullable()();

  /// Error message from last failed attempt.
  TextColumn get lastError => text().nullable()();

  /// Timestamp when queued.
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
