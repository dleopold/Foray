import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/extensions/datetime_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/feedback/foray_snackbar.dart';
import '../../../../database/database.dart';
import '../../../../database/daos/collaboration_dao.dart';
import '../../../../database/tables/sync_queue_table.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/comments_controller.dart';

/// Widget displaying the comment thread for an observation.
class CommentsList extends ConsumerStatefulWidget {
  const CommentsList({
    super.key,
    required this.observationId,
    required this.isLocked,
    required this.isOrganizer,
  });

  final String observationId;
  final bool isLocked;
  final bool isOrganizer;

  @override
  ConsumerState<CommentsList> createState() => _CommentsListState();
}

class _CommentsListState extends ConsumerState<CommentsList> {
  final _commentController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final commentsAsync = ref.watch(commentsProvider(widget.observationId));
    final authState = ref.watch(authControllerProvider);
    final currentUserId = authState.user?.id;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Discussion',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.md),

        // Comments list
        commentsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Text('Error: $err'),
          data: (comments) {
            if (comments.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                child: Center(
                  child: Text(
                    'No comments yet',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: comments.length,
              itemBuilder: (context, index) {
                final comment = comments[index];
                final canDelete =
                    widget.isOrganizer || comment.author?.id == currentUserId;

                return _CommentTile(
                  comment: comment,
                  canDelete: canDelete && !widget.isLocked,
                  onDelete: () => _deleteComment(comment.comment.id),
                );
              },
            );
          },
        ),

        // Comment input
        if (!widget.isLocked) ...[
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: const InputDecoration(
                    hintText: 'Add a comment...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  minLines: 1,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              IconButton.filled(
                onPressed: _isSending ? null : _sendComment,
                icon: _isSending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Future<void> _sendComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    setState(() => _isSending = true);

    try {
      final db = ref.read(databaseProvider);
      final authState = ref.read(authControllerProvider);
      final user = authState.user;

      if (user == null) throw Exception('Not authenticated');

      final commentId = const Uuid().v4();

      await db.collaborationDao.addComment(CommentsCompanion.insert(
        id: commentId,
        observationId: widget.observationId,
        authorId: user.id,
        content: content,
      ),);

      // Queue for sync
      await db.syncDao.enqueue(
        entityType: 'comment',
        entityId: commentId,
        operation: SyncOperation.create,
      );

      _commentController.clear();
    } catch (e) {
      if (mounted) {
        ForaySnackbar.showError(
          context,
          'Could not post comment. Please try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  Future<void> _deleteComment(String commentId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Comment?'),
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
      await db.collaborationDao.deleteComment(commentId);
    }
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({
    required this.comment,
    required this.canDelete,
    required this.onDelete,
  });

  final CommentWithAuthor comment;
  final bool canDelete;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor:
                Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Text(
              (comment.author?.displayName ?? 'U')[0].toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.author?.displayName ?? 'Unknown',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      comment.comment.createdAt.relative,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  comment.comment.content,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          if (canDelete)
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18),
              onPressed: onDelete,
              color: Colors.red,
            ),
        ],
      ),
    );
  }
}
