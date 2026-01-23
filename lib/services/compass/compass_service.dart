import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
class CompassService {
  StreamSubscription<CompassEvent>? _subscription;
  final _headingController = StreamController<double?>.broadcast();

  // Smoothing parameters
  static const int _smoothingWindow = 5;
  final List<double> _headingBuffer = [];

  /// Stream of smoothed heading values (0-360 degrees).
  Stream<double?> get headingStream => _headingController.stream;

  bool _isAvailable = false;

  /// Whether the device has a compass/magnetometer.
  bool get isAvailable => _isAvailable;

  bool _needsCalibration = false;

  /// Whether the compass needs calibration.
  bool get needsCalibration => _needsCalibration;

  /// Check if compass is available on this device.
  Future<bool> checkAvailability() async {
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
  void startListening() {
    if (_subscription != null) return; // Already listening

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
    _headingBuffer.clear();
  }

  /// Dispose of the service and release resources.
  void dispose() {
    stopListening();
    _headingController.close();
  }
}
