import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/marker_cluster.dart';
import 'observation_marker.dart';

/// Builds markers for clusters (single or grouped observations).
class ClusterMarkerBuilder {
  /// Build a marker for a cluster.
  ///
  /// If the cluster contains a single observation, builds an observation marker.
  /// Otherwise, builds a cluster marker showing the count.
  static Marker build({
    required MapCluster cluster,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    if (cluster.isSingle) {
      return ObservationMarkerBuilder.buildFromDetails(
        details: cluster.first,
        onTap: onTap,
        isSelected: isSelected,
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

/// Visual representation of a cluster on the map.
class ClusterMarkerWidget extends StatelessWidget {
  const ClusterMarkerWidget({
    super.key,
    required this.count,
    required this.onTap,
    this.color,
  });

  final int count;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color ?? AppColors.primary,
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

/// A cluster marker with size varying based on count.
class ScaledClusterMarker extends StatelessWidget {
  const ScaledClusterMarker({
    super.key,
    required this.count,
    required this.onTap,
    this.minSize = 40,
    this.maxSize = 60,
    this.maxCount = 100,
  });

  final int count;
  final VoidCallback onTap;
  final double minSize;
  final double maxSize;
  final int maxCount;

  double get size {
    final ratio = (count / maxCount).clamp(0.0, 1.0);
    return minSize + (maxSize - minSize) * ratio;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primaryDark,
            ],
          ),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            count > 99 ? '99+' : count.toString(),
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: size * 0.35,
            ),
          ),
        ),
      ),
    );
  }
}
