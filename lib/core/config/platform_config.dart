import 'package:flutter/foundation.dart' show kIsWeb;

/// Platform-specific configuration and feature flags.
///
/// Used to conditionally enable/disable features based on platform capabilities.
abstract class PlatformConfig {
  /// Whether the app is running on web.
  static bool get isWeb => kIsWeb;

  /// Whether the native camera is supported.
  static bool get supportsCamera => !kIsWeb;

  /// Whether GPS location is supported.
  static bool get supportsGPS => !kIsWeb;

  /// Whether the compass/magnetometer is supported.
  static bool get supportsCompass => !kIsWeb;

  /// Whether push notifications are supported.
  static bool get supportsPushNotifications => !kIsWeb;

  /// Whether local file system storage is fully supported.
  static bool get supportsFileSystem => !kIsWeb;

  /// Local database is supported on all platforms (SQLite/IndexedDB).
  static bool get supportsLocalDatabase => true;

  /// Whether to use simulated location for demos.
  static bool get useSimulatedLocation => kIsWeb;

  /// Whether to use simulated compass for demos.
  static bool get useSimulatedCompass => kIsWeb;
}

/// Demo-specific configuration.
abstract class DemoConfig {
  /// Show a banner indicating demo mode.
  static bool get showDemoBanner => PlatformConfig.isWeb;

  /// Use simulated GPS location.
  static bool get useSimulatedLocation => PlatformConfig.isWeb;

  /// Use simulated compass heading.
  static bool get useSimulatedCompass => PlatformConfig.isWeb;

  /// Use bundled demo photos instead of camera.
  static bool get useMockPhotos => PlatformConfig.isWeb;

  /// Skip authentication (use demo user).
  static bool get skipAuth => PlatformConfig.isWeb;

  /// Pre-seed demo data on first launch.
  static bool get preSeedData => PlatformConfig.isWeb;
}
