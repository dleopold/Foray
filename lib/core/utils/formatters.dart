abstract class Formatters {
  static String distance(double meters, {bool useMetric = true}) {
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
      return '${(feet / 5280).toStringAsFixed(1)} mi';
    }
  }

  static String bearing(double degrees) {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final index = ((degrees + 22.5) / 45).floor() % 8;
    return '${directions[index]} (${degrees.round()}\u00B0)';
  }

  static String coordinates(double lat, double lon, {int decimals = 5}) {
    final latDir = lat >= 0 ? 'N' : 'S';
    final lonDir = lon >= 0 ? 'E' : 'W';
    return '${lat.abs().toStringAsFixed(decimals)}\u00B0 $latDir, '
        '${lon.abs().toStringAsFixed(decimals)}\u00B0 $lonDir';
  }
}
