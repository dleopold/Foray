import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../services/sync/sync_queue_processor.dart';

class SyncStatusBanner extends ConsumerWidget {
  const SyncStatusBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(syncStatusProvider);

    return statusAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (status) {
        if (status.state == SyncProcessorState.idle && !status.hasPending) {
          return const SizedBox.shrink();
        }

        return _buildBanner(context, ref, status);
      },
    );
  }

  Widget _buildBanner(BuildContext context, WidgetRef ref, SyncProcessorStatus status) {
    final (color, icon, message) = switch (status.state) {
      SyncProcessorState.syncing => (
        AppColors.syncPending,
        const _SyncingIcon(),
        '${status.pendingCount} item${status.pendingCount != 1 ? 's' : ''} syncing...',
      ),
      SyncProcessorState.offline => (
        Colors.grey,
        const Icon(Icons.cloud_off, size: 16),
        'Offline - changes saved locally',
      ),
      SyncProcessorState.error => (
        AppColors.error,
        const Icon(Icons.error_outline, size: 16),
        '${status.failedCount} item${status.failedCount != 1 ? 's' : ''} failed to sync',
      ),
      SyncProcessorState.idle => (
        AppColors.syncPending,
        const Icon(Icons.cloud_queue, size: 16),
        '${status.pendingCount} item${status.pendingCount != 1 ? 's' : ''} waiting to sync',
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      color: color.withOpacity(0.15),
      child: Row(
        children: [
          icon,
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(message)),
          if (status.state != SyncProcessorState.syncing)
            TextButton(
              onPressed: () {
                ref.read(syncQueueProcessorProvider).processQueue();
              },
              child: Text(
                status.isOffline ? 'Retry' : 'Sync Now',
              ),
            ),
        ],
      ),
    );
  }
}

class _SyncingIcon extends StatefulWidget {
  const _SyncingIcon();

  @override
  State<_SyncingIcon> createState() => _SyncingIconState();
}

class _SyncingIconState extends State<_SyncingIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: const Icon(Icons.sync, size: 16),
    );
  }
}
