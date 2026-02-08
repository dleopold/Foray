import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../database/daos/observations_dao.dart';
import '../../../../routing/routes.dart';
import '../../../maps/data/map_config.dart';
import '../../../maps/data/marker_cluster.dart';
import '../../../maps/presentation/widgets/cluster_marker.dart';
import '../../../maps/presentation/widgets/foray_map.dart';
import '../../../maps/presentation/widgets/observation_marker.dart';
import '../../../observations/presentation/controllers/observation_controller.dart';

/// Tab displaying the map view for a foray.
///
/// Shows observation locations on an interactive map with clustering
/// and selection support.
class ForayMapTab extends ConsumerStatefulWidget {
  const ForayMapTab({super.key, required this.forayId});

  final String forayId;

  @override
  ConsumerState<ForayMapTab> createState() => _ForayMapTabState();
}

class _ForayMapTabState extends ConsumerState<ForayMapTab> {
  final _mapController = MapController();
  String? _selectedObservationId;
  double _currentZoom = MapConfig.defaultZoom;

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final observationsAsync =
        ref.watch(forayObservationsProvider(widget.forayId));

    return observationsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Error loading observations: $err'),
            ],
          ),
        ),
      ),
      data: (observations) {
        if (observations.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.map_outlined,
                    size: 64,
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.5),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'No observations yet',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Observations will appear here on the map',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        final clusters = ClusterManager.clusterObservations(
          observations,
          _currentZoom,
        );

        final markers = clusters.map((cluster) {
          if (cluster.isSingle) {
            return ObservationMarkerBuilder.buildFromDetails(
              details: cluster.first,
              isSelected:
                  cluster.first.observation.id == _selectedObservationId,
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
              onPositionChanged: (camera, hasGesture) {
                final zoom = camera.zoom;
                if (zoom != null && _currentZoom != zoom) {
                  setState(() => _currentZoom = zoom);
                }
              },
            ),

            // Fit all button
            Positioned(
              top: AppSpacing.md,
              right: AppSpacing.md,
              child: FloatingActionButton.small(
                heroTag: 'fit_all',
                onPressed: () => _fitAllMarkers(observations),
                backgroundColor: Theme.of(context).colorScheme.surface,
                foregroundColor: Theme.of(context).colorScheme.onSurface,
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
      observations
          .map(
              (o) => LatLng(o.observation.latitude, o.observation.longitude),)
          .toList(),
    );

    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(MapConfig.boundsPadding),
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
          AppRoutes.observationDetail
              .replaceFirst(':id', selected.observation.id),
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
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                child: selected.photos.isNotEmpty
                    ? ClipRRect(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusSm),
                        child: _buildThumbnail(selected.photos.first.localPath),
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
                    if (selected.collector != null)
                      Text(
                        selected.collector!.displayName,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
              ),

              // Navigate button
              IconButton(
                icon: const Icon(Icons.navigation),
                onPressed: () => context.push(
                  AppRoutes.navigate
                      .replaceFirst(':observationId', selected.observation.id),
                ),
                tooltip: 'Navigate to this observation',
              ),

              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(String path) {
    // Handle both asset and file paths
    if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.eco),
      );
    }
    return Image.asset(
      'assets/images/placeholder.png',
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const Icon(Icons.eco),
    );
  }
}
