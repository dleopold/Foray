import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides a MapController that is automatically disposed.
final mapControllerProvider = Provider.autoDispose<MapController>((ref) {
  final controller = MapController();
  ref.onDispose(() => controller.dispose());
  return controller;
});

/// Provider for tracking the current zoom level.
final mapZoomProvider = StateProvider.autoDispose<double>((ref) {
  return 13.0;
});

/// Provider for tracking the selected observation on the map.
final selectedMapObservationProvider = StateProvider.autoDispose<String?>((ref) {
  return null;
});
