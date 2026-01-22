# Specification: Compass Navigation

**Phase:** 7  
**Estimated Duration:** 4-5 days  
**Dependencies:** Phase 5 complete

---

## 1. Compass Service

### 1.1 Compass Service Implementation

```dart
// lib/services/compass/compass_service.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final compassServiceProvider = Provider<CompassService>((ref) {
  return CompassService();
});

final compassHeadingProvider = StreamProvider<double?>((ref) {
  final service = ref.watch(compassServiceProvider);
  return service.headingStream;
});

class CompassService {
  StreamSubscription<CompassEvent>? _subscription;
  final _headingController = StreamController<double?>.broadcast();
  
  // Smoothing parameters
  static const int _smoothingWindow = 5;
  final List<double> _headingBuffer = [];

  Stream<double?> get headingStream => _headingController.stream;

  bool _isAvailable = false;
  bool get isAvailable => _isAvailable;

  Future<bool> checkAvailability() async {
    _isAvailable = await FlutterCompass.events != null;
    return _isAvailable;
  }

  void startListening() {
    _subscription?.cancel();
    _subscription = FlutterCompass.events?.listen(
      (event) {
        if (event.heading != null) {
          _addHeadingToBuffer(event.heading!);
          _headingController.add(_getSmoothedHeading());
        }
      },
      onError: (error) {
        _headingController.addError(error);
      },
    );
  }

  void _addHeadingToBuffer(double heading) {
    _headingBuffer.add(heading);
    if (_headingBuffer.length > _smoothingWindow) {
      _headingBuffer.removeAt(0);
    }
  }

  double _getSmoothedHeading() {
    if (_headingBuffer.isEmpty) return 0;
    if (_headingBuffer.length == 1) return _headingBuffer.first;

    // Use circular mean for heading smoothing
    double sumSin = 0;
    double sumCos = 0;

    for (final heading in _headingBuffer) {
      final rad = heading * pi / 180;
      sumSin += sin(rad);
      sumCos += cos(rad);
    }

    final avgRad = atan2(sumSin, sumCos);
    var avgDeg = avgRad * 180 / pi;
    if (avgDeg < 0) avgDeg += 360;
    
    return avgDeg;
  }

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }

  void dispose() {
    stopListening();
    _headingController.close();
  }
}
```

---

## 2. GPS Utilities

### 2.1 GPS Calculation Utils

```dart
// lib/core/utils/gps_utils.dart
import 'dart:math';

abstract class GpsUtils {
  /// Calculates the great-circle distance between two points using Haversine formula
  /// Returns distance in meters
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadius = 6371000.0; // meters

    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  /// Calculates the initial bearing from point 1 to point 2
  /// Returns bearing in degrees (0-360)
  static double calculateBearing(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final dLon = _toRadians(lon2 - lon1);
    final lat1Rad = _toRadians(lat1);
    final lat2Rad = _toRadians(lat2);

    final y = sin(dLon) * cos(lat2Rad);
    final x = cos(lat1Rad) * sin(lat2Rad) -
        sin(lat1Rad) * cos(lat2Rad) * cos(dLon);

    var bearing = atan2(y, x) * 180 / pi;
    bearing = (bearing + 360) % 360;

    return bearing;
  }

  /// Calculates the relative bearing from current heading to target bearing
  /// Returns angle in degrees (-180 to 180)
  static double calculateRelativeBearing(
    double currentHeading,
    double targetBearing,
  ) {
    var relative = targetBearing - currentHeading;
    
    // Normalize to -180 to 180
    while (relative > 180) {
      relative -= 360;
    }
    while (relative < -180) {
      relative += 360;
    }
    
    return relative;
  }

  /// Returns true if heading is within tolerance of target bearing
  static bool isAligned(
    double currentHeading,
    double targetBearing, {
    double tolerance = 10,
  }) {
    final relative = calculateRelativeBearing(currentHeading, targetBearing).abs();
    return relative <= tolerance;
  }

  /// Formats bearing as cardinal direction
  static String bearingToCardinal(double bearing) {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final index = ((bearing + 22.5) / 45).floor() % 8;
    return directions[index];
  }

  /// Formats bearing with cardinal and degrees
  static String formatBearing(double bearing) {
    return '${bearingToCardinal(bearing)} (${bearing.round()}°)';
  }

  /// Formats distance with appropriate units
  static String formatDistance(double meters, {bool useMetric = true}) {
    if (useMetric) {
      if (meters < 1000) {
        return '${meters.round()} m';
      }
      return '${(meters / 1000).toStringAsFixed(1)} km';
    } else {
      final feet = meters * 3.28084;
      if (feet < 5280) {
        return '${feet.round()} ft';
      }
      final miles = feet / 5280;
      return '${miles.toStringAsFixed(1)} mi';
    }
  }

  static double _toRadians(double degrees) => degrees * pi / 180;
}
```

