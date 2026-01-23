import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../data/map_config.dart';

/// Base map widget used throughout the app.
///
/// Provides consistent map configuration and styling.
class ForayMap extends StatelessWidget {
  const ForayMap({
    super.key,
    this.controller,
    this.center,
    this.zoom,
    this.markers = const [],
    this.polylines = const [],
    this.circles = const [],
    this.onTap,
    this.onLongPress,
    this.onPositionChanged,
    this.showUserLocation = false,
    this.userLocation,
    this.isDarkMode = false,
  });

  /// Optional map controller for programmatic control.
  final MapController? controller;

  /// Initial center of the map.
  final LatLng? center;

  /// Initial zoom level.
  final double? zoom;

  /// Markers to display on the map.
  final List<Marker> markers;

  /// Polylines to display on the map.
  final List<Polyline> polylines;

  /// Circles to display on the map.
  final List<CircleMarker> circles;

  /// Callback when the map is tapped.
  final void Function(TapPosition, LatLng)? onTap;

  /// Callback when the map is long-pressed.
  final void Function(TapPosition, LatLng)? onLongPress;

  /// Callback when the map position changes.
  final void Function(MapCamera, bool)? onPositionChanged;

  /// Whether to show the user's location.
  final bool showUserLocation;

  /// Current user location (if available).
  final LatLng? userLocation;

  /// Whether to use dark mode tiles.
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final allMarkers = [...markers];

    // Add user location marker if available
    if (showUserLocation && userLocation != null) {
      allMarkers.add(
        Marker(
          point: userLocation!,
          width: 24,
          height: 24,
          child: _UserLocationMarker(),
        ),
      );
    }

    return FlutterMap(
      mapController: controller,
      options: MapOptions(
        initialCenter: center ?? MapConfig.defaultCenter,
        initialZoom: zoom ?? MapConfig.defaultZoom,
        minZoom: MapConfig.minZoom,
        maxZoom: MapConfig.maxZoom,
        onTap: onTap,
        onLongPress: onLongPress,
        onPositionChanged: onPositionChanged,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all,
        ),
      ),
      children: [
        isDarkMode ? MapConfig.darkTileLayer : MapConfig.defaultTileLayer,
        if (circles.isNotEmpty) CircleLayer(circles: circles),
        if (polylines.isNotEmpty) PolylineLayer(polylines: polylines),
        MarkerLayer(markers: allMarkers),
      ],
    );
  }
}

/// A pulsing blue dot indicating the user's current location.
class _UserLocationMarker extends StatefulWidget {
  @override
  State<_UserLocationMarker> createState() => _UserLocationMarkerState();
}

class _UserLocationMarkerState extends State<_UserLocationMarker>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue.withOpacity(0.3 * _animation.value),
            border: Border.all(
              color: Colors.blue,
              width: 2,
            ),
          ),
          child: Center(
            child: Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Extension to help with map bounds calculations.
extension MapBoundsExtension on List<LatLng> {
  /// Calculate bounds that contain all points.
  LatLngBounds? toBounds() {
    if (isEmpty) return null;
    return LatLngBounds.fromPoints(this);
  }
}
