import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/sync_queue_table.dart';

part 'sync_dao.g.dart';

/// Data Access Object for the sync queue.
///
/// Manages the offline sync queue for background synchronization.
@DriftAccessor(tables: [SyncQueue])
class SyncDao extends DatabaseAccessor<AppDatabase> with _$SyncDaoMixin {
  SyncDao(super.db);

  // =========================================================================
  // Queue Management
  // =========================================================================

  /// Add an item to the sync queue.
  Future<void> enqueue({
    required String entityType,
    required String entityId,
    required SyncOperation operation,
    String? payload,
  }) {
    return into(syncQueue).insert(
      SyncQueueCompanion.insert(
        entityType: entityType,
        entityId: entityId,
        operation: operation,
        payload: Value(payload),
      ),
    );
  }

  /// Get pending items to process.
  Future<List<SyncQueueData>> getPendingItems({int limit = 50}) {
    return (select(syncQueue)
          ..where((q) => q.status.equals('pending'))
          ..orderBy([(q) => OrderingTerm.asc(q.id)])
          ..limit(limit))
        .get();
  }

  /// Get failed items that are eligible for retry.
  Future<List<SyncQueueData>> getFailedItemsForRetry({int maxRetries = 3}) {
    return (select(syncQueue)
          ..where((q) =>
              q.status.equals('failed') &
              q.retryCount.isSmallerThanValue(maxRetries))
          ..orderBy([(q) => OrderingTerm.asc(q.lastAttempt)]))
        .get();
  }

  // =========================================================================
  // Status Updates
  // =========================================================================

  /// Mark an item as currently processing.
  Future<void> markProcessing(int id) {
    return (update(syncQueue)..where((q) => q.id.equals(id))).write(
      SyncQueueCompanion(
        status: const Value(SyncQueueStatus.processing),
        lastAttempt: Value(DateTime.now()),
      ),
    );
  }

  /// Mark an item as successfully completed.
  Future<void> markCompleted(int id) {
    return (update(syncQueue)..where((q) => q.id.equals(id))).write(
      const SyncQueueCompanion(status: Value(SyncQueueStatus.completed)),
    );
  }

  /// Mark an item as failed.
  Future<void> markFailed(int id, String error) async {
    final item =
        await (select(syncQueue)..where((q) => q.id.equals(id))).getSingle();
    await (update(syncQueue)..where((q) => q.id.equals(id))).write(
      SyncQueueCompanion(
        status: const Value(SyncQueueStatus.failed),
        retryCount: Value(item.retryCount + 1),
        lastError: Value(error),
      ),
    );
  }

  /// Reset a failed item to pending for retry.
  Future<void> resetToPending(int id) {
    return (update(syncQueue)..where((q) => q.id.equals(id))).write(
      const SyncQueueCompanion(status: Value(SyncQueueStatus.pending)),
    );
  }

  // =========================================================================
  // Cleanup
  // =========================================================================

  /// Delete all completed items.
  Future<void> deleteCompleted() {
    return (delete(syncQueue)..where((q) => q.status.equals('completed'))).go();
  }

  /// Delete items older than a certain age.
  Future<void> deleteOlderThan(Duration age) {
    final cutoff = DateTime.now().subtract(age);
    return (delete(syncQueue)
          ..where((q) =>
              q.status.equals('completed') & q.createdAt.isSmallerThanValue(cutoff)))
        .go();
  }

  // =========================================================================
  // Statistics
  // =========================================================================

  /// Get count of items by status.
  Future<int> getCountByStatus(SyncQueueStatus status) async {
    final count = countAll();
    final query = selectOnly(syncQueue)
      ..addColumns([count])
      ..where(syncQueue.status.equals(status.name));
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  /// Watch pending item count for UI updates.
  Stream<int> watchPendingCount() {
    final count = countAll();
    final query = selectOnly(syncQueue)
      ..addColumns([count])
      ..where(syncQueue.status.equals('pending'));
    return query.watchSingle().map((row) => row.read(count) ?? 0);
  }

  /// Get total queue statistics.
  Future<SyncQueueStats> getStats() async {
    final pending = await getCountByStatus(SyncQueueStatus.pending);
    final processing = await getCountByStatus(SyncQueueStatus.processing);
    final failed = await getCountByStatus(SyncQueueStatus.failed);
    final completed = await getCountByStatus(SyncQueueStatus.completed);
    return SyncQueueStats(
      pending: pending,
      processing: processing,
      failed: failed,
      completed: completed,
    );
  }

  // =========================================================================
  // Deduplication
  // =========================================================================

  /// Remove duplicate pending entries for the same entity/operation.
  ///
  /// Keeps only the most recent entry for each unique combination.
  Future<void> deduplicateQueue() async {
    await customStatement('''
      DELETE FROM sync_queue 
      WHERE id NOT IN (
        SELECT MAX(id) 
        FROM sync_queue 
        WHERE status = 'pending'
        GROUP BY entity_type, entity_id, operation
      ) AND status = 'pending'
    ''');
  }

  /// Check if an entity has pending sync operations.
  Future<bool> hasPendingSync(String entityType, String entityId) async {
    final result = await (select(syncQueue)
          ..where((q) =>
              q.entityType.equals(entityType) &
              q.entityId.equals(entityId) &
              q.status.isIn(['pending', 'processing'])))
        .getSingleOrNull();
    return result != null;
  }
}

// ============================================================================
// Helper Classes
// ============================================================================

/// Statistics about the sync queue.
class SyncQueueStats {
  final int pending;
  final int processing;
  final int failed;
  final int completed;

  SyncQueueStats({
    required this.pending,
    required this.processing,
    required this.failed,
    required this.completed,
  });

  int get total => pending + processing + failed + completed;
  bool get hasWork => pending > 0 || processing > 0;
  bool get hasFailures => failed > 0;
}
