# Specification: Maps

**Phase:** 8  
**Estimated Duration:** 4-5 days  
**Dependencies:** Phase 5 complete  
**Patterns & Pitfalls:** See `PATTERNS_AND_PITFALLS.md` — [flutter_map Gotchas](#7-flutter_map-gotchas), [Performance Patterns](#9-performance-patterns)

---

## 1. Map Infrastructure

### 1.1 Map Configuration

```dart
// lib/features/maps/data/map_config.dart
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

abstract class MapConfig {
  // Default tile provider (OpenStreetMap)
  static TileLayer get defaultTileLayer => TileLayer(
    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    userAgentPackageName: 'com.foray.app',
    maxZoom: 18,
  );

  // Default center (will be overridden by user location or data)
  static LatLng get defaultCenter => const LatLng(47.6062, -122.3321); // Seattle

  // Default zoom levels
  static const double defaultZoom = 13;
  static const double minZoom = 3;
  static const double maxZoom = 18;
  static const double clusterZoom = 14;
}
```

### 1.2 Map Controller Provider

```dart
// lib/features/maps/presentation/controllers/map_controller_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';

final mapControllerProvider = Provider.autoDispose<MapController>((ref) {
  final controller = MapController();
  ref.onDispose(() => controller.dispose());
  return controller;
});
```

### 1.3 Base Map Widget

```dart
// lib/features/maps/presentation/widgets/foray_map.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:foray/features/maps/data/map_config.dart';

class ForayMap extends StatelessWidget {
  const ForayMap({
    super.key,
    this.controller,
    this.center,
    this.zoom,
    this.markers = const [],
    this.onTap,
    this.onLongPress,
    this.showUserLocation = true,
  });

  final MapController? controller;
  final LatLng? center;
  final double? zoom;
  final List<Marker> markers;
  final void Function(TapPosition, LatLng)? onTap;
  final void Function(TapPosition, LatLng)? onLongPress;
  final bool showUserLocation;

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: controller,
      options: MapOptions(
        initialCenter: center ?? MapConfig.defaultCenter,
        initialZoom: zoom ?? MapConfig.defaultZoom,
        minZoom: MapConfig.minZoom,
        maxZoom: MapConfig.maxZoom,
        onTap: onTap,
        onLongPress: onLongPress,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all,
        ),
      ),
      children: [
        MapConfig.defaultTileLayer,
        MarkerLayer(markers: markers),
      ],
    );
  }
}
```

---

## 2. Observation Markers

### 2.1 Observation Marker Widget

```dart
// lib/features/maps/presentation/widgets/observation_marker.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:foray/core/theme/app_colors.dart';
import 'package:foray/core/theme/app_spacing.dart';
import 'package:foray/database/database.dart';

class ObservationMarkerBuilder {
  static Marker build({
    required Observation observation,
    Photo? photo,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    return Marker(
      point: LatLng(observation.latitude, observation.longitude),
      width: isSelected ? 56 : 44,
      height: isSelected ? 56 : 44,
      child: ObservationMarkerWidget(
        observation: observation,
        photo: photo,
        onTap: onTap,
        isSelected: isSelected,
      ),
    );
  }
}

class ObservationMarkerWidget extends StatelessWidget {
  const ObservationMarkerWidget({
    super.key,
    required this.observation,
    this.photo,
    required this.onTap,
    this.isSelected = false,
  });

  final Observation observation;
  final Photo? photo;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _getMarkerColor(),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.white,
            width: isSelected ? 3 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipOval(
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    // If we have a photo, show thumbnail
    if (photo != null && photo!.localPath.isNotEmpty) {
      return Image.asset(
        photo!.localPath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildIcon(),
      );
    }
    return _buildIcon();
  }

  Widget _buildIcon() {
    return Container(
      color: _getMarkerColor(),
      child: Icon(
        Icons.eco,
        color: Colors.white,
        size: isSelected ? 28 : 22,
      ),
    );
  }

  Color _getMarkerColor() {
    switch (observation.privacyLevel) {
      case PrivacyLevel.private:
        return AppColors.privacyPrivate;
      case PrivacyLevel.foray:
        return AppColors.privacyForay;
      case PrivacyLevel.publicExact:
        return AppColors.privacyPublic;
      case PrivacyLevel.publicObscured:
        return AppColors.privacyObscured;
    }
  }
}
```

---

## 3. Marker Clustering

### 3.1 Cluster Logic

```dart
// lib/features/maps/data/marker_cluster.dart
import 'dart:math';
import 'package:latlong2/latlong.dart';
import 'package:foray/database/database.dart';

class ClusterManager {
  static List<MapCluster> clusterObservations(
    List<ObservationWithDetails> observations,
    double zoom, {
    double clusterDistance = 60, // pixels
  }) {
    if (zoom >= 15) {
      // At high zoom, no clustering
      return observations.map((o) => MapCluster.single(o)).toList();
    }

    final clusters = <MapCluster>[];
    final processed = <String>{};

    for (final obs in observations) {
      if (processed.contains(obs.observation.id)) continue;

      final cluster = <ObservationWithDetails>[obs];
      processed.add(obs.observation.id);

      // Find nearby observations
      for (final other in observations) {
        if (processed.contains(other.observation.id)) continue;

        final distance = _pixelDistance(
          obs.observation.latitude,
          obs.observation.longitude,
          other.observation.latitude,
          other.observation.longitude,
          zoom,
        );

        if (distance < clusterDistance) {
          cluster.add(other);
          processed.add(other.observation.id);
        }
      }

      clusters.add(MapCluster(cluster));
    }

    return clusters;
  }

  static double _pixelDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
    double zoom,
  ) {
    // Simplified pixel distance calculation
    final scale = pow(2, zoom);
    final x1 = (lon1 + 180) / 360 * 256 * scale;
    final y1 = (1 - log(tan(lat1 * pi / 180) + 1 / cos(lat1 * pi / 180)) / pi) /
        2 * 256 * scale;
    final x2 = (lon2 + 180) / 360 * 256 * scale;
    final y2 = (1 - log(tan(lat2 * pi / 180) + 1 / cos(lat2 * pi / 180)) / pi) /
        2 * 256 * scale;

    return sqrt(pow(x1 - x2, 2) + pow(y1 - y2, 2));
  }
}

class MapCluster {
  MapCluster(this.observations);
  
  factory MapCluster.single(ObservationWithDetails observation) {
    return MapCluster([observation]);
  }

  final List<ObservationWithDetails> observations;

  bool get isSingle => observations.length == 1;
  int get count => observations.length;

  LatLng get center {
    if (observations.isEmpty) return const LatLng(0, 0);
    if (observations.length == 1) {
      return LatLng(
        observations.first.observation.latitude,
        observations.first.observation.longitude,
      );
    }

    // Average center of all observations
    var sumLat = 0.0;
    var sumLon = 0.0;
    for (final obs in observations) {
      sumLat += obs.observation.latitude;
      sumLon += obs.observation.longitude;
    }
    return LatLng(sumLat / observations.length, sumLon / observations.length);
  }

  ObservationWithDetails get first => observations.first;
}
```

### 3.2 Cluster Marker Widget

```dart
// lib/features/maps/presentation/widgets/cluster_marker.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:foray/core/theme/app_colors.dart';
import 'package:foray/features/maps/data/marker_cluster.dart';

class ClusterMarkerBuilder {
  static Marker build({
    required MapCluster cluster,
    required VoidCallback onTap,
  }) {
    if (cluster.isSingle) {
      return ObservationMarkerBuilder.build(
        observation: cluster.first.observation,
        photo: cluster.first.photos.firstOrNull,
        onTap: onTap,
      );
    }

    return Marker(
      point: cluster.center,
      width: 48,
      height: 48,
      child: ClusterMarkerWidget(
        count: cluster.count,
        onTap: onTap,
      ),
    );
  }
}

class ClusterMarkerWidget extends StatelessWidget {
  const ClusterMarkerWidget({
    super.key,
    required this.count,
    required this.onTap,
  });

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            count > 99 ? '99+' : count.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
```

---

## 4. Foray Map Screen

### 4.1 Foray Map Tab

```dart
// lib/features/forays/presentation/widgets/foray_map_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import 'package:foray/core/theme/app_spacing.dart';
import 'package:foray/database/database.dart';
import 'package:foray/features/maps/presentation/widgets/foray_map.dart';
import 'package:foray/features/maps/presentation/widgets/observation_marker.dart';
import 'package:foray/features/maps/data/marker_cluster.dart';
import 'package:foray/features/observations/presentation/controllers/observations_controller.dart';
import 'package:foray/routing/routes.dart';

class ForayMapTab extends ConsumerStatefulWidget {
  const ForayMapTab({super.key, required this.forayId});

  final String forayId;

  @override
  ConsumerState<ForayMapTab> createState() => _ForayMapTabState();
}

class _ForayMapTabState extends ConsumerState<ForayMapTab> {
  final _mapController = MapController();
  String? _selectedObservationId;
  double _currentZoom = 13;

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final observationsAsync = ref.watch(forayObservationsProvider(widget.forayId));

    return observationsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
      data: (observations) {
        if (observations.isEmpty) {
          return const Center(
            child: Text('No observations yet'),
          );
        }

        final clusters = ClusterManager.clusterObservations(
          observations,
          _currentZoom,
        );

        final markers = clusters.map((cluster) {
          if (cluster.isSingle) {
            return ObservationMarkerBuilder.build(
              observation: cluster.first.observation,
              photo: cluster.first.photos.firstOrNull,
              isSelected: cluster.first.observation.id == _selectedObservationId,
              onTap: () => _selectObservation(cluster.first),
            );
          }
          return ClusterMarkerBuilder.build(
            cluster: cluster,
            onTap: () => _zoomToCluster(cluster),
          );
        }).toList();

        return Stack(
          children: [
            ForayMap(
              controller: _mapController,
              center: _calculateCenter(observations),
              markers: markers,
              onTap: (_, __) => _clearSelection(),
            ),
            
            // Fit all button
            Positioned(
              top: AppSpacing.md,
              right: AppSpacing.md,
              child: FloatingActionButton.small(
                heroTag: 'fit',
                onPressed: () => _fitAllMarkers(observations),
                child: const Icon(Icons.fit_screen),
              ),
            ),
            
            // Selected observation panel
            if (_selectedObservationId != null)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildSelectionPanel(observations),
              ),
          ],
        );
      },
    );
  }

  LatLng _calculateCenter(List<ObservationWithDetails> observations) {
    if (observations.isEmpty) return MapConfig.defaultCenter;
    
    var sumLat = 0.0;
    var sumLon = 0.0;
    for (final obs in observations) {
      sumLat += obs.observation.latitude;
      sumLon += obs.observation.longitude;
    }
    return LatLng(
      sumLat / observations.length,
      sumLon / observations.length,
    );
  }

  void _selectObservation(ObservationWithDetails observation) {
    setState(() => _selectedObservationId = observation.observation.id);
    _mapController.move(
      LatLng(observation.observation.latitude, observation.observation.longitude),
      15,
    );
  }

  void _clearSelection() {
    setState(() => _selectedObservationId = null);
  }

  void _zoomToCluster(MapCluster cluster) {
    _mapController.move(cluster.center, _currentZoom + 2);
  }

  void _fitAllMarkers(List<ObservationWithDetails> observations) {
    if (observations.isEmpty) return;

    final bounds = LatLngBounds.fromPoints(
      observations.map((o) => LatLng(o.observation.latitude, o.observation.longitude)).toList(),
    );

    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(50),
      ),
    );
  }

  Widget _buildSelectionPanel(List<ObservationWithDetails> observations) {
    final selected = observations.firstWhere(
      (o) => o.observation.id == _selectedObservationId,
    );

    return Card(
      margin: const EdgeInsets.all(AppSpacing.md),
      child: InkWell(
        onTap: () => context.push(
          AppRoutes.observationDetail.replaceFirst(':id', selected.observation.id),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              // Thumbnail
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  color: Theme.of(context).colorScheme.surfaceVariant,
                ),
                child: selected.photos.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                        child: Image.asset(
                          selected.photos.first.localPath,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Icon(Icons.eco),
              ),
              const SizedBox(width: AppSpacing.md),
              
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      selected.observation.preliminaryId ?? 'Unknown species',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    Text(
                      selected.collector?.displayName ?? 'Unknown collector',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              
              // Navigate button
              IconButton(
                icon: const Icon(Icons.navigation),
                onPressed: () => context.push(
                  AppRoutes.navigate.replaceFirst(':observationId', selected.observation.id),
                ),
              ),
              
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## 5. Personal Map Screen

### 5.1 Personal Observation Map

```dart
// lib/features/maps/presentation/screens/personal_map_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import 'package:foray/core/theme/app_spacing.dart';
import 'package:foray/database/database.dart';
import 'package:foray/features/maps/presentation/widgets/foray_map.dart';
import 'package:foray/features/maps/presentation/widgets/observation_marker.dart';
import 'package:foray/features/maps/data/marker_cluster.dart';
import 'package:foray/features/auth/presentation/controllers/auth_controller.dart';
import 'package:foray/routing/routes.dart';

final personalObservationsProvider = FutureProvider<List<Observation>>((ref) async {
  final db = ref.watch(databaseProvider);
  final authState = ref.watch(authControllerProvider);
  final user = authState.user;
  
  if (user == null) return [];
  
  return db.observationsDao.getObservationsForUser(user.id);
});

class PersonalMapScreen extends ConsumerStatefulWidget {
  const PersonalMapScreen({super.key});

  @override
  ConsumerState<PersonalMapScreen> createState() => _PersonalMapScreenState();
}

class _PersonalMapScreenState extends ConsumerState<PersonalMapScreen> {
  final _mapController = MapController();
  String? _selectedObservationId;
  
  // Filters
  DateTimeRange? _dateFilter;
  String? _speciesFilter;

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final observationsAsync = ref.watch(personalObservationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Observations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilters,
          ),
        ],
      ),
      body: observationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (observations) {
          final filtered = _applyFilters(observations);

          if (filtered.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.map_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    observations.isEmpty
                        ? 'No observations yet'
                        : 'No observations match filters',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            );
          }

          final markers = filtered.map((obs) {
            return ObservationMarkerBuilder.build(
              observation: obs,
              isSelected: obs.id == _selectedObservationId,
              onTap: () => setState(() => _selectedObservationId = obs.id),
            );
          }).toList();

          return Stack(
            children: [
              ForayMap(
                controller: _mapController,
                markers: markers,
                onTap: (_, __) => setState(() => _selectedObservationId = null),
              ),
              
              // My location button
              Positioned(
                bottom: _selectedObservationId != null ? 120 : AppSpacing.lg,
                right: AppSpacing.md,
                child: FloatingActionButton.small(
                  heroTag: 'location',
                  onPressed: _goToMyLocation,
                  child: const Icon(Icons.my_location),
                ),
              ),
              
              // Selection panel
              if (_selectedObservationId != null)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildSelectionPanel(filtered),
                ),
            ],
          );
        },
      ),
    );
  }

  List<Observation> _applyFilters(List<Observation> observations) {
    var filtered = observations;

    if (_dateFilter != null) {
      filtered = filtered.where((o) {
        return o.observedAt.isAfter(_dateFilter!.start) &&
            o.observedAt.isBefore(_dateFilter!.end.add(const Duration(days: 1)));
      }).toList();
    }

    if (_speciesFilter != null && _speciesFilter!.isNotEmpty) {
      filtered = filtered.where((o) {
        return o.preliminaryId?.toLowerCase().contains(_speciesFilter!.toLowerCase()) ?? false;
      }).toList();
    }

    return filtered;
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _FilterSheet(
        dateFilter: _dateFilter,
        speciesFilter: _speciesFilter,
        onApply: (date, species) {
          setState(() {
            _dateFilter = date;
            _speciesFilter = species;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _goToMyLocation() async {
    // Get current location and move map
    final locationService = ref.read(locationServiceProvider);
    final position = await locationService.getCurrentPosition();
    if (position != null) {
      _mapController.move(LatLng(position.latitude, position.longitude), 15);
    }
  }

  Widget _buildSelectionPanel(List<Observation> observations) {
    final selected = observations.firstWhere((o) => o.id == _selectedObservationId);

    return Card(
      margin: const EdgeInsets.all(AppSpacing.md),
      child: InkWell(
        onTap: () => context.push(
          AppRoutes.observationDetail.replaceFirst(':id', selected.id),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              const Icon(Icons.eco, size: 40),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      selected.preliminaryId ?? 'Unknown species',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Text(
                      selected.observedAt.toString().split(' ')[0],
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.navigation),
                onPressed: () => context.push(
                  AppRoutes.navigate.replaceFirst(':observationId', selected.id),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({
    this.dateFilter,
    this.speciesFilter,
    required this.onApply,
  });

  final DateTimeRange? dateFilter;
  final String? speciesFilter;
  final void Function(DateTimeRange?, String?) onApply;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  DateTimeRange? _dateFilter;
  final _speciesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _dateFilter = widget.dateFilter;
    _speciesController.text = widget.speciesFilter ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Filter Observations', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.lg),
          
          // Date filter
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Date Range'),
            subtitle: Text(_dateFilter == null
                ? 'All time'
                : '${_dateFilter!.start.toString().split(' ')[0]} - ${_dateFilter!.end.toString().split(' ')[0]}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_dateFilter != null)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => setState(() => _dateFilter = null),
                  ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                      initialDateRange: _dateFilter,
                    );
                    if (picked != null) {
                      setState(() => _dateFilter = picked);
                    }
                  },
                ),
              ],
            ),
          ),
          
          // Species filter
          TextField(
            controller: _speciesController,
            decoration: const InputDecoration(
              labelText: 'Species',
              hintText: 'Filter by species name',
            ),
          ),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Apply button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => widget.onApply(
                _dateFilter,
                _speciesController.text.trim().isEmpty ? null : _speciesController.text.trim(),
              ),
              child: const Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## 6. Map Interaction Polish

Includes smooth pan/zoom, current location indicator, and theme-consistent styling - implemented via `flutter_map` configuration options in the base `ForayMap` widget.

---

## Acceptance Criteria

Phase 8 is complete when:

1. [ ] Map renders with OpenStreetMap tiles
2. [ ] Observation markers display correctly
3. [ ] Markers show photo thumbnails when available
4. [ ] Clustering works at low zoom levels
5. [ ] Cluster tap zooms in
6. [ ] Marker tap shows selection panel
7. [ ] Selection panel navigates to observation detail
8. [ ] "Navigate to" button works from selection
9. [ ] Foray map shows all foray observations
10. [ ] Personal map shows all user observations
11. [ ] Date filter works
12. [ ] Species filter works
13. [ ] "Fit all markers" works
14. [ ] "My location" button works
