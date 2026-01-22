import 'dart:math';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/buttons/foray_button.dart';
import '../../../../core/widgets/inputs/foray_text_field.dart';
import '../../../../core/constants/privacy_levels.dart' as constants;
import '../../../../database/database.dart';
import '../../../../database/tables/forays_table.dart';
import '../../../../routing/routes.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

/// Screen for creating a new group foray.
///
/// Solo forays are created from the foray list screen with a single tap.
/// This screen provides full configuration options for group forays.
class CreateForayScreen extends ConsumerStatefulWidget {
  const CreateForayScreen({super.key});

  @override
  ConsumerState<CreateForayScreen> createState() => _CreateForayScreenState();
}

class _CreateForayScreenState extends ConsumerState<CreateForayScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  DateTime _date = DateTime.now();
  PrivacyLevel _defaultPrivacy = PrivacyLevel.foray;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Foray'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          children: [
            // Name
            ForayTextField(
              controller: _nameController,
              label: 'Foray Name',
              hint: 'e.g., Fall Mushroom Walk',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),

            // Description
            ForayTextField(
              controller: _descriptionController,
              label: 'Description (optional)',
              hint: 'What will you be looking for?',
              maxLines: 3,
            ),
            const SizedBox(height: AppSpacing.md),

            // Date
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Date'),
              subtitle: Text(_date.toString().split(' ')[0]),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate:
                      DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) {
                  setState(() => _date = picked);
                }
              },
            ),
            const Divider(),

            // Location name
            ForayTextField(
              controller: _locationController,
              label: 'Location (optional)',
              hint: 'e.g., Mount Rainier National Park',
              prefixIcon: Icons.location_on_outlined,
            ),
            const SizedBox(height: AppSpacing.lg),

            // Default privacy
            Text(
              'Default Privacy for Observations',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Participants can always increase privacy but cannot decrease it below this level.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.md),

            // Privacy level options - using constants for labels
            ...PrivacyLevel.values.map((level) {
              final constantsLevel = _getConstantsPrivacyLevel(level);
              return RadioListTile<PrivacyLevel>(
                title: Text(constantsLevel?.label ?? level.name),
                subtitle: Text(constantsLevel?.description ?? ''),
                value: level,
                groupValue: _defaultPrivacy,
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _defaultPrivacy = value);
                  }
                },
              );
            }),

            const SizedBox(height: AppSpacing.xl),

            // Create button
            ForayButton(
              onPressed: _submit,
              label: 'Create Foray',
              isLoading: _isLoading,
              fullWidth: true,
            ),
          ],
        ),
      ),
    );
  }

  /// Map database PrivacyLevel to constants PrivacyLevel for UI display.
  constants.PrivacyLevel? _getConstantsPrivacyLevel(PrivacyLevel level) {
    return switch (level) {
      PrivacyLevel.private => constants.PrivacyLevel.private,
      PrivacyLevel.foray => constants.PrivacyLevel.foray,
      PrivacyLevel.publicExact => constants.PrivacyLevel.publicExact,
      PrivacyLevel.publicObscured => constants.PrivacyLevel.publicObscured,
    };
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final db = ref.read(databaseProvider);
      final authState = ref.read(authControllerProvider);
      final user = authState.user;

      if (user == null) throw Exception('Not authenticated');

      final forayId = const Uuid().v4();
      final joinCode = _generateJoinCode();

      await db.foraysDao.createForay(ForaysCompanion.insert(
        id: forayId,
        creatorId: user.id,
        name: _nameController.text.trim(),
        description: Value(_descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim()),
        date: _date,
        locationName: Value(_locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim()),
        defaultPrivacy: Value(_defaultPrivacy),
        joinCode: Value(joinCode),
        isSolo: const Value(false),
      ));

      await db.foraysDao.addParticipant(
        forayId: forayId,
        userId: user.id,
        role: ParticipantRole.organizer,
      );

      // TODO: Queue for sync when sync is implemented
      // await db.syncDao.enqueue(
      //   entityType: 'foray',
      //   entityId: forayId,
      //   operation: SyncOperation.create,
      // );

      if (mounted) {
        context.go(AppRoutes.forayDetail.replaceFirst(':id', forayId));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating foray: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Generate a random 6-character join code.
  String _generateJoinCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random.secure();
    return List.generate(6, (_) => chars[random.nextInt(chars.length)]).join();
  }
}
