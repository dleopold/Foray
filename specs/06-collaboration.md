# Specification: Collaboration Features

**Phase:** 6  
**Estimated Duration:** 5-6 days  
**Dependencies:** Phase 5 complete  
**Patterns & Pitfalls:** See `PATTERNS_AND_PITFALLS.md` — [Supabase Integration](#4-supabase-integration) (Realtime), [Riverpod Pitfalls](#2-riverpod-2x-pitfalls)

---

## 1. Specimen Lookup

### 1.1 Specimen Lookup Sheet

```dart
// lib/features/observations/presentation/widgets/specimen_lookup_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:foray/core/theme/app_spacing.dart';
import 'package:foray/core/widgets/inputs/foray_text_field.dart';
import 'package:foray/database/database.dart';
import 'package:foray/routing/routes.dart';

class SpecimenLookupSheet extends ConsumerStatefulWidget {
  const SpecimenLookupSheet({super.key, required this.forayId});

  final String forayId;

  @override
  ConsumerState<SpecimenLookupSheet> createState() => _SpecimenLookupSheetState();
}

class _SpecimenLookupSheetState extends ConsumerState<SpecimenLookupSheet> {
  final _controller = TextEditingController();
  bool _showScanner = false;
  bool _isSearching = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppSpacing.radiusLg),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Find Specimen',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    IconButton(
                      icon: Icon(_showScanner ? Icons.keyboard : Icons.qr_code_scanner),
                      onPressed: () => setState(() => _showScanner = !_showScanner),
                    ),
                  ],
                ),
              ),
              
              // Content
              Expanded(
                child: _showScanner ? _buildScanner() : _buildSearchInput(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchInput() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        children: [
          ForayTextField(
            controller: _controller,
            hint: 'Enter specimen ID',
            prefixIcon: Icons.search,
            error: _error,
            onSubmitted: (_) => _search(),
            suffixIcon: Icons.arrow_forward,
            onSuffixTap: _search,
          ),
          const SizedBox(height: AppSpacing.md),
          
          if (_isSearching)
            const CircularProgressIndicator()
          else
            Text(
              'Enter the specimen ID or scan the QR code on the specimen tag',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }

  Widget _buildScanner() {
    return Stack(
      children: [
        MobileScanner(
          onDetect: (capture) {
            final barcodes = capture.barcodes;
            for (final barcode in barcodes) {
              if (barcode.rawValue != null) {
                _handleScannedCode(barcode.rawValue!);
                return;
              }
            }
          },
        ),
        Positioned(
          bottom: AppSpacing.lg,
          left: AppSpacing.screenPadding,
          right: AppSpacing.screenPadding,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text(
                'Point camera at specimen QR code',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _handleScannedCode(String code) {
    _controller.text = code;
    setState(() => _showScanner = false);
    _search();
  }

  Future<void> _search() async {
    final specimenId = _controller.text.trim();
    if (specimenId.isEmpty) {
      setState(() => _error = 'Please enter a specimen ID');
      return;
    }

    setState(() {
      _isSearching = true;
      _error = null;
    });

    try {
      final db = ref.read(databaseProvider);
      final observation = await db.observationsDao.getObservationBySpecimenId(
        widget.forayId,
        specimenId,
      );

      if (observation == null) {
        setState(() => _error = 'Specimen not found');
        return;
      }

      if (mounted) {
        Navigator.pop(context);
        context.push(
          AppRoutes.observationDetail.replaceFirst(':id', observation.id),
        );
      }
    } catch (e) {
      setState(() => _error = 'Error searching: $e');
    } finally {
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }
}
```

---

## 2. Identification Entry

### 2.1 Add Identification UI

```dart
// lib/features/collaboration/presentation/widgets/add_identification_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:foray/core/theme/app_spacing.dart';
import 'package:foray/core/widgets/buttons/foray_button.dart';
import 'package:foray/database/database.dart';
import 'package:foray/features/auth/presentation/controllers/auth_controller.dart';
import 'package:foray/features/observations/presentation/widgets/species_search_field.dart';

class AddIdentificationSheet extends ConsumerStatefulWidget {
  const AddIdentificationSheet({
    super.key,
    required this.observationId,
  });

  final String observationId;

  @override
  ConsumerState<AddIdentificationSheet> createState() => _AddIdentificationSheetState();
}

class _AddIdentificationSheetState extends ConsumerState<AddIdentificationSheet> {
  final _notesController = TextEditingController();
  String? _selectedSpecies;
  ConfidenceLevel _confidence = ConfidenceLevel.likely;
  bool _isLoading = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.screenPadding,
        right: AppSpacing.screenPadding,
        top: AppSpacing.screenPadding,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.screenPadding,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add Identification',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.lg),
          
          // Species search
          SpeciesSearchField(
            initialValue: _selectedSpecies,
            onSelected: (species) => setState(() => _selectedSpecies = species),
          ),
          const SizedBox(height: AppSpacing.md),
          
          // Confidence
          Text(
            'Confidence',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: AppSpacing.xs),
          SegmentedButton<ConfidenceLevel>(
            segments: const [
              ButtonSegment(value: ConfidenceLevel.guess, label: Text('Guess')),
              ButtonSegment(value: ConfidenceLevel.likely, label: Text('Likely')),
              ButtonSegment(value: ConfidenceLevel.confident, label: Text('Confident')),
            ],
            selected: {_confidence},
            onSelectionChanged: (s) => setState(() => _confidence = s.first),
          ),
          const SizedBox(height: AppSpacing.md),
          
          // Notes
          TextField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'Notes (optional)',
              hintText: 'Reasoning for this ID...',
            ),
            maxLines: 2,
          ),
          const SizedBox(height: AppSpacing.lg),
          
          // Submit
          ForayButton(
            onPressed: _selectedSpecies != null ? _submit : null,
            label: 'Add ID',
            isLoading: _isLoading,
            fullWidth: true,
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (_selectedSpecies == null) return;

    setState(() => _isLoading = true);

    try {
      final db = ref.read(databaseProvider);
      final authState = ref.read(authControllerProvider);
      final user = authState.user;

      if (user == null) throw Exception('Not authenticated');

      final idId = const Uuid().v4();
      
      await db.collaborationDao.addIdentification(IdentificationsCompanion.insert(
        id: idId,
        observationId: widget.observationId,
        identifierId: user.id,
        speciesName: _selectedSpecies!,
        confidence: Value(_confidence),
        notes: Value(_notesController.text.trim().isEmpty 
            ? null 
            : _notesController.text.trim()),
      ));

      // Auto-vote for own ID
      await db.collaborationDao.addVote(idId, user.id);

      // Queue for sync
      await db.syncDao.enqueue(
        entityType: 'identification',
        entityId: idId,
        operation: SyncOperation.create,
      );

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding ID: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
```

---

## 3. ID Voting System

### 3.1 Identifications List Widget

```dart
// lib/features/collaboration/presentation/widgets/identifications_list.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foray/core/theme/app_spacing.dart';
import 'package:foray/core/theme/app_colors.dart';
import 'package:foray/database/database.dart';
import 'package:foray/features/auth/presentation/controllers/auth_controller.dart';
import 'package:foray/features/collaboration/presentation/controllers/identifications_controller.dart';

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
    final userVote = ref.watch(userVoteProvider(observationId));

    return identificationsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
      data: (identifications) {
        if (identifications.isEmpty) {
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

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: identifications.length,
          itemBuilder: (context, index) {
            final id = identifications[index];
            final isVoted = userVote.valueOrNull == id.identification.id;
            
            return IdentificationTile(
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
    );
  }

  void _showAddIdSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddIdentificationSheet(observationId: observationId),
    );
  }

  Future<void> _vote(WidgetRef ref, String identificationId) async {
    final db = ref.read(databaseProvider);
    final authState = ref.read(authControllerProvider);
    final user = authState.user;
    
    if (user == null) return;
    
    await db.collaborationDao.addVote(identificationId, user.id);
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, String identificationId) async {
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

class IdentificationTile extends StatelessWidget {
  const IdentificationTile({
    super.key,
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
                  backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
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
              : Theme.of(context).colorScheme.surfaceVariant,
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
```

### 3.2 Identifications Controller

```dart
// lib/features/collaboration/presentation/controllers/identifications_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foray/database/database.dart';
import 'package:foray/features/auth/presentation/controllers/auth_controller.dart';

final identificationsProvider = StreamProvider.family<List<IdentificationWithDetails>, String>(
  (ref, observationId) {
    final db = ref.watch(databaseProvider);
    return db.collaborationDao.watchIdentificationsForObservation(observationId);
  },
);

final userVoteProvider = FutureProvider.family<String?, String>(
  (ref, observationId) async {
    final db = ref.watch(databaseProvider);
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;
    
    if (user == null) return null;
    
    return db.collaborationDao.getUserVoteForObservation(observationId, user.id);
  },
);
```

---

## 4. ID Management

Covered in the IdentificationsList widget above - deletion is handled with confirmation dialog.

---

## 5. Comment Thread

### 5.1 Comments List Widget

```dart
// lib/features/collaboration/presentation/widgets/comments_list.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:foray/core/theme/app_spacing.dart';
import 'package:foray/core/extensions/datetime_extensions.dart';
import 'package:foray/database/database.dart';
import 'package:foray/features/auth/presentation/controllers/auth_controller.dart';
import 'package:foray/features/collaboration/presentation/controllers/comments_controller.dart';

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
                final canDelete = widget.isOrganizer || 
                    comment.author?.id == currentUserId;
                
                return CommentTile(
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
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: const InputDecoration(
                    hintText: 'Add a comment...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
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
      ));

      await db.syncDao.enqueue(
        entityType: 'comment',
        entityId: commentId,
        operation: SyncOperation.create,
      );

      _commentController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error posting comment: $e')),
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

class CommentTile extends StatelessWidget {
  const CommentTile({
    super.key,
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
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
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
```

### 5.2 Comments Controller

```dart
// lib/features/collaboration/presentation/controllers/comments_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foray/database/database.dart';

final commentsProvider = StreamProvider.family<List<CommentWithAuthor>, String>(
  (ref, observationId) {
    final db = ref.watch(databaseProvider);
    return db.collaborationDao.watchCommentsForObservation(observationId);
  },
);
```

---

## 7. Real-time Updates (Supabase)

### 7.1 Realtime Subscription Service

```dart
// lib/services/realtime/realtime_service.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:foray/database/database.dart';
import 'package:foray/services/supabase_service.dart';

final realtimeServiceProvider = Provider<RealtimeService>((ref) {
  return RealtimeService(
    ref.watch(supabaseClientProvider),
    ref.watch(databaseProvider),
  );
});

class RealtimeService {
  RealtimeService(this._supabase, this._db);

  final SupabaseClient _supabase;
  final AppDatabase _db;
  
  final Map<String, RealtimeChannel> _channels = {};

  void subscribeToForay(String forayId) {
    if (_channels.containsKey(forayId)) return;

    final channel = _supabase.channel('foray:$forayId');
    
    channel
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'observations',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'foray_id',
          value: forayId,
        ),
        callback: (payload) => _handleObservationChange(payload),
      )
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'identifications',
        callback: (payload) => _handleIdentificationChange(payload),
      )
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'comments',
        callback: (payload) => _handleCommentChange(payload),
      )
      .subscribe();

    _channels[forayId] = channel;
  }

  void unsubscribeFromForay(String forayId) {
    final channel = _channels.remove(forayId);
    if (channel != null) {
      _supabase.removeChannel(channel);
    }
  }

  void _handleObservationChange(PostgresChangePayload payload) {
    // Update local database based on remote change
    // Implementation depends on sync strategy
  }

  void _handleIdentificationChange(PostgresChangePayload payload) {
    // Update local database
  }

  void _handleCommentChange(PostgresChangePayload payload) {
    // Update local database
  }

  void dispose() {
    for (final channel in _channels.values) {
      _supabase.removeChannel(channel);
    }
    _channels.clear();
  }
}
```

---

## Acceptance Criteria

Phase 6 is complete when:

1. [ ] Specimen lookup by text search works
2. [ ] Specimen lookup by QR/barcode scan works
3. [ ] Users can add identifications with species search
4. [ ] Confidence levels work correctly
5. [ ] Voting works (one vote per user, can change)
6. [ ] Vote counts update and sort correctly
7. [ ] ID deletion works for creators and organizers
8. [ ] Comment thread displays in order
9. [ ] Users can post comments
10. [ ] Comment deletion works for authors and organizers
11. [ ] Locked observations prevent new IDs/votes/comments
12. [ ] Real-time updates work when online
