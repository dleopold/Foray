import 'package:drift/drift.dart';

import 'observations_table.dart';

// ============================================================================
// Enums and Type Converters
// ============================================================================

/// Upload status for photos.
enum UploadStatus {
  /// Not yet uploaded.
  pending,

  /// Currently uploading.
  uploading,

  /// Successfully uploaded.
  uploaded,

  /// Upload failed (will retry).
  failed,
}

/// Converter for [UploadStatus] to/from database string.
class UploadStatusConverter extends TypeConverter<UploadStatus, String> {
  const UploadStatusConverter();

  @override
  UploadStatus fromSql(String fromDb) {
    return UploadStatus.values.firstWhere((e) => e.name == fromDb);
  }

  @override
  String toSql(UploadStatus value) => value.name;
}

// ============================================================================
// Tables
// ============================================================================

/// Photos table - images attached to observations.
///
/// Stores both local file path and remote URL (after upload).
/// Photos are ordered by [sortOrder] for display.
class Photos extends Table {
  /// Local UUID - client-generated.
  TextColumn get id => text()();

  /// Remote UUID (null until uploaded).
  TextColumn get remoteId => text().nullable()();

  /// Foreign key to parent observation.
  TextColumn get observationId => text().references(Observations, #id)();

  /// Local file system path to the image.
  TextColumn get localPath => text()();

  /// Remote storage URL (populated after upload).
  TextColumn get remoteUrl => text().nullable()();

  /// Display order (0 = primary/first photo).
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  /// Optional caption for the photo.
  TextColumn get caption => text().nullable()();

  /// Upload status.
  TextColumn get uploadStatus => text()
      .map(const UploadStatusConverter())
      .withDefault(const Constant('pending'))();

  /// Timestamp when created.
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
