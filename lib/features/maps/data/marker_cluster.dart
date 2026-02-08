import 'dart:math';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../database/daos/observations_dao.dart';
import 'map_config.dart';

/// Manages clustering of observation markers.
class ClusterManager {
  /// Cluster observations based on zoom level and pixel distance.
  ///
  /// At high zoom levels (>= 15), no clustering is applied.
  /// At lower zoom levels, nearby observations are grouped together.
  static List<MapCluster> clusterObservations(
    List<ObservationWithDetails> observations,
    double zoom, {
    double clusterDistance = MapConfig.clusterDistance,
  }) {
    if (observations.isEmpty) return [];

    // No clustering at high zoom
    if (zoom >= MapConfig.clusterDisableZoom) {
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

  /// Calculate the approximate pixel distance between two points.
  static double _pixelDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
    double zoom,
  ) {
    final scale = pow(2, zoom);
    final x1 = (lon1 + 180) / 360 * 256 * scale;
    final y1 =
        (1 - log(tan(lat1 * pi / 180) + 1 / cos(lat1 * pi / 180)) / pi) /
            2 *
            256 *
            scale;
    final x2 = (lon2 + 180) / 360 * 256 * scale;
    final y2 =
        (1 - log(tan(lat2 * pi / 180) + 1 / cos(lat2 * pi / 180)) / pi) /
            2 *
            256 *
            scale;

    return sqrt(pow(x1 - x2, 2) + pow(y1 - y2, 2));
  }
}

/// A cluster of one or more observations.
class MapCluster {
  MapCluster(this.observations);

  /// Create a cluster with a single observation.
  factory MapCluster.single(ObservationWithDetails observation) {
    return MapCluster([observation]);
  }

  /// The observations in this cluster.
  final List<ObservationWithDetails> observations;

  /// Whether this cluster contains only one observation.
  bool get isSingle => observations.length == 1;

  /// The number of observations in this cluster.
  int get count => observations.length;

  /// The center point of this cluster.
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

  /// Get the first observation (for single clusters or display).
  ObservationWithDetails get first => observations.first;

  /// Get bounds that contain all observations in this cluster.
  LatLngBounds get bounds {
    return LatLngBounds.fromPoints(
      observations
          .map((o) =>
              LatLng(o.observation.latitude, o.observation.longitude),)
          .toList(),
    );
  }
}
