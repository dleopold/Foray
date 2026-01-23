import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/platform_config.dart';

/// Provides the compass service singleton.
final compassServiceProvider = Provider<CompassService>((ref) {
  final service = CompassService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Provides a stream of smoothed compass headings.
final compassHeadingProvider = StreamProvider<double?>((ref) {
  final service = ref.watch(compassServiceProvider);
  service.startListening();
  return service.headingStream;
});

/// Service for compass/magnetometer operations.
///
/// Provides smoothed heading data using circular mean averaging.
/// On web, provides simulated compass for demo purposes.
class CompassService {
  StreamSubscription<CompassEvent>? _subscription;
  final _headingController = StreamController<double?>.broadcast();

  // Smoothing parameters
  static const int _smoothingWindow = 5;
  final List<double> _headingBuffer = [];

  // Web simulation
  Timer? _simulationTimer;
  double _simulatedHeading = 0;
  final _random = Random();

  /// Stream of smoothed heading values (0-360 degrees).
  Stream<double?> get headingStream => _headingController.stream;

  bool _isAvailable = false;

  /// Whether the device has a compass/magnetometer.
  /// On web, always returns true (simulated).
  bool get isAvailable => PlatformConfig.useSimulatedCompass ? true : _isAvailable;

  bool _needsCalibration = false;

  /// Whether the compass needs calibration.
  /// On web, always returns false.
  bool get needsCalibration => PlatformConfig.useSimulatedCompass ? false : _needsCalibration;

  /// Check if compass is available on this device.
  /// On web, always returns true (simulated).
  Future<bool> checkAvailability() async {
    if (PlatformConfig.useSimulatedCompass) {
      _isAvailable = true;
      return true;
    }

    try {
      // Try to get the first event to check availability
      final events = FlutterCompass.events;
      _isAvailable = events != null;
      return _isAvailable;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Compass not available: $e');
      }
      _isAvailable = false;
      return false;
    }
  }

  /// Start listening for compass heading updates.
  /// On web, starts simulated compass.
  void startListening() {
    if (_subscription != null || _simulationTimer != null) return; // Already listening

    // Use simulated compass for web
    if (PlatformConfig.useSimulatedCompass) {
      _startSimulation();
      return;
    }

    _subscription = FlutterCompass.events?.listen(
      (event) {
        // Check for calibration status
        if (event.accuracy != null && event.accuracy! < 0) {
          _needsCalibration = true;
        } else {
          _needsCalibration = false;
        }

        if (event.heading != null) {
          _addHeadingToBuffer(event.heading!);
          _headingController.add(_getSmoothedHeading());
        }
      },
      onError: (error) {
        if (kDebugMode) {
          debugPrint('Compass error: $error');
        }
        _headingController.addError(error);
      },
    );
  }

  /// Start simulated compass for web demo.
  void _startSimulation() {
    _simulationTimer = Timer.periodic(
      const Duration(milliseconds: 100),
      (_) => _simulateHeadingChange(),
    );
  }

  /// Simulate realistic compass movement.
  void _simulateHeadingChange() {
    // Gentle random walk for realistic feel
    _simulatedHeading += (_random.nextDouble() - 0.5) * 3;
    _simulatedHeading = _simulatedHeading % 360;
    if (_simulatedHeading < 0) _simulatedHeading += 360;

    _headingController.add(_simulatedHeading);
  }

  void _addHeadingToBuffer(double heading) {
    _headingBuffer.add(heading);
    if (_headingBuffer.length > _smoothingWindow) {
      _headingBuffer.removeAt(0);
    }
  }

  /// Calculate smoothed heading using circular mean.
  ///
  /// This correctly handles the 0/360 degree boundary.
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

  /// Stop listening for compass updates.
  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
    _simulationTimer?.cancel();
    _simulationTimer = null;
    _headingBuffer.clear();
  }

  /// Dispose of the service and release resources.
  void dispose() {
    stopListening();
    _headingController.close();
  }
}
