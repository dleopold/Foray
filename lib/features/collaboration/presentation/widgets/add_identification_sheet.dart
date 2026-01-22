import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/buttons/foray_button.dart';
import '../../../../database/database.dart';
import '../../../../database/tables/observations_table.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../observations/presentation/widgets/species_search_field.dart';

/// Bottom sheet for adding a new identification to an observation.
class AddIdentificationSheet extends ConsumerStatefulWidget {
  const AddIdentificationSheet({
    super.key,
    required this.observationId,
  });

  final String observationId;

  @override
  ConsumerState<AddIdentificationSheet> createState() =>
      _AddIdentificationSheetState();
}

class _AddIdentificationSheetState
    extends ConsumerState<AddIdentificationSheet> {
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
          // Header
          Row(
            children: [
              Expanded(
                child: Text(
                  'Add Identification',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
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
              ButtonSegment(
                  value: ConfidenceLevel.confident, label: Text('Confident')),
            ],
            selected: {_confidence},
            onSelectionChanged: (selection) {
              setState(() => _confidence = selection.first);
            },
          ),
          const SizedBox(height: AppSpacing.md),

          // Notes
          TextField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'Notes (optional)',
              hintText: 'Reasoning for this ID...',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: AppSpacing.lg),

          // Submit
          ForayButton(
            onPressed: _selectedSpecies != null ? _submit : null,
            label: 'Add Identification',
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

      // TODO: Queue for sync when Phase 9 is complete
      // await db.syncDao.enqueue(
      //   entityType: 'identification',
      //   entityId: idId,
      //   operation: SyncOperation.create,
      // );

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
