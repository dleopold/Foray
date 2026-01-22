import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../database/daos/forays_dao.dart';
import '../controllers/foray_detail_controller.dart';

/// Tab displaying the participants of a foray.
///
/// Shows all participants with their roles. Organizers can manage
/// participants from this tab.
class ForayParticipantsTab extends ConsumerWidget {
  const ForayParticipantsTab({super.key, required this.forayId});

  final String forayId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final participantsAsync = ref.watch(forayParticipantsProvider(forayId));
    final isOrganizerAsync = ref.watch(isOrganizerProvider(forayId));

    return participantsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
      data: (participants) {
        if (participants.isEmpty) {
          return const Center(child: Text('No participants'));
        }

        final isOrganizer = isOrganizerAsync.valueOrNull ?? false;

        return ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          itemCount: participants.length,
          itemBuilder: (context, index) {
            final participant = participants[index];
            return _ParticipantListTile(
              participant: participant,
              isCurrentUserOrganizer: isOrganizer,
              onRemove: isOrganizer && !participant.isOrganizer
                  ? () => _removeParticipant(context, ref, participant)
                  : null,
            );
          },
        );
      },
    );
  }

  Future<void> _removeParticipant(
    BuildContext context,
    WidgetRef ref,
    ParticipantWithUser participant,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Participant?'),
        content: Text(
          'Remove ${participant.user.displayName} from this foray?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // TODO: Implement participant removal
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Participant removal coming soon')),
        );
      }
    }
  }
}

class _ParticipantListTile extends StatelessWidget {
  const _ParticipantListTile({
    required this.participant,
    required this.isCurrentUserOrganizer,
    this.onRemove,
  });

  final ParticipantWithUser participant;
  final bool isCurrentUserOrganizer;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: participant.user.avatarUrl != null
            ? ClipOval(
                child: Image.network(
                  participant.user.avatarUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildInitials(context),
                ),
              )
            : _buildInitials(context),
      ),
      title: Text(participant.user.displayName),
      subtitle: participant.user.email != null
          ? Text(participant.user.email!)
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (participant.isOrganizer)
            Chip(
              label: const Text('Organizer'),
              labelStyle: Theme.of(context).textTheme.labelSmall,
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
          if (onRemove != null)
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: onRemove,
              tooltip: 'Remove participant',
            ),
        ],
      ),
    );
  }

  Widget _buildInitials(BuildContext context) {
    final name = participant.user.displayName;
    final initials = name.isNotEmpty
        ? name.split(' ').map((n) => n.isNotEmpty ? n[0] : '').take(2).join()
        : '?';
    return Text(
      initials.toUpperCase(),
      style: Theme.of(context).textTheme.titleSmall,
    );
  }
}