### 2.2 Unit Tests

```dart
// test/unit/gps_utils_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:foray/core/utils/gps_utils.dart';

void main() {
  group('GpsUtils', () {
    test('calculateDistance returns correct distance', () {
      // Seattle to Portland ~280 km
      final distance = GpsUtils.calculateDistance(
        47.6062, -122.3321, // Seattle
        45.5152, -122.6784, // Portland
      );
      expect(distance, closeTo(280000, 5000)); // within 5km
    });

    test('calculateBearing returns correct bearing', () {
      // Heading south
      final bearing = GpsUtils.calculateBearing(
        47.6062, -122.3321, // Seattle
        45.5152, -122.6784, // Portland
      );
      expect(bearing, closeTo(180, 10)); // roughly south
    });

    test('calculateRelativeBearing normalizes correctly', () {
      expect(GpsUtils.calculateRelativeBearing(0, 90), equals(90));
      expect(GpsUtils.calculateRelativeBearing(350, 10), closeTo(20, 0.1));
      expect(GpsUtils.calculateRelativeBearing(10, 350), closeTo(-20, 0.1));
    });

    test('isAligned returns true within tolerance', () {
      expect(GpsUtils.isAligned(0, 5), isTrue);
      expect(GpsUtils.isAligned(0, 15), isFalse);
      expect(GpsUtils.isAligned(355, 5), isTrue);
    });

    test('bearingToCardinal returns correct direction', () {
      expect(GpsUtils.bearingToCardinal(0), equals('N'));
      expect(GpsUtils.bearingToCardinal(90), equals('E'));
      expect(GpsUtils.bearingToCardinal(180), equals('S'));
      expect(GpsUtils.bearingToCardinal(270), equals('W'));
      expect(GpsUtils.bearingToCardinal(45), equals('NE'));
    });
  });
}
```

---

## 3. Compass Rose Component

### 3.1 Animated Compass Rose

```dart
// lib/core/widgets/compass/compass_rose.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:foray/core/theme/app_colors.dart';

class CompassRose extends StatelessWidget {
  const CompassRose({
    super.key,
    required this.heading,
    this.size = 250,
    this.ringColor,
    this.cardinalColor,
    this.needleColor,
  });

  final double heading;
  final double size;
  final Color? ringColor;
  final Color? cardinalColor;
  final Color? needleColor;

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
            cardinalColor: cardinalColor ?? Theme.of(context).colorScheme.onSurface,
            needleColor: needleColor ?? AppColors.primary,
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
  });

  final Color ringColor;
  final Color cardinalColor;
  final Color needleColor;

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
  }

  @override
  bool shouldRepaint(covariant _CompassRosePainter oldDelegate) {
    return ringColor != oldDelegate.ringColor ||
        cardinalColor != oldDelegate.cardinalColor ||
        needleColor != oldDelegate.needleColor;
  }
}
```

---

## 4. Bearing Indicator Component

### 4.1 Target Direction Arrow

```dart
// lib/core/widgets/compass/bearing_indicator.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:foray/core/theme/app_colors.dart';
import 'package:foray/core/utils/gps_utils.dart';

class BearingIndicator extends StatelessWidget {
  const BearingIndicator({
    super.key,
    required this.currentHeading,
    required this.targetBearing,
    this.size = 60,
    this.color,
    this.alignedColor,
  });

  final double currentHeading;
  final double targetBearing;
  final double size;
  final Color? color;
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
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: effectiveColor.withOpacity(0.2),
          border: Border.all(
            color: effectiveColor,
            width: 3,
          ),
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
```

---

## 5. Distance Display Component

### 5.1 Animated Distance Readout

