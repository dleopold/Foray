import '../../../core/constants/privacy_levels.dart';

/// Distance unit preference.
enum DistanceUnit {
  metric('Metric', 'km, m'),
  imperial('Imperial', 'mi, ft');

  const DistanceUnit(this.label, this.description);

  final String label;
  final String description;
}

/// App-wide settings that persist across sessions.
class AppSettings {
  const AppSettings({
    this.themeMode = AppThemeMode.system,
    this.distanceUnit = DistanceUnit.metric,
    this.defaultPrivacy = PrivacyLevel.private,
  });

  /// Theme preference.
  final AppThemeMode themeMode;

  /// Preferred distance units.
  final DistanceUnit distanceUnit;

  /// Default privacy level for new observations.
  final PrivacyLevel defaultPrivacy;

  /// Whether metric units should be used.
  bool get useMetric => distanceUnit == DistanceUnit.metric;

  AppSettings copyWith({
    AppThemeMode? themeMode,
    DistanceUnit? distanceUnit,
    PrivacyLevel? defaultPrivacy,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      distanceUnit: distanceUnit ?? this.distanceUnit,
      defaultPrivacy: defaultPrivacy ?? this.defaultPrivacy,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettings &&
          runtimeType == other.runtimeType &&
          themeMode == other.themeMode &&
          distanceUnit == other.distanceUnit &&
          defaultPrivacy == other.defaultPrivacy;

  @override
  int get hashCode =>
      themeMode.hashCode ^ distanceUnit.hashCode ^ defaultPrivacy.hashCode;
}

/// Theme mode options (matches Flutter's ThemeMode but serializable).
enum AppThemeMode {
  system('System', 'Follow device settings'),
  light('Light', 'Always use light theme'),
  dark('Dark', 'Always use dark theme');

  const AppThemeMode(this.label, this.description);

  final String label;
  final String description;
}
