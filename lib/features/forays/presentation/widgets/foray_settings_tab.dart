import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../database/database.dart';
import '../../../../database/tables/forays_table.dart';
import '../controllers/foray_detail_controller.dart';

/// Tab displaying foray settings (organizer only).
///
/// Allows organizers to complete/reopen forays, lock observations,
/// and delete the foray.
class ForaySettingsTab extends ConsumerWidget {
  const ForaySettingsTab({super.key, required this.forayId});

  final String forayId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final forayAsync = ref.watch(forayDetailProvider(forayId));

    return forayAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
      data: (foray) {
        if (foray == null) return const SizedBox.shrink();

        return ListView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          children: [
            // Status section
            Text(
              'Foray Status',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),

            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      foray.status == ForayStatus.active
                          ? Icons.play_circle
                          : Icons.check_circle,
                      color: foray.status == ForayStatus.active
                          ? Colors.green
                          : Colors.grey,
                    ),
                    title: Text(
                      foray.status == ForayStatus.active
                          ? 'Active'
                          : 'Completed',
                    ),
                    subtitle: Text(
                      foray.status == ForayStatus.active
                          ? 'Participants can add observations'
                          : 'No new observations can be added',
                    ),
                    trailing: foray.status == ForayStatus.active
                        ? TextButton(
                            onPressed: () => _completeForay(context, ref),
                            child: const Text('Complete'),
                          )
                        : TextButton(
                            onPressed: () => _reopenForay(context, ref),
                            child: const Text('Reopen'),
                          ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Lock observations
            Text(
              'Observations',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),

            Card(
              child: SwitchListTile(
                title: const Text('Lock All Observations'),
                subtitle: const Text(
                  'When locked, no one can add IDs, votes, or comments',
                ),
                value: foray.observationsLocked,
                onChanged: (value) =>
                    _setObservationsLocked(context, ref, value),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Danger zone
            Text(
              'Danger Zone',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),

            Card(
              color:
                  Theme.of(context).colorScheme.errorContainer.withOpacity(0.3),
              child: ListTile(
                leading: Icon(
                  Icons.delete_forever,
                  color: Theme.of(context).colorScheme.error,
                ),
                title: const Text('Delete Foray'),
                subtitle: const Text('This cannot be undone'),
                onTap: () => _confirmDeleteForay(context, ref),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _completeForay(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Foray?'),
        content: const Text(
          'No new observations can be added after completing. You can reopen later if needed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Complete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final db = ref.read(databaseProvider);
      await db.foraysDao.updateForayStatus(forayId, ForayStatus.completed);
    }
  }

  Future<void> _reopenForay(BuildContext context, WidgetRef ref) async {
    final db = ref.read(databaseProvider);
    await db.foraysDao.updateForayStatus(forayId, ForayStatus.active);
  }

  Future<void> _setObservationsLocked(
      BuildContext context, WidgetRef ref, bool locked,) async {
    final db = ref.read(databaseProvider);
    await db.foraysDao.setObservationsLocked(forayId, locked);
  }

  Future<void> _confirmDeleteForay(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Foray?'),
        content: const Text(
          'All observations and data will be permanently deleted. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final db = ref.read(databaseProvider);
      await db.foraysDao.deleteForay(forayId);
      if (context.mounted) {
        context.go('/');
      }
    }
  }
}
