import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/datetime_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/indicators/privacy_badge.dart';
import '../../../../database/database.dart';
import '../../../../database/daos/observations_dao.dart';
import '../../../../routing/routes.dart';
import '../../../collaboration/presentation/widgets/comments_list.dart';
import '../../../collaboration/presentation/widgets/identifications_list.dart';
import '../controllers/observation_controller.dart';

/// Screen displaying full details of an observation.
///
/// Shows photo gallery, all metadata, location, identifications, and comments.
class ObservationDetailScreen extends ConsumerWidget {
  const ObservationDetailScreen({
    super.key,
    required this.observationId,
  });

  final String observationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final observationAsync = ref.watch(observationDetailProvider(observationId));

    return observationAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: $err')),
      ),
      data: (observation) {
        if (observation == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Observation not found')),
          );
        }

        return _ObservationDetailContent(observation: observation);
      },
    );
  }
}

class _ObservationDetailContent extends StatefulWidget {
  const _ObservationDetailContent({required this.observation});

  final ObservationWithDetails observation;

  @override
  State<_ObservationDetailContent> createState() =>
      _ObservationDetailContentState();
}

class _ObservationDetailContentState extends State<_ObservationDetailContent> {
  int _currentPhotoIndex = 0;
  final _pageController = PageController();

  Observation get obs => widget.observation.observation;
  List<Photo> get photos => widget.observation.photos;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar with photo gallery
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildPhotoGallery(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  // TODO: Navigate to edit screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Edit coming soon')),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.navigation),
                onPressed: () => context.push(
                  AppRoutes.navigate.replaceFirst(':observationId', obs.id),
                ),
                tooltip: 'Navigate to location',
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Species name
                  _buildSpeciesHeader(),
                  const SizedBox(height: AppSpacing.lg),

                  // Quick info row
                  _buildQuickInfo(),
                  const SizedBox(height: AppSpacing.lg),

                  const Divider(),
                  const SizedBox(height: AppSpacing.lg),

                  // Location
                  _buildSection(
                    'Location',
                    _buildLocationInfo(),
                  ),

                  // Field data
                  if (_hasFieldData()) ...[
                    const SizedBox(height: AppSpacing.lg),
                    _buildSection(
                      'Field Data',
                      _buildFieldData(),
                    ),
                  ],

                  // Notes
                  if (obs.fieldNotes != null && obs.fieldNotes!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.lg),
                    _buildSection(
                      'Field Notes',
                      Text(obs.fieldNotes!),
                    ),
                  ],

                  // Identifications section
                  const SizedBox(height: AppSpacing.lg),
                  IdentificationsList(
                    observationId: obs.id,
                    isLocked: false, // TODO: Get from foray state
                    canDelete: true, // TODO: Check if collector or organizer
                  ),

                  // Comments section
                  const SizedBox(height: AppSpacing.lg),
                  CommentsList(
                    observationId: obs.id,
                    isLocked: false, // TODO: Get from foray state
                    isOrganizer: false, // TODO: Check if organizer
                  ),

                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoGallery() {
    if (photos.isEmpty) {
      return Container(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: const Center(
          child: Icon(Icons.photo, size: 64),
        ),
      );
    }

    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() => _currentPhotoIndex = index);
          },
          itemCount: photos.length,
          itemBuilder: (context, index) {
            final photo = photos[index];
            return GestureDetector(
              onTap: () => _openFullScreenGallery(index),
              child: Image.file(
                File(photo.localPath),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: const Center(child: Icon(Icons.broken_image, size: 48)),
                ),
              ),
            );
          },
        ),
        if (photos.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                photos.length,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index == _currentPhotoIndex
                        ? Colors.white
                        : Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _openFullScreenGallery(int initialIndex) {
    // TODO: Implement full screen gallery viewer
  }

  Widget _buildSpeciesHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                obs.preliminaryId ?? 'Unidentified',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontStyle: obs.preliminaryId != null
                          ? FontStyle.italic
                          : FontStyle.normal,
                    ),
              ),
              if (obs.preliminaryIdConfidence != null)
                Text(
                  'Confidence: ${obs.preliminaryIdConfidence!.name}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
        ),
        if (obs.isDraft)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Text(
              'Draft',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.warning,
                  ),
            ),
          ),
      ],
    );
  }

  Widget _buildQuickInfo() {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.sm,
      children: [
        _QuickInfoChip(
          icon: Icons.calendar_today,
          label: obs.observedAt.formatted,
        ),
        if (widget.observation.collector != null)
          _QuickInfoChip(
            icon: Icons.person,
            label: widget.observation.collector!.displayName,
          ),
        if (obs.specimenId != null)
          _QuickInfoChip(
            icon: Icons.qr_code,
            label: obs.specimenId!,
          ),
        if (obs.collectionNumber != null)
          _QuickInfoChip(
            icon: Icons.tag,
            label: '#${obs.collectionNumber}',
          ),
        PrivacyBadge(level: obs.privacyLevel),
      ],
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        content,
      ],
    );
  }

  Widget _buildLocationInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.location_on, size: 16),
            const SizedBox(width: AppSpacing.xs),
            Text(
              '${obs.latitude.toStringAsFixed(5)}, ${obs.longitude.toStringAsFixed(5)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        if (obs.gpsAccuracy != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Accuracy: ±${obs.gpsAccuracy!.round()}m',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        if (obs.altitude != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Altitude: ${obs.altitude!.round()}m',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        // TODO: Add mini-map
      ],
    );
  }

  bool _hasFieldData() {
    return obs.substrate != null ||
        obs.habitatNotes != null ||
        obs.sporePrintColor != null;
  }

  Widget _buildFieldData() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (obs.substrate != null)
          _buildFieldDataRow('Substrate', obs.substrate!),
        if (obs.habitatNotes != null)
          _buildFieldDataRow('Habitat', obs.habitatNotes!),
        if (obs.sporePrintColor != null)
          _buildFieldDataRow('Spore Print', obs.sporePrintColor!),
      ],
    );
  }

  Widget _buildFieldDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

}

class _QuickInfoChip extends StatelessWidget {
  const _QuickInfoChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