```dart
// lib/core/widgets/compass/distance_display.dart
import 'package:flutter/material.dart';
import 'package:foray/core/theme/app_colors.dart';
import 'package:foray/core/theme/app_spacing.dart';
import 'package:foray/core/utils/gps_utils.dart';

class DistanceDisplay extends StatefulWidget {
  const DistanceDisplay({
    super.key,
    required this.distanceMeters,
    required this.useMetric,
    this.previousDistance,
  });

  final double distanceMeters;
  final bool useMetric;
  final double? previousDistance;

  @override
  State<DistanceDisplay> createState() => _DistanceDisplayState();
}

class _DistanceDisplayState extends State<DistanceDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  bool get isGettingCloser =>
      widget.previousDistance != null &&
      widget.distanceMeters < widget.previousDistance!;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(DistanceDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (isGettingCloser) {
      _pulseController.forward().then((_) => _pulseController.reverse());
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formattedDistance = GpsUtils.formatDistance(
      widget.distanceMeters,
      useMetric: widget.useMetric,
    );

    return ScaleTransition(
      scale: _pulseAnimation,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            formattedDistance,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: _getDistanceColor(),
            ),
          ),
          if (isGettingCloser)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.arrow_downward,
                  size: 16,
                  color: AppColors.success,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Getting closer',
                  style: TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Color _getDistanceColor() {
    if (widget.distanceMeters < 10) {
      return AppColors.success;
    } else if (widget.distanceMeters < 50) {
      return AppColors.warning;
    }
    return Theme.of(context).textTheme.headlineLarge?.color ?? Colors.black;
  }
}
```

---

## 6. Navigation Screen

### 6.1 Compass Navigation Screen

```dart
// lib/features/navigation/presentation/screens/compass_navigation_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:foray/core/theme/app_spacing.dart';
import 'package:foray/core/theme/app_colors.dart';
import 'package:foray/core/utils/gps_utils.dart';
import 'package:foray/core/widgets/compass/compass_rose.dart';
import 'package:foray/core/widgets/compass/bearing_indicator.dart';
import 'package:foray/core/widgets/compass/distance_display.dart';
import 'package:foray/core/widgets/indicators/gps_accuracy_indicator.dart';
import 'package:foray/core/constants/app_constants.dart';
import 'package:foray/database/database.dart';
import 'package:foray/services/compass/compass_service.dart';
import 'package:foray/services/location/location_service.dart';
import 'package:foray/features/navigation/presentation/widgets/arrival_celebration.dart';

class CompassNavigationScreen extends ConsumerStatefulWidget {
  const CompassNavigationScreen({
    super.key,
    required this.observationId,
  });

  final String observationId;

  @override
  ConsumerState<CompassNavigationScreen> createState() => _CompassNavigationScreenState();
}

class _CompassNavigationScreenState extends ConsumerState<CompassNavigationScreen> {
  Observation? _targetObservation;
  Position? _currentPosition;
  double? _previousDistance;
  double? _currentDistance;
  double? _targetBearing;
  double? _currentHeading;
  bool _hasArrived = false;
  bool _showCalibrationPrompt = false;
  String? _error;

  StreamSubscription<Position>? _positionSubscription;
  StreamSubscription<double?>? _headingSubscription;

  @override
  void initState() {
    super.initState();
    _loadObservation();
    _startTracking();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _headingSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadObservation() async {
    final db = ref.read(databaseProvider);
    final observation = await db.observationsDao.getObservationById(widget.observationId);
    setState(() => _targetObservation = observation);
  }

  void _startTracking() {
    // Start compass
    final compassService = ref.read(compassServiceProvider);
    compassService.startListening();
    _headingSubscription = compassService.headingStream.listen((heading) {
      setState(() => _currentHeading = heading);
    });

    // Start GPS tracking
    final locationService = ref.read(locationServiceProvider);
    _positionSubscription = locationService.getPositionStream().listen((position) {
      _updatePosition(position);
    });
  }

  void _updatePosition(Position position) {
    if (_targetObservation == null) return;

    final distance = GpsUtils.calculateDistance(
      position.latitude,
      position.longitude,
      _targetObservation!.latitude,
      _targetObservation!.longitude,
    );

    final bearing = GpsUtils.calculateBearing(
      position.latitude,
      position.longitude,
      _targetObservation!.latitude,
      _targetObservation!.longitude,
    );

    setState(() {
      _previousDistance = _currentDistance;
      _currentDistance = distance;
      _targetBearing = bearing;
      _currentPosition = position;
      
      // Check for arrival
      if (distance <= AppConstants.arrivalThresholdMeters && !_hasArrived) {
        _triggerArrival();
      }
    });
  }

  void _triggerArrival() {
    setState(() => _hasArrived = true);
    HapticFeedback.heavyImpact();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ArrivalCelebration(
        observation: _targetObservation!,
        onDismiss: () {
          Navigator.pop(context);
          setState(() => _hasArrived = false);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_targetObservation == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Navigate'),
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: _openInMaps,
            tooltip: 'Open in Maps',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            children: [
              // GPS accuracy indicator
              if (_currentPosition != null)
                GPSAccuracyIndicator(accuracyMeters: _currentPosition!.accuracy),
              
              const Spacer(),
              
              // Compass and bearing indicator
              if (_currentHeading != null && _targetBearing != null)
                Stack(
                  alignment: Alignment.center,
                  children: [
                    CompassRose(
                      heading: _currentHeading!,
                      size: 280,
                    ),
                    BearingIndicator(
                      currentHeading: _currentHeading!,
                      targetBearing: _targetBearing!,
                      size: 80,
                    ),
                  ],
                )
              else
                _buildLoadingCompass(),
              
              const SizedBox(height: AppSpacing.xl),
              
              // Distance display
              if (_currentDistance != null)
                DistanceDisplay(
                  distanceMeters: _currentDistance!,
                  useMetric: true, // TODO: Get from user preferences
                  previousDistance: _previousDistance,
                ),
              
              const SizedBox(height: AppSpacing.md),
              
              // Bearing text
              if (_targetBearing != null)
                Text(
                  GpsUtils.formatBearing(_targetBearing!),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              
              const Spacer(),
              
              // Target observation info
              _buildTargetInfo(),
              
              const SizedBox(height: AppSpacing.lg),
              
              // Open in maps button
              if (_currentDistance != null && 
                  _currentDistance! > AppConstants.farDistanceThresholdKm * 1000)
                OutlinedButton.icon(
                  onPressed: _openInMaps,
                  icon: const Icon(Icons.directions),
                  label: const Text('Get Directions'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingCompass() {
    return Container(
      width: 280,
      height: 280,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          width: 3,
        ),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildTargetInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: const Icon(
                Icons.eco,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _targetObservation!.preliminaryId ?? 'Unknown species',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  Text(
                    'Collected ${_targetObservation!.observedAt.toString().split(' ')[0]}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openInMaps() async {
    if (_targetObservation == null) return;

    final lat = _targetObservation!.latitude;
    final lon = _targetObservation!.longitude;
    
    // Try Google Maps first, fall back to Apple Maps
    final googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lon',
    );
    final appleMapsUrl = Uri.parse(
      'https://maps.apple.com/?daddr=$lat,$lon',
    );

    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    } else if (await canLaunchUrl(appleMapsUrl)) {
      await launchUrl(appleMapsUrl, mode: LaunchMode.externalApplication);
    }
  }
}
```

