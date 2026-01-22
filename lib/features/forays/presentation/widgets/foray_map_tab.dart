import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';

/// Tab displaying the map view for a foray.
///
/// Shows observation locations on an interactive map.
/// This is a placeholder that will be implemented in Phase 8 (Maps).
class ForayMapTab extends ConsumerWidget {
  const ForayMapTab({super.key, required this.forayId});

  final String forayId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Implement map view in Phase 8
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Map View',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Observation locations will appear here',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
