import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../database/database.dart';
import '../../../../database/daos/collaboration_dao.dart';
import '../../../../database/tables/observations_table.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/identifications_controller.dart';
import 'add_identification_sheet.dart';

/// Widget displaying the list of identifications for an observation.
class IdentificationsList extends ConsumerWidget {
  const IdentificationsList({
    super.key,
    required this.observationId,
    required this.isLocked,
    required this.canDelete,
  });

  final String observationId;
  final bool isLocked;
  final bool canDelete; // Organizer or collector

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final identificationsAsync = ref.watch(identificationsProvider(observationId));
    final userVoteAsync = ref.watch(userVoteProvider(observationId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with add button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Identifications',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (!isLocked)
              TextButton.icon(
                onPressed: () => _showAddIdSheet(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add ID'),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),

        // Identifications list
        identificationsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error: $err')),
          data: (identifications) {
            if (identifications.isEmpty) {
              return _buildEmptyState(context);
            }

            final userVote = userVoteAsync.valueOrNull;

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: identifications.length,
              itemBuilder: (context, index) {
                final id = identifications[index];
                final isVoted = userVote == id.identification.id;

                return _IdentificationTile(
                  identification: id,
                  isVoted: isVoted,
                  isLocked: isLocked,
                  canDelete: canDelete,
                  onVote: () => _vote(ref, id.identification.id),
                  onDelete: () => _delete(context, ref, id.identification.id),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.help_outline,
              size: 48,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'No identifications yet',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (!isLocked)
              TextButton(
                onPressed: () => _showAddIdSheet(context),
                child: const Text('Be the first to ID this'),
              ),
          ],
        ),
      ),
    );
  }

  void _showAddIdSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) =>
          AddIdentificationSheet(observationId: observationId),
    );
  }

  Future<void> _vote(WidgetRef ref, String identificationId) async {
    final db = ref.read(databaseProvider);
    final authState = ref.read(authControllerProvider);
    final user = authState.user;

    if (user == null) return;

    await db.collaborationDao.addVote(identificationId, user.id);
    // Invalidate the user vote provider to refresh
    ref.invalidate(userVoteProvider(observationId));
  }

  Future<void> _delete(
      BuildContext context, WidgetRef ref, String identificationId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Identification?'),
        content: const Text('This will remove this ID and all its votes.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final db = ref.read(databaseProvider);
      await db.collaborationDao.deleteIdentification(identificationId);
    }
  }
}

class _IdentificationTile extends StatelessWidget {
  const _IdentificationTile({
    required this.identification,
    required this.isVoted,
    required this.isLocked,
    required this.canDelete,
    required this.onVote,
    required this.onDelete,
  });

  final IdentificationWithDetails identification;
  final bool isVoted;
  final bool isLocked;
  final bool canDelete;
  final VoidCallback onVote;
  final VoidCallback onDelete;

  Identification get id => identification.identification;
  User? get identifier => identification.identifier;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Vote button
                _buildVoteButton(context),
                const SizedBox(width: AppSpacing.md),

                // Species name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        id.speciesName,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                      ),
                      if (id.commonName != null)
                        Text(
                          id.commonName!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),

                // Confidence badge
                _buildConfidenceBadge(context),

                // Delete button
                if (canDelete && !isLocked)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: onDelete,
                    color: Colors.red,
                  ),
              ],
            ),

            // Notes
            if (id.notes != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                id.notes!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],

            // Identifier
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Text(
                    (identifier?.displayName ?? 'U')[0].toUpperCase(),
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  identifier?.displayName ?? 'Unknown',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoteButton(BuildContext context) {
    return InkWell(
      onTap: isLocked ? null : onVote,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isVoted
              ? AppColors.primary.withOpacity(0.2)
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: isVoted ? AppColors.primary : Colors.transparent,
          ),
        ),
        child: Column(
          children: [
            Icon(
              isVoted ? Icons.thumb_up : Icons.thumb_up_outlined,
              size: 20,
              color: isVoted ? AppColors.primary : null,
            ),
            Text(
              '${id.voteCount}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isVoted ? AppColors.primary : null,
                    fontWeight: isVoted ? FontWeight.bold : null,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfidenceBadge(BuildContext context) {
    final color = switch (id.confidence) {
      ConfidenceLevel.confident => AppColors.success,
      ConfidenceLevel.likely => AppColors.warning,
      ConfidenceLevel.guess => AppColors.syncLocal,
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Text(
        id.confidence.name,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
