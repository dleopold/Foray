import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/buttons/foray_button.dart';
import '../../../../core/widgets/feedback/foray_snackbar.dart';
import '../../../../core/widgets/indicators/gps_accuracy_indicator.dart';
import '../../../../core/widgets/inputs/foray_text_field.dart';
import '../../../../database/database.dart';
import '../../../../database/tables/forays_table.dart';
import '../../../../database/tables/observations_table.dart';
import '../../../../database/tables/sync_queue_table.dart';
import '../../../../services/location/location_service.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../widgets/privacy_selector.dart';
import '../widgets/species_search_field.dart';
import '../widgets/spore_print_picker.dart';
import '../widgets/substrate_picker.dart';
import 'camera_capture_screen.dart';

/// Screen for creating or editing an observation.
///
/// Provides a comprehensive form for recording mushroom finds including
/// photos, GPS location, species identification, field data, and notes.
class ObservationEntryScreen extends ConsumerStatefulWidget {
  const ObservationEntryScreen({
    super.key,
    required this.forayId,
    this.observationId, // For editing existing observation
  });

  final String forayId;
  final String? observationId;

  bool get isEditing => observationId != null;

  @override
  ConsumerState<ObservationEntryScreen> createState() =>
      _ObservationEntryScreenState();
}

class _ObservationEntryScreenState
    extends ConsumerState<ObservationEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();

  // Form controllers
  final _specimenIdController = TextEditingController();
  final _collectionNumberController = TextEditingController();
  final _habitatNotesController = TextEditingController();
  final _fieldNotesController = TextEditingController();

  // State
  List<File> _photos = [];
  Position? _position;
  String? _preliminaryId;
  ConfidenceLevel _confidence = ConfidenceLevel.likely;
  String? _substrate;
  String? _sporePrintColor;
  PrivacyLevel _privacyLevel = PrivacyLevel.private;
  PrivacyLevel? _minimumPrivacyLevel;
  bool _isLoading = false;
  bool _isFetchingLocation = false;

  @override
  void initState() {
    super.initState();
    _fetchLocation();
    _loadForayDefaults();
    if (widget.isEditing) {
      _loadExistingObservation();
    }
  }

  @override
  void dispose() {
    _specimenIdController.dispose();
    _collectionNumberController.dispose();
    _habitatNotesController.dispose();
    _fieldNotesController.dispose();
    super.dispose();
  }

  Future<void> _fetchLocation() async {
    setState(() => _isFetchingLocation = true);

    final locationService = ref.read(locationServiceProvider);
    _position = await locationService.getCurrentPosition();

    if (mounted) {
      setState(() => _isFetchingLocation = false);
    }
  }

  Future<void> _loadForayDefaults() async {
    final db = ref.read(databaseProvider);
    final foray = await db.foraysDao.getForayById(widget.forayId);

    if (foray != null && mounted) {
      setState(() {
        _privacyLevel = foray.defaultPrivacy;
        _minimumPrivacyLevel = foray.defaultPrivacy;
      });

      // Auto-generate collection number
      if (!widget.isEditing) {
        final nextNum =
            await db.observationsDao.getNextCollectionNumber(widget.forayId);
        _collectionNumberController.text = nextNum.toString();
      }
    }
  }

  Future<void> _loadExistingObservation() async {
    // TODO: Implement loading existing observation for editing
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Observation' : 'New Observation'),
        actions: [
          if (!widget.isEditing)
            TextButton(
              onPressed: _saveDraft,
              child: const Text('Save Draft'),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          children: [
            // Photos section
            _buildPhotosSection(),
            const SizedBox(height: AppSpacing.lg),

            // Location section
            _buildLocationSection(),
            const SizedBox(height: AppSpacing.lg),

            // Privacy selector (prominent!)
            _buildPrivacySection(),
            const SizedBox(height: AppSpacing.lg),

            const Divider(),
            const SizedBox(height: AppSpacing.lg),

            // Identification section
            _buildIdentificationSection(),
            const SizedBox(height: AppSpacing.lg),

            // Field data section
            _buildFieldDataSection(),
            const SizedBox(height: AppSpacing.lg),

            // Notes section
            _buildNotesSection(),
            const SizedBox(height: AppSpacing.xl),

            // Submit button
            ForayButton(
              onPressed: _submit,
              label: widget.isEditing ? 'Save Changes' : 'Save Observation',
              isLoading: _isLoading,
              fullWidth: true,
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Photos',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              '${_photos.length}/${AppConstants.maxPhotosPerObservation}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _photos.length + 1,
            itemBuilder: (context, index) {
              if (index == _photos.length) {
                // Add photo button
                return _buildAddPhotoButton();
              }
              return _buildPhotoThumbnail(_photos[index], index);
            },
          ),
        ),
        if (_photos.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: Text(
              'At least one photo is required',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
            ),
          ),
      ],
    );
  }

  Widget _buildAddPhotoButton() {
    final canAdd = _photos.length < AppConstants.maxPhotosPerObservation;

    return GestureDetector(
      onTap: canAdd ? _openCamera : null,
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: AppSpacing.sm),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_a_photo,
              size: 32,
              color: canAdd
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Add Photo',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoThumbnail(File photo, int index) {
    return Stack(
      children: [
        Container(
          width: 100,
          margin: const EdgeInsets.only(right: AppSpacing.sm),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            image: DecorationImage(
              image: FileImage(photo),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 12,
          child: GestureDetector(
            onTap: () => setState(() => _photos.removeAt(index)),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Location',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (_position != null)
              GpsAccuracyIndicator(accuracyMeters: _position!.accuracy),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        if (_isFetchingLocation)
          const Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: AppSpacing.sm),
              Text('Getting location...'),
            ],
          )
        else if (_position != null)
          Row(
            children: [
              const Icon(Icons.location_on, size: 16),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  '${_position!.latitude.toStringAsFixed(5)}, ${_position!.longitude.toStringAsFixed(5)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              TextButton.icon(
                onPressed: _fetchLocation,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Refresh'),
              ),
            ],
          )
        else
          Row(
            children: [
              const Icon(Icons.location_off, size: 16, color: Colors.orange),
              const SizedBox(width: AppSpacing.xs),
              const Expanded(child: Text('Location unavailable')),
              TextButton.icon(
                onPressed: _fetchLocation,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Retry'),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildPrivacySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Privacy',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        PrivacySelector(
          selectedLevel: _privacyLevel,
          onChanged: (level) => setState(() => _privacyLevel = level),
          minimumLevel: _minimumPrivacyLevel,
        ),
      ],
    );
  }

  Widget _buildIdentificationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Identification',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),

        // Species search
        SpeciesSearchField(
          initialValue: _preliminaryId,
          onSelected: (species) => setState(() => _preliminaryId = species),
        ),
        const SizedBox(height: AppSpacing.md),

        // Confidence level
        if (_preliminaryId != null) ...[
          Text(
            'How confident are you?',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          SegmentedButton<ConfidenceLevel>(
            segments: const [
              ButtonSegment(
                value: ConfidenceLevel.guess,
                label: Text('Guess'),
              ),
              ButtonSegment(
                value: ConfidenceLevel.likely,
                label: Text('Likely'),
              ),
              ButtonSegment(
                value: ConfidenceLevel.confident,
                label: Text('Confident'),
              ),
            ],
            selected: {_confidence},
            onSelectionChanged: (selection) {
              setState(() => _confidence = selection.first);
            },
          ),
          const SizedBox(height: AppSpacing.lg),
        ],

        // Specimen ID and Collection Number row
        Row(
          children: [
            Expanded(
              child: ForayTextField(
                controller: _specimenIdController,
                label: 'Specimen ID',
                hint: 'PNWMS-001',
                suffixIcon: Icons.qr_code_scanner,
                onSuffixTap: _scanSpecimenId,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: ForayTextField(
                controller: _collectionNumberController,
                label: 'Collection #',
                hint: '1',
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFieldDataSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Field Data',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),

        // Substrate
        SubstratePicker(
          selectedSubstrate: _substrate,
          onChanged: (substrate) => setState(() => _substrate = substrate),
        ),
        const SizedBox(height: AppSpacing.md),

        // Habitat notes
        ForayTextField(
          controller: _habitatNotesController,
          label: 'Habitat Notes',
          hint: 'Under Douglas fir, mossy slope...',
          maxLines: 2,
        ),
        const SizedBox(height: AppSpacing.md),

        // Spore print color
        SporePrintPicker(
          selectedColor: _sporePrintColor,
          onChanged: (color) => setState(() => _sporePrintColor = color),
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Field Notes',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        ForayTextField(
          controller: _fieldNotesController,
          hint:
              'Color, odor, texture, staining, latex, taste (if applicable)...',
          maxLines: 4,
        ),
      ],
    );
  }

  Future<void> _openCamera() async {
    final photos = await Navigator.push<List<File>>(
      context,
      MaterialPageRoute(
        builder: (context) => CameraCaptureScreen(existingPhotos: _photos),
      ),
    );

    if (photos != null && mounted) {
      setState(() => _photos = photos);
    }
  }

  Future<void> _scanSpecimenId() async {
    // TODO: Implement barcode/QR scanning for specimen ID
    if (!mounted) return;
    ForaySnackbar.showInfo(context, 'Barcode scanning coming soon');
  }

  Future<void> _saveDraft() async {
    // Save as draft without validation
    await _saveObservation(isDraft: true);
  }

  Future<void> _submit() async {
    if (_photos.isEmpty) {
      ForaySnackbar.showWarning(context, 'Please add at least one photo');
      return;
    }

    if (_position == null) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('No Location'),
          content: const Text(
            'Location data is not available. Save observation without GPS coordinates?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Save Anyway'),
            ),
          ],
        ),
      );
      if (proceed != true) return;
    }

    await _saveObservation(isDraft: false);
  }

  Future<void> _saveObservation({required bool isDraft}) async {
    setState(() => _isLoading = true);

    try {
      final db = ref.read(databaseProvider);
      final authState = ref.read(authControllerProvider);
      final user = authState.user;

      if (user == null) throw Exception('Not authenticated');

      final observationId = widget.observationId ?? _uuid.v4();

      // Create observation
      await db.observationsDao.createObservation(ObservationsCompanion.insert(
        id: observationId,
        forayId: widget.forayId,
        collectorId: user.id,
        latitude: _position?.latitude ?? 0,
        longitude: _position?.longitude ?? 0,
        gpsAccuracy: Value(_position?.accuracy),
        altitude: Value(_position?.altitude),
        observedAt: DateTime.now(),
        specimenId: Value(_specimenIdController.text.trim().isEmpty
            ? null
            : _specimenIdController.text.trim(),),
        collectionNumber: Value(_collectionNumberController.text.trim().isEmpty
            ? null
            : _collectionNumberController.text.trim(),),
        substrate: Value(_substrate),
        habitatNotes: Value(_habitatNotesController.text.trim().isEmpty
            ? null
            : _habitatNotesController.text.trim(),),
        fieldNotes: Value(_fieldNotesController.text.trim().isEmpty
            ? null
            : _fieldNotesController.text.trim(),),
        sporePrintColor: Value(_sporePrintColor),
        preliminaryId: Value(_preliminaryId),
        preliminaryIdConfidence:
            Value(_preliminaryId != null ? _confidence : null),
        privacyLevel: Value(_privacyLevel),
        isDraft: Value(isDraft),
      ),);

      // Add photos
      for (var i = 0; i < _photos.length; i++) {
        await db.observationsDao.addPhoto(PhotosCompanion.insert(
          id: _uuid.v4(),
          observationId: observationId,
          localPath: _photos[i].path,
          sortOrder: Value(i),
        ),);
      }

      // Queue for sync (only non-drafts)
      if (!isDraft) {
        await db.syncDao.enqueue(
          entityType: 'observation',
          entityId: observationId,
          operation: SyncOperation.create,
        );
      }

      if (mounted) {
        ForaySnackbar.showSuccess(
          context,
          isDraft ? 'Draft saved' : 'Observation saved',
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ForaySnackbar.showError(
          context,
          'Error saving observation. Please try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
