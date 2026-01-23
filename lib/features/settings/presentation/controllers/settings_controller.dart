import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/privacy_levels.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/app_settings.dart';

/// Keys for SharedPreferences storage.
abstract class _SettingsKeys {
  static const themeMode = 'settings_theme_mode';
  static const distanceUnit = 'settings_distance_unit';
  static const defaultPrivacy = 'settings_default_privacy';
}

/// Provider for SharedPreferences instance.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in ProviderScope',
  );
});

/// Provider for app settings with persistence.
final settingsControllerProvider =
    StateNotifierProvider<SettingsController, AppSettings>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SettingsController(prefs, ref);
});

/// Convenience provider for whether to use metric units.
final useMetricProvider = Provider<bool>((ref) {
  return ref.watch(settingsControllerProvider).useMetric;
});

/// Convenience provider for default privacy level.
final defaultPrivacyProvider = Provider<PrivacyLevel>((ref) {
  return ref.watch(settingsControllerProvider).defaultPrivacy;
});

/// Controller for app settings with persistence.
class SettingsController extends StateNotifier<AppSettings> {
  SettingsController(this._prefs, this._ref) : super(_loadSettings(_prefs)) {
    // Sync theme mode with the app's themeModeProvider
    _syncThemeMode();
  }

  final SharedPreferences _prefs;
  final Ref _ref;

  /// Load settings from SharedPreferences.
  static AppSettings _loadSettings(SharedPreferences prefs) {
    final themeModeIndex = prefs.getInt(_SettingsKeys.themeMode);
    final distanceUnitIndex = prefs.getInt(_SettingsKeys.distanceUnit);
    final privacyIndex = prefs.getInt(_SettingsKeys.defaultPrivacy);

    return AppSettings(
      themeMode: themeModeIndex != null && themeModeIndex < AppThemeMode.values.length
          ? AppThemeMode.values[themeModeIndex]
          : AppThemeMode.system,
      distanceUnit: distanceUnitIndex != null && distanceUnitIndex < DistanceUnit.values.length
          ? DistanceUnit.values[distanceUnitIndex]
          : DistanceUnit.metric,
      defaultPrivacy: privacyIndex != null && privacyIndex < PrivacyLevel.values.length
          ? PrivacyLevel.values[privacyIndex]
          : PrivacyLevel.private,
    );
  }

  /// Sync settings theme mode with Flutter's ThemeMode.
  void _syncThemeMode() {
    final flutterMode = _appThemeModeToThemeMode(state.themeMode);
    _ref.read(themeModeProvider.notifier).state = flutterMode;
  }

  /// Convert AppThemeMode to Flutter's ThemeMode.
  ThemeMode _appThemeModeToThemeMode(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.system:
        return ThemeMode.system;
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
    }
  }

  /// Update theme mode preference.
  Future<void> setThemeMode(AppThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _prefs.setInt(_SettingsKeys.themeMode, mode.index);
    _syncThemeMode();
  }

  /// Update distance unit preference.
  Future<void> setDistanceUnit(DistanceUnit unit) async {
    state = state.copyWith(distanceUnit: unit);
    await _prefs.setInt(_SettingsKeys.distanceUnit, unit.index);
  }

  /// Update default privacy level.
  Future<void> setDefaultPrivacy(PrivacyLevel privacy) async {
    state = state.copyWith(defaultPrivacy: privacy);
    await _prefs.setInt(_SettingsKeys.defaultPrivacy, privacy.index);
  }

  /// Toggle between light and dark mode (ignoring system).
  Future<void> toggleDarkMode() async {
    final newMode = state.themeMode == AppThemeMode.dark
        ? AppThemeMode.light
        : AppThemeMode.dark;
    await setThemeMode(newMode);
  }
}
