import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../database/database.dart';
import '../../../../database/daos/observations_dao.dart';
import '../../../../database/tables/forays_table.dart';

/// Builds a marker for an observation.
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

  /// Build a marker from ObservationWithDetails.
  static Marker buildFromDetails({
    required ObservationWithDetails details,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    return build(
      observation: details.observation,
      photo: details.primaryPhoto,
      onTap: onTap,
      isSelected: isSelected,
    );
  }
}

/// Visual representation of an observation on the map.
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
              blurRadius: isSelected ? 8 : 4,
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
    // If we have a photo with a local path, show thumbnail
    if (photo != null && photo!.localPath.isNotEmpty) {
      final file = File(photo!.localPath);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          cacheWidth: 100, // Limit cache size for performance
          errorBuilder: (_, __, ___) => _buildIcon(),
        );
      }
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

/// A simple dot marker for minimal display.
class SimpleDotMarker extends StatelessWidget {
  const SimpleDotMarker({
    super.key,
    this.color,
    this.size = 12,
  });

  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color ?? AppColors.primary,
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );
  }
}
