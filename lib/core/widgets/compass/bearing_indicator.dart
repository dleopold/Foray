import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../utils/gps_utils.dart';

/// An arrow indicator showing the direction to a target.
///
/// Rotates relative to the current compass heading to always
/// point toward the target bearing.
class BearingIndicator extends StatelessWidget {
  const BearingIndicator({
    super.key,
    required this.currentHeading,
    required this.targetBearing,
    this.size = 60,
    this.color,
    this.alignedColor,
  });

  /// Current compass heading in degrees (0-360).
  final double currentHeading;

  /// Target bearing in degrees (0-360).
  final double targetBearing;

  /// Size of the indicator.
  final double size;

  /// Color when not aligned.
  final Color? color;

  /// Color when aligned with target (within 10 degrees).
  final Color? alignedColor;

  bool get isAligned => GpsUtils.isAligned(currentHeading, targetBearing);

  @override
  Widget build(BuildContext context) {
    final relativeBearing = GpsUtils.calculateRelativeBearing(
      currentHeading,
      targetBearing,
    );

    final effectiveColor = isAligned
        ? (alignedColor ?? AppColors.success)
        : (color ?? AppColors.primary);

    return AnimatedRotation(
      turns: relativeBearing / 360,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOutCubic,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: effectiveColor.withOpacity(0.2),
          border: Border.all(
            color: effectiveColor,
            width: 3,
          ),
          boxShadow: isAligned
              ? [
                  BoxShadow(
                    color: effectiveColor.withOpacity(0.4),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: CustomPaint(
          painter: _ArrowPainter(color: effectiveColor),
        ),
      ),
    );
  }
}

class _ArrowPainter extends CustomPainter {
  _ArrowPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw arrow pointing up
    final path = Path()
      ..moveTo(center.dx, size.height * 0.15)
      ..lineTo(center.dx - size.width * 0.2, size.height * 0.5)
      ..lineTo(center.dx, size.height * 0.4)
      ..lineTo(center.dx + size.width * 0.2, size.height * 0.5)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ArrowPainter oldDelegate) {
    return color != oldDelegate.color;
  }
}

/// A simple directional arrow without the circular background.
class DirectionalArrow extends StatelessWidget {
  const DirectionalArrow({
    super.key,
    required this.currentHeading,
    required this.targetBearing,
    this.size = 40,
    this.color,
  });

  final double currentHeading;
  final double targetBearing;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final relativeBearing = GpsUtils.calculateRelativeBearing(
      currentHeading,
      targetBearing,
    );
    final isAligned = GpsUtils.isAligned(currentHeading, targetBearing);

    return AnimatedRotation(
      turns: relativeBearing / 360,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOutCubic,
      child: Icon(
        Icons.navigation,
        size: size,
        color: isAligned
            ? AppColors.success
            : (color ?? Theme.of(context).colorScheme.primary),
      ),
    );
  }
}
