import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../database/database.dart';
import 'sync_service.dart';

final syncQueueProcessorProvider = Provider<SyncQueueProcessor>((ref) {
  final processor = SyncQueueProcessor(
    ref.watch(databaseProvider),
    ref.watch(syncServiceProvider),
  );
  ref.onDispose(() => processor.stop());
  return processor;
});

final syncStatusProvider = StreamProvider<SyncProcessorStatus>((ref) {
  final processor = ref.watch(syncQueueProcessorProvider);
  return processor.statusStream;
});

class SyncQueueProcessor {
  SyncQueueProcessor(this._db, this._syncService);

  final AppDatabase _db;
  final SyncService _syncService;
  
  Timer? _processingTimer;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  bool _isProcessing = false;
  bool _isRunning = false;

  final _statusController = StreamController<SyncProcessorStatus>.broadcast();
  Stream<SyncProcessorStatus> get statusStream => _statusController.stream;

  void start() {
    if (_isRunning) return;
    _isRunning = true;

    _processingTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => processQueue(),
    );

    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        processQueue();
      }
    });

    processQueue();
  }

  void stop() {
    _isRunning = false;
    _processingTimer?.cancel();
    _processingTimer = null;
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }

  Future<void> processQueue() async {
    if (_isProcessing) return;
    _isProcessing = true;
    _emitStatus(SyncProcessorState.syncing);

    try {
      final connectivity = await Connectivity().checkConnectivity();
      if (connectivity == ConnectivityResult.none) {
        _emitStatus(SyncProcessorState.offline);
        return;
      }

      final pendingItems = await _db.syncDao.getPendingItems(limit: 10);
      
      for (final item in pendingItems) {
        await _processItem(item);
      }

      final failedItems = await _db.syncDao.getFailedItemsForRetry(
        maxRetries: AppConstants.syncRetryMaxAttempts,
      );
      
      for (final item in failedItems) {
        final backoffDelay = _calculateBackoff(item.retryCount);
        if (item.lastAttempt != null) {
          final timeSinceLastAttempt = DateTime.now().difference(item.lastAttempt!);
          if (timeSinceLastAttempt < backoffDelay) continue;
        }
        await _processItem(item);
      }

      await _db.syncDao.deleteCompleted();

      final stats = await _db.syncDao.getStats();
      if (stats.hasWork) {
        _emitStatus(SyncProcessorState.syncing, pendingCount: stats.pending);
      } else if (stats.hasFailures) {
        _emitStatus(SyncProcessorState.error, failedCount: stats.failed);
      } else {
        _emitStatus(SyncProcessorState.idle);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Sync error: $e');
      _emitStatus(SyncProcessorState.error);
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> _processItem(SyncQueueData item) async {
    await _db.syncDao.markProcessing(item.id);

    try {
      switch (item.entityType) {
        case 'observation':
          await _syncService.pushObservation(item.entityId);
        case 'foray':
          await _syncService.pushForay(item.entityId);
        case 'identification':
          await _syncService.pushIdentification(item.entityId);
        case 'comment':
          await _syncService.pushComment(item.entityId);
        default:
          if (kDebugMode) debugPrint('Unknown entity type: ${item.entityType}');
      }
      await _db.syncDao.markCompleted(item.id);
    } catch (e) {
      await _db.syncDao.markFailed(item.id, e.toString());
    }
  }

  Duration _calculateBackoff(int retryCount) {
    final multiplier = 1 << retryCount;
    return AppConstants.syncRetryBaseDelay * multiplier;
  }

  void _emitStatus(SyncProcessorState state, {int pendingCount = 0, int failedCount = 0}) {
    _statusController.add(SyncProcessorStatus(
      state: state,
      pendingCount: pendingCount,
      failedCount: failedCount,
      lastSync: DateTime.now(),
    ),);
  }

  void dispose() {
    stop();
    _statusController.close();
  }
}

enum SyncProcessorState {
  idle,
  syncing,
  offline,
  error,
}

class SyncProcessorStatus {
  const SyncProcessorStatus({
    required this.state,
    this.pendingCount = 0,
    this.failedCount = 0,
    this.lastSync,
  });

  final SyncProcessorState state;
  final int pendingCount;
  final int failedCount;
  final DateTime? lastSync;

  bool get isSyncing => state == SyncProcessorState.syncing;
  bool get isOffline => state == SyncProcessorState.offline;
  bool get hasError => state == SyncProcessorState.error;
  bool get hasPending => pendingCount > 0;
}