---

## 7. Arrival Detection

### 7.1 Arrival Celebration Widget

```dart
// lib/features/navigation/presentation/widgets/arrival_celebration.dart
import 'package:flutter/material.dart';
import 'package:foray/core/theme/app_spacing.dart';
import 'package:foray/core/theme/app_colors.dart';
import 'package:foray/database/database.dart';

class ArrivalCelebration extends StatefulWidget {
  const ArrivalCelebration({
    super.key,
    required this.observation,
    required this.onDismiss,
  });

  final Observation observation;
  final VoidCallback onDismiss;

  @override
  State<ArrivalCelebration> createState() => _ArrivalCelebrationState();
}

class _ArrivalCelebrationState extends State<ArrivalCelebration>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Celebration icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    size: 48,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                
                // Title
                Text(
                  "You've arrived!",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                
                // Subtitle
                Text(
                  widget.observation.preliminaryId ?? 'Unknown species',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                
                // Dismiss button
                ElevatedButton(
                  onPressed: widget.onDismiss,
                  child: const Text('Continue'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

---

## 8. Edge Cases & Polish

### 8.1 Compass Calibration Prompt

```dart
// lib/features/navigation/presentation/widgets/compass_calibration_prompt.dart
import 'package:flutter/material.dart';
import 'package:foray/core/theme/app_spacing.dart';

class CompassCalibrationPrompt extends StatelessWidget {
  const CompassCalibrationPrompt({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Compass needs calibration',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    'Move your phone in a figure-8 pattern',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## Acceptance Criteria

Phase 7 is complete when:

1. [ ] Compass service provides smooth heading data
2. [ ] Compass rose animates smoothly at 60fps
3. [ ] Bearing indicator shows correct direction to target
4. [ ] Distance display updates in real-time
5. [ ] Distance formats correctly (m/km or ft/mi)
6. [ ] "Getting closer" feedback appears when approaching
7. [ ] Arrival celebration triggers at ~10m threshold
8. [ ] Haptic feedback fires on arrival
9. [ ] "Open in Maps" launches external maps app
10. [ ] GPS accuracy warning shows when poor signal
11. [ ] Compass calibration prompt appears when needed
12. [ ] Navigation works fully offline
