import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Configuration for map display.
abstract class MapConfig {
  /// Default tile provider (OpenStreetMap).
  static TileLayer get defaultTileLayer => TileLayer(
        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        userAgentPackageName: 'com.foray.app',
        maxZoom: 18,
        tileProvider: NetworkTileProvider(),
      );

  /// Dark mode tile provider.
  static TileLayer get darkTileLayer => TileLayer(
        urlTemplate:
            'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
        userAgentPackageName: 'com.foray.app',
        subdomains: const ['a', 'b', 'c', 'd'],
        maxZoom: 19,
        tileProvider: NetworkTileProvider(),
      );

  /// Default center (Seattle, WA - will be overridden by user location or data).
  static LatLng get defaultCenter => const LatLng(47.6062, -122.3321);

  /// Default zoom levels.
  static const double defaultZoom = 13;
  static const double minZoom = 3;
  static const double maxZoom = 18;

  /// Zoom level at which clustering is disabled.
  static const double clusterDisableZoom = 15;

  /// Distance in pixels for marker clustering.
  static const double clusterDistance = 60;

  /// Padding for fitting bounds.
  static const double boundsPadding = 50;
}
