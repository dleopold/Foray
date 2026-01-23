import 'dart:math';

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// An animated compass rose widget.
///
/// Rotates smoothly based on the current heading, showing cardinal
/// directions (N, E, S, W) and tick marks.
class CompassRose extends StatelessWidget {
  const CompassRose({
    super.key,
    required this.heading,
    this.size = 250,
    this.ringColor,
    this.cardinalColor,
    this.needleColor,
    this.showDegrees = false,
  });

  /// Current compass heading in degrees (0-360).
  final double heading;

  /// Size of the compass rose.
  final double size;

  /// Color of the outer ring and tick marks.
  final Color? ringColor;

  /// Color of the cardinal direction letters.
  final Color? cardinalColor;

  /// Color of the north indicator.
  final Color? needleColor;

  /// Whether to show degree numbers.
  final bool showDegrees;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: AnimatedRotation(
        turns: -heading / 360,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        child: CustomPaint(
          size: Size(size, size),
          painter: _CompassRosePainter(
            ringColor: ringColor ?? Theme.of(context).colorScheme.outline,
            cardinalColor:
                cardinalColor ?? Theme.of(context).colorScheme.onSurface,
            needleColor: needleColor ?? AppColors.primary,
            showDegrees: showDegrees,
          ),
        ),
      ),
    );
  }
}

class _CompassRosePainter extends CustomPainter {
  _CompassRosePainter({
    required this.ringColor,
    required this.cardinalColor,
    required this.needleColor,
    required this.showDegrees,
  });

  final Color ringColor;
  final Color cardinalColor;
  final Color needleColor;
  final bool showDegrees;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw outer ring
    final ringPaint = Paint()
      ..color = ringColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, radius - 10, ringPaint);

    // Draw inner ring
    final innerRingPaint = Paint()
      ..color = ringColor.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, radius - 35, innerRingPaint);

    // Draw tick marks
    final tickPaint = Paint()
      ..color = ringColor
      ..strokeWidth = 2;

    for (var i = 0; i < 360; i += 10) {
      final isCardinal = i % 90 == 0;
      final isMajor = i % 30 == 0;

      final startRadius = radius - (isCardinal ? 30 : (isMajor ? 25 : 20));
      final endRadius = radius - 10;

      final angle = i * pi / 180;
      final start = Offset(
        center.dx + startRadius * sin(angle),
        center.dy - startRadius * cos(angle),
      );
      final end = Offset(
        center.dx + endRadius * sin(angle),
        center.dy - endRadius * cos(angle),
      );

      tickPaint.strokeWidth = isCardinal ? 3 : (isMajor ? 2 : 1);
      tickPaint.color = isCardinal ? cardinalColor : ringColor;
      canvas.drawLine(start, end, tickPaint);
    }

    // Draw cardinal directions
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    final cardinals = {'N': 0.0, 'E': 90.0, 'S': 180.0, 'W': 270.0};
    cardinals.forEach((label, degrees) {
      final isNorth = label == 'N';
      textPainter.text = TextSpan(
        text: label,
        style: TextStyle(
          color: isNorth ? needleColor : cardinalColor,
          fontSize: isNorth ? 24 : 18,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();

      final angle = degrees * pi / 180;
      final textRadius = radius - 50;
      final offset = Offset(
        center.dx + textRadius * sin(angle) - textPainter.width / 2,
        center.dy - textRadius * cos(angle) - textPainter.height / 2,
      );
      textPainter.paint(canvas, offset);
    });

    // Draw north indicator (red triangle at top)
    final northPaint = Paint()
      ..color = needleColor
      ..style = PaintingStyle.fill;

    final northPath = Path()
      ..moveTo(center.dx, center.dy - radius + 5)
      ..lineTo(center.dx - 8, center.dy - radius + 20)
      ..lineTo(center.dx + 8, center.dy - radius + 20)
      ..close();
    canvas.drawPath(northPath, northPaint);

    // Draw center dot
    final centerPaint = Paint()
      ..color = cardinalColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 4, centerPaint);
  }

  @override
  bool shouldRepaint(covariant _CompassRosePainter oldDelegate) {
    return ringColor != oldDelegate.ringColor ||
        cardinalColor != oldDelegate.cardinalColor ||
        needleColor != oldDelegate.needleColor ||
        showDegrees != oldDelegate.showDegrees;
  }
}
