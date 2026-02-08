import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../utils/gps_utils.dart';

/// Displays the distance to a target with animated feedback.
///
/// Shows a pulse animation when the user is getting closer,
/// and changes color based on proximity.
class DistanceDisplay extends StatefulWidget {
  const DistanceDisplay({
    super.key,
    required this.distanceMeters,
    this.useMetric = true,
    this.previousDistance,
    this.showTrend = true,
  });

  /// Current distance in meters.
  final double distanceMeters;

  /// Whether to use metric units (meters/km) or imperial (feet/miles).
  final bool useMetric;

  /// Previous distance for trend detection.
  final double? previousDistance;

  /// Whether to show the "getting closer" indicator.
  final bool showTrend;

  @override
  State<DistanceDisplay> createState() => _DistanceDisplayState();
}

class _DistanceDisplayState extends State<DistanceDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  bool get isGettingCloser =>
      widget.previousDistance != null &&
      widget.distanceMeters < widget.previousDistance! - 1; // 1m threshold

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(DistanceDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (isGettingCloser && !_pulseController.isAnimating) {
      _pulseController.forward().then((_) => _pulseController.reverse());
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color _getDistanceColor() {
    if (widget.distanceMeters < 10) {
      return AppColors.success;
    } else if (widget.distanceMeters < 50) {
      return AppColors.warning;
    }
    return Theme.of(context).textTheme.headlineLarge?.color ?? Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    final formattedDistance = GpsUtils.formatDistanceSmart(
      widget.distanceMeters,
      useMetric: widget.useMetric,
    );

    return ScaleTransition(
      scale: _pulseAnimation,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _getDistanceColor(),
                ),
            child: Text(formattedDistance),
          ),
          if (widget.showTrend && isGettingCloser) ...[
            const SizedBox(height: AppSpacing.xs),
            _buildTrendIndicator(),
          ],
        ],
      ),
    );
  }

  Widget _buildTrendIndicator() {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isGettingCloser ? 1.0 : 0.0,
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.arrow_downward,
            size: 16,
            color: AppColors.success,
          ),
          SizedBox(width: AppSpacing.xs),
          Text(
            'Getting closer',
            style: TextStyle(
              color: AppColors.success,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

/// A compact distance display for use in lists or cards.
class CompactDistanceDisplay extends StatelessWidget {
  const CompactDistanceDisplay({
    super.key,
    required this.distanceMeters,
    this.useMetric = true,
    this.style,
  });

  final double distanceMeters;
  final bool useMetric;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final formattedDistance = GpsUtils.formatDistance(
      distanceMeters,
      useMetric: useMetric,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.straighten,
          size: 16,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          formattedDistance,
          style: style ?? Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
