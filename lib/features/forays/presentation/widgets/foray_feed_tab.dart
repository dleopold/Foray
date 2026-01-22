import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../routing/routes.dart';
import '../../../observations/presentation/controllers/observation_controller.dart';
import '../../../observations/presentation/widgets/observation_card.dart';

/// Tab displaying the observation feed for a foray.
///
/// Shows all observations in the foray in reverse chronological order.
class ForayFeedTab extends ConsumerWidget {
  const ForayFeedTab({super.key, required this.forayId});

  final String forayId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final observationsAsync = ref.watch(forayObservationsProvider(forayId));

    return observationsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (observations) {
        if (observations.isEmpty) {
          return _buildEmptyState(context);
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(forayObservationsProvider(forayId));
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            itemCount: observations.length,
            itemBuilder: (context, index) {
              final observation = observations[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: ObservationCard(
                  observation: observation,
                  onTap: () => context.push(
                    AppRoutes.observationDetail
                        .replaceFirst(':id', observation.observation.id),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No observations yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Tap the button below to add your first observation',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
