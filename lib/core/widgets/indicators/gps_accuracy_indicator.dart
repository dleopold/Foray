import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

class GpsAccuracyIndicator extends StatelessWidget {
  const GpsAccuracyIndicator({
    super.key,
    required this.accuracyMeters,
    this.showLabel = true,
  });

  final double? accuracyMeters;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final quality = _getQuality();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: quality.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.gps_fixed,
            size: 16,
            color: quality.color,
          ),
          if (showLabel) ...[
            const SizedBox(width: AppSpacing.xs),
            Text(
              _getLabel(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: quality.color,
              ),
            ),
          ],
        ],
      ),
    );
  }

  _GpsQuality _getQuality() {
    if (accuracyMeters == null) {
      return _GpsQuality.unknown;
    }
    if (accuracyMeters! <= 5) {
      return _GpsQuality.excellent;
    }
    if (accuracyMeters! <= 15) {
      return _GpsQuality.good;
    }
    if (accuracyMeters! <= 30) {
      return _GpsQuality.fair;
    }
    return _GpsQuality.poor;
  }

  String _getLabel() {
    if (accuracyMeters == null) {
      return 'No GPS';
    }
    final quality = _getQuality();
    final meters = accuracyMeters!.round();
    return '${quality.label} (\u00B1${meters}m)';
  }
}

enum _GpsQuality {
  excellent(AppColors.success, 'Excellent'),
  good(AppColors.success, 'Good'),
  fair(AppColors.warning, 'Fair'),
  poor(AppColors.error, 'Poor'),
  unknown(AppColors.syncLocal, 'Unknown');

  const _GpsQuality(this.color, this.label);
  final Color color;
  final String label;
}
