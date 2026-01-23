import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/config/platform_config.dart';
import '../../core/constants/app_constants.dart';

/// Provides the location service singleton.
final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

/// Provides the current position (one-time fetch).
final currentPositionProvider = FutureProvider<Position?>((ref) async {
  final locationService = ref.watch(locationServiceProvider);
  return locationService.getCurrentPosition();
});

/// Provides a stream of position updates.
final positionStreamProvider = StreamProvider<Position>((ref) {
  final locationService = ref.watch(locationServiceProvider);
  return locationService.getPositionStream();
});

/// Service for location/GPS operations.
///
/// Handles permission checks, position retrieval, and distance/bearing calculations.
/// On web, provides simulated positions for demo purposes.
class LocationService {
  // Simulated locations for web demo (Pacific Northwest mushroom hotspots)
  static final _simulatedPositions = [
    _SimulatedPosition(47.6062, -122.3321, 'Seattle'),
    _SimulatedPosition(47.6205, -122.3493, 'Queen Anne'),
    _SimulatedPosition(47.5480, -122.0354, 'Tiger Mountain'),
    _SimulatedPosition(47.4799, -121.7817, 'Snoqualmie'),
    _SimulatedPosition(47.7511, -122.3244, 'Carkeek Park'),
  ];

  int _simulatedIndex = 0;
  StreamController<Position>? _webPositionController;
  Timer? _webPositionTimer;

  /// Check and request location permissions.
  ///
  /// Returns true if location services are enabled and permission is granted.
  /// On web, always returns true (simulated).
  Future<bool> checkPermission() async {
    // Web always has "permission" for simulated location
    if (PlatformConfig.useSimulatedLocation) {
      return true;
    }

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (kDebugMode) {
        debugPrint('Location services are disabled');
      }
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (kDebugMode) {
          debugPrint('Location permission denied');
        }
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (kDebugMode) {
        debugPrint('Location permission permanently denied');
      }
      return false;
    }

    return true;
  }

  /// Get the current position.
  ///
  /// Returns null if permission is denied or location unavailable.
  /// On web, returns simulated position.
  Future<Position?> getCurrentPosition({
    LocationAccuracy accuracy = LocationAccuracy.best,
    Duration? timeout,
  }) async {
    // Return simulated position for web
    if (PlatformConfig.useSimulatedLocation) {
      await Future.delayed(const Duration(milliseconds: 300)); // Simulate delay
      return _getSimulatedPosition();
    }

    final hasPermission = await checkPermission();
    if (!hasPermission) return null;

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: accuracy,
        timeLimit: timeout ??
            Duration(seconds: AppConstants.gpsTimeoutSeconds),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting current position: $e');
      }
      return null;
    }
  }

  /// Get a stream of position updates.
  /// On web, returns simulated position updates.
  Stream<Position> getPositionStream({
    LocationAccuracy accuracy = LocationAccuracy.best,
    int distanceFilter = 5,
  }) {
    // Return simulated position stream for web
    if (PlatformConfig.useSimulatedLocation) {
      _webPositionController?.close();
      _webPositionController = StreamController<Position>.broadcast();
      _webPositionTimer?.cancel();

      // Emit position updates every 2 seconds
      _webPositionTimer = Timer.periodic(
        const Duration(seconds: 2),
        (_) {
          if (_webPositionController?.isClosed == false) {
            _webPositionController!.add(_getSimulatedPosition());
          }
        },
      );

      // Emit initial position
      Future.microtask(() {
        if (_webPositionController?.isClosed == false) {
          _webPositionController!.add(_getSimulatedPosition());
        }
      });

      return _webPositionController!.stream;
    }

    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter,
      ),
    );
  }

  /// Get next simulated position (cycles through demo locations).
  Position _getSimulatedPosition() {
    final simulated = _simulatedPositions[_simulatedIndex];
    _simulatedIndex = (_simulatedIndex + 1) % _simulatedPositions.length;

    return Position(
      latitude: simulated.lat,
      longitude: simulated.lon,
      accuracy: 10.0,
      altitude: 100.0,
      altitudeAccuracy: 5.0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
      timestamp: DateTime.now(),
    );
  }

  /// Dispose of web simulation resources.
  void dispose() {
    _webPositionTimer?.cancel();
    _webPositionController?.close();
  }

  /// Calculate distance between two points in meters.
  double distanceBetween(
    double startLat,
    double startLon,
    double endLat,
    double endLon,
  ) {
    return Geolocator.distanceBetween(startLat, startLon, endLat, endLon);
  }

  /// Calculate bearing between two points in degrees.
  double bearingBetween(
    double startLat,
    double startLon,
    double endLat,
    double endLon,
  ) {
    return Geolocator.bearingBetween(startLat, startLon, endLat, endLon);
  }

  /// Open the device's location settings.
  Future<bool> openLocationSettings() {
    return Geolocator.openLocationSettings();
  }

  /// Open the app's permission settings.
  Future<bool> openAppSettings() {
    return Geolocator.openAppSettings();
  }

  /// Format distance for display.
  ///
  /// Shows meters if under 1km, otherwise kilometers.
  String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.round()}m';
    } else {
      return '${(meters / 1000).toStringAsFixed(1)}km';
    }
  }

  /// Format coordinates for display.
  String formatCoordinates(double latitude, double longitude, {int decimals = 5}) {
    return '${latitude.toStringAsFixed(decimals)}, ${longitude.toStringAsFixed(decimals)}';
  }
}

/// Helper class for simulated positions.
class _SimulatedPosition {
  const _SimulatedPosition(this.lat, this.lon, this.name);

  final double lat;
  final double lon;
  final String name;
}
