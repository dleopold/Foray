import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/extensions/datetime_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/indicators/privacy_badge.dart';
import '../../../../database/daos/observations_dao.dart';

/// A card widget displaying observation summary information.
///
/// Shows thumbnail, species, date, collector, and privacy level.
class ObservationCard extends StatelessWidget {
  const ObservationCard({
    super.key,
    required this.observation,
    required this.onTap,
  });

  final ObservationWithDetails observation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final obs = observation.observation;
    final photo = observation.primaryPhoto;
    final collector = observation.collector;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            SizedBox(
              width: 100,
              height: 100,
              child: photo != null
                  ? _buildThumbnail(photo.localPath)
                  : _buildPlaceholder(context),
            ),

            // Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Species or "Unidentified"
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            obs.preliminaryId ?? 'Unidentified',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontStyle: obs.preliminaryId != null
                                      ? FontStyle.italic
                                      : FontStyle.normal,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (obs.isDraft)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xs,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withOpacity(0.2),
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.radiusSm),
                            ),
                            child: Text(
                              'Draft',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: AppColors.warning,
                                  ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),

                    // Date and collector
                    Text(
                      '${obs.observedAt.formatted}${collector != null ? ' • ${collector.displayName}' : ''}',
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),

                    // Specimen ID if present
                    if (obs.specimenId != null)
                      Text(
                        'ID: ${obs.specimenId}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                    const SizedBox(height: AppSpacing.xs),

                    // Bottom row: Privacy badge + photo count
                    Row(
                      children: [
                        PrivacyBadge(level: obs.privacyLevel),
                        const Spacer(),
                        if (observation.photos.length > 1)
                          Row(
                            children: [
                              Icon(
                                Icons.photo_library,
                                size: 14,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${observation.photos.length}',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        if (observation.hasUpdates)
                          Padding(
                            padding: const EdgeInsets.only(left: AppSpacing.sm),
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail(String localPath) {
    final file = File(localPath);
    return Image.file(
      file,
      fit: BoxFit.cover,
      cacheWidth: 200,
      cacheHeight: 200,
      errorBuilder: (context, error, stackTrace) {
        return _buildPlaceholder(context);
      },
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.photo,
        size: 32,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
