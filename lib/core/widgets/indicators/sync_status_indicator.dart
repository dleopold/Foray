import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

enum SyncStatus { local, pending, synced, failed }

class SyncStatusIndicator extends StatelessWidget {
  const SyncStatusIndicator({
    super.key,
    required this.status,
    this.showLabel = false,
    this.size = 16,
  });

  final SyncStatus status;
  final bool showLabel;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildIcon(),
        if (showLabel) ...[
          const SizedBox(width: AppSpacing.xs),
          Text(
            _getLabel(),
            style: TextStyle(
              fontSize: 12,
              color: _getColor(),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildIcon() {
    if (status == SyncStatus.pending) {
      return SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: _getColor(),
        ),
      );
    }
    return Icon(
      _getIcon(),
      size: size,
      color: _getColor(),
    );
  }

  IconData _getIcon() {
    switch (status) {
      case SyncStatus.local:
        return Icons.smartphone;
      case SyncStatus.pending:
        return Icons.sync;
      case SyncStatus.synced:
        return Icons.cloud_done;
      case SyncStatus.failed:
        return Icons.cloud_off;
    }
  }

  Color _getColor() {
    switch (status) {
      case SyncStatus.local:
        return AppColors.syncLocal;
      case SyncStatus.pending:
        return AppColors.syncPending;
      case SyncStatus.synced:
        return AppColors.syncSynced;
      case SyncStatus.failed:
        return AppColors.syncFailed;
    }
  }

  String _getLabel() {
    switch (status) {
      case SyncStatus.local:
        return 'Local only';
      case SyncStatus.pending:
        return 'Syncing...';
      case SyncStatus.synced:
        return 'Synced';
      case SyncStatus.failed:
        return 'Sync failed';
    }
  }
}
