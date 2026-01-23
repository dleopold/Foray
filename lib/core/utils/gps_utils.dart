import 'dart:math';

/// Utility class for GPS calculations.
///
/// Provides Haversine distance, bearing, and formatting functions.
abstract class GpsUtils {
  static const double _earthRadius = 6371000.0; // meters

  /// Calculates the great-circle distance between two points using Haversine formula.
  ///
  /// Returns distance in meters.
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return _earthRadius * c;
  }

  /// Calculates the initial bearing from point 1 to point 2.
  ///
  /// Returns bearing in degrees (0-360).
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

  /// Calculates the relative bearing from current heading to target bearing.
  ///
  /// Returns angle in degrees (-180 to 180).
  /// Positive = turn right, negative = turn left.
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

  /// Returns true if heading is within tolerance of target bearing.
  static bool isAligned(
    double currentHeading,
    double targetBearing, {
    double tolerance = 10,
  }) {
    final relative = calculateRelativeBearing(currentHeading, targetBearing).abs();
    return relative <= tolerance;
  }

  /// Formats bearing as cardinal direction.
  static String bearingToCardinal(double bearing) {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final index = ((bearing + 22.5) / 45).floor() % 8;
    return directions[index];
  }

  /// Formats bearing with cardinal and degrees.
  static String formatBearing(double bearing) {
    return '${bearingToCardinal(bearing)} (${bearing.round()}°)';
  }

  /// Formats distance with appropriate units.
  ///
  /// [useMetric] - if true, uses meters/kilometers; if false, uses feet/miles.
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

  /// Formats distance with smart unit switching.
  ///
  /// Shows more precision for close distances.
  static String formatDistanceSmart(double meters, {bool useMetric = true}) {
    if (useMetric) {
      if (meters < 10) {
        return '${meters.toStringAsFixed(1)} m';
      } else if (meters < 1000) {
        return '${meters.round()} m';
      } else if (meters < 10000) {
        return '${(meters / 1000).toStringAsFixed(2)} km';
      }
      return '${(meters / 1000).toStringAsFixed(1)} km';
    } else {
      final feet = meters * 3.28084;
      if (feet < 100) {
        return '${feet.round()} ft';
      } else if (feet < 5280) {
        return '${(feet / 100).round() * 100} ft';
      }
      final miles = feet / 5280;
      if (miles < 10) {
        return '${miles.toStringAsFixed(2)} mi';
      }
      return '${miles.toStringAsFixed(1)} mi';
    }
  }

  /// Converts degrees to radians.
  static double _toRadians(double degrees) => degrees * pi / 180;

  /// Converts radians to degrees.
  static double toDegrees(double radians) => radians * 180 / pi;
}
