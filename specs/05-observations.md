# Specification: Observation Entry & Management

**Phase:** 5  
**Estimated Duration:** 6-7 days  
**Dependencies:** Phase 4 complete

---

## 1. Camera Capture Flow

### 1.1 Camera Service

```dart
// lib/services/camera/camera_service.dart
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

final cameraServiceProvider = Provider<CameraService>((ref) {
  return CameraService();
});

class CameraService {
  final _uuid = const Uuid();
  final _picker = ImagePicker();
  
  List<CameraDescription>? _cameras;
  CameraController? _controller;

  Future<List<CameraDescription>> getCameras() async {
    _cameras ??= await availableCameras();
    return _cameras!;
  }

  Future<CameraController> initializeCamera({
    CameraDescription? camera,
    ResolutionPreset resolution = ResolutionPreset.high,
  }) async {
    final cameras = await getCameras();
    final selectedCamera = camera ?? cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      selectedCamera,
      resolution,
      enableAudio: false,
    );

    await _controller!.initialize();
    return _controller!;
  }

  Future<File?> capturePhoto() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return null;
    }

    try {
      final xFile = await _controller!.takePicture();
      final savedPath = await _saveToLocalStorage(File(xFile.path));
      return savedPath;
    } catch (e) {
      return null;
    }
  }

  Future<File?> pickFromGallery() async {
    final xFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 2048,
      maxHeight: 2048,
      imageQuality: 85,
    );

    if (xFile == null) return null;

    return _saveToLocalStorage(File(xFile.path));
  }

  Future<List<File>> pickMultipleFromGallery({int maxImages = 10}) async {
    final xFiles = await _picker.pickMultiImage(
      maxWidth: 2048,
      maxHeight: 2048,
      imageQuality: 85,
    );

    final files = <File>[];
    for (final xFile in xFiles.take(maxImages)) {
      final saved = await _saveToLocalStorage(File(xFile.path));
      if (saved != null) files.add(saved);
    }
    return files;
  }

  Future<File?> _saveToLocalStorage(File sourceFile) async {
    final dir = await getApplicationDocumentsDirectory();
    final photosDir = Directory(p.join(dir.path, 'photos'));
    if (!await photosDir.exists()) {
      await photosDir.create(recursive: true);
    }

    final fileName = '${_uuid.v4()}.jpg';
    final destPath = p.join(photosDir.path, fileName);
    
    return sourceFile.copy(destPath);
  }

  void dispose() {
    _controller?.dispose();
    _controller = null;
  }
}
```

### 1.2 Camera Capture Screen

```dart
// lib/features/observations/presentation/screens/camera_capture_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:foray/core/theme/app_spacing.dart';
import 'package:foray/core/theme/app_colors.dart';
import 'package:foray/services/camera/camera_service.dart';
import 'package:foray/core/constants/app_constants.dart';

class CameraCaptureScreen extends ConsumerStatefulWidget {
  const CameraCaptureScreen({
    super.key,
    this.existingPhotos = const [],
  });

  final List<File> existingPhotos;

  @override
  ConsumerState<CameraCaptureScreen> createState() => _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends ConsumerState<CameraCaptureScreen> {
  CameraController? _controller;
  List<File> _capturedPhotos = [];
  bool _isInitializing = true;
  bool _isCapturing = false;
  String? _error;

  int get _remainingSlots => AppConstants.maxPhotosPerObservation - 
      widget.existingPhotos.length - _capturedPhotos.length;

  @override
  void initState() {
    super.initState();
    _capturedPhotos = List.from(widget.existingPhotos);
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameraService = ref.read(cameraServiceProvider);
      _controller = await cameraService.initializeCamera();
      setState(() => _isInitializing = false);
    } catch (e) {
      setState(() {
        _isInitializing = false;
        _error = 'Failed to initialize camera: $e';
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            _buildTopBar(),
            
            // Camera preview
            Expanded(
              child: _buildCameraPreview(),
            ),
            
            // Photo thumbnails
            if (_capturedPhotos.isNotEmpty) _buildThumbnailStrip(),
            
            // Capture controls
            _buildCaptureControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      color: Colors.black54,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            '${_capturedPhotos.length}/${AppConstants.maxPhotosPerObservation} photos',
            style: const TextStyle(color: Colors.white),
          ),
          TextButton(
            onPressed: _capturedPhotos.isNotEmpty
                ? () => Navigator.pop(context, _capturedPhotos)
                : null,
            child: Text(
              'Done',
              style: TextStyle(
                color: _capturedPhotos.isNotEmpty ? AppColors.primary : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (_isInitializing) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 48),
              const SizedBox(height: AppSpacing.md),
              Text(
                _error!,
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              ElevatedButton(
                onPressed: _initCamera,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_controller == null || !_controller!.value.isInitialized) {
      return const SizedBox.shrink();
    }

    return CameraPreview(_controller!);
  }

  Widget _buildThumbnailStrip() {
    return Container(
      height: 80,
      color: Colors.black87,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        itemCount: _capturedPhotos.length,
        itemBuilder: (context, index) {
          final photo = _capturedPhotos[index];
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  child: Image.file(
                    photo,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _capturedPhotos.removeAt(index));
                    },
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(2),
                      child: const Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCaptureControls() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      color: Colors.black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Gallery button
          IconButton(
            icon: const Icon(Icons.photo_library, color: Colors.white, size: 32),
            onPressed: _remainingSlots > 0 ? _pickFromGallery : null,
          ),
          
          // Capture button
          GestureDetector(
            onTap: _remainingSlots > 0 && !_isCapturing ? _capturePhoto : null,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                color: _isCapturing ? Colors.grey : Colors.transparent,
              ),
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _remainingSlots > 0 ? Colors.white : Colors.grey,
                ),
              ),
            ),
          ),
          
          // Switch camera button
          IconButton(
            icon: const Icon(Icons.flip_camera_ios, color: Colors.white, size: 32),
            onPressed: _switchCamera,
          ),
        ],
      ),
    );
  }

  Future<void> _capturePhoto() async {
    if (_isCapturing) return;
    
    setState(() => _isCapturing = true);
    
    try {
      final cameraService = ref.read(cameraServiceProvider);
      final photo = await cameraService.capturePhoto();
      
      if (photo != null && mounted) {
        setState(() => _capturedPhotos.add(photo));
      }
    } finally {
      if (mounted) {
        setState(() => _isCapturing = false);
      }
    }
  }

  Future<void> _pickFromGallery() async {
    final cameraService = ref.read(cameraServiceProvider);
    final photos = await cameraService.pickMultipleFromGallery(
      maxImages: _remainingSlots,
    );
    
    if (mounted && photos.isNotEmpty) {
      setState(() => _capturedPhotos.addAll(photos));
    }
  }

  Future<void> _switchCamera() async {
    final cameraService = ref.read(cameraServiceProvider);
    final cameras = await cameraService.getCameras();
    
    if (cameras.length < 2) return;
    
    final currentIndex = cameras.indexOf(_controller!.description);
    final nextIndex = (currentIndex + 1) % cameras.length;
    
    _controller?.dispose();
    _controller = await cameraService.initializeCamera(camera: cameras[nextIndex]);
    setState(() {});
  }
}
```

---

## 2. GPS Capture

### 2.1 Location Service

```dart
// lib/services/location/location_service.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:foray/core/constants/app_constants.dart';

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

class LocationService {
  Future<bool> checkPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  Future<Position?> getCurrentPosition({
    LocationAccuracy accuracy = LocationAccuracy.best,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final hasPermission = await checkPermission();
    if (!hasPermission) return null;

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: accuracy,
        timeLimit: timeout,
      );
    } catch (e) {
      return null;
    }
  }

  Stream<Position> getPositionStream({
    LocationAccuracy accuracy = LocationAccuracy.best,
    int distanceFilter = 5,
  }) {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter,
      ),
    );
  }

  Future<double> distanceBetween(
    double startLat,
    double startLon,
    double endLat,
    double endLon,
  ) async {
    return Geolocator.distanceBetween(startLat, startLon, endLat, endLon);
  }

  double bearingBetween(
    double startLat,
    double startLon,
    double endLat,
    double endLon,
  ) {
    return Geolocator.bearingBetween(startLat, startLon, endLat, endLon);
  }
}

// Position state for observation entry
final currentPositionProvider = FutureProvider<Position?>((ref) async {
  final locationService = ref.watch(locationServiceProvider);
  return locationService.getCurrentPosition();
});
```

---

## 3. Observation Entry Form

### 3.1 Observation Entry Screen

```dart
// lib/features/observations/presentation/screens/observation_entry_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:foray/core/theme/app_spacing.dart';
import 'package:foray/core/widgets/buttons/foray_button.dart';
import 'package:foray/core/widgets/inputs/foray_text_field.dart';
import 'package:foray/core/widgets/indicators/privacy_badge.dart';
import 'package:foray/core/widgets/indicators/gps_accuracy_indicator.dart';
import 'package:foray/core/constants/privacy_levels.dart';
import 'package:foray/core/constants/app_constants.dart';
import 'package:foray/database/database.dart';
import 'package:foray/services/location/location_service.dart';
import 'package:foray/features/auth/presentation/controllers/auth_controller.dart';
import 'package:foray/features/observations/presentation/screens/camera_capture_screen.dart';
import 'package:foray/features/observations/presentation/widgets/substrate_picker.dart';
import 'package:foray/features/observations/presentation/widgets/spore_print_picker.dart';
import 'package:foray/features/observations/presentation/widgets/privacy_selector.dart';
import 'package:foray/features/observations/presentation/widgets/species_search_field.dart';
import 'package:foray/routing/routes.dart';

class ObservationEntryScreen extends ConsumerStatefulWidget {
  const ObservationEntryScreen({
    super.key,
    required this.forayId,
    this.observationId, // For editing
  });

  final String forayId;
  final String? observationId;

  bool get isEditing => observationId != null;

  @override
  ConsumerState<ObservationEntryScreen> createState() => _ObservationEntryScreenState();
}

class _ObservationEntryScreenState extends ConsumerState<ObservationEntryScreen> {
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
      });
      
      // Auto-generate collection number
      final nextNum = await db.observationsDao.getNextCollectionNumber(widget.forayId);
      _collectionNumberController.text = nextNum.toString();
    }
  }

  Future<void> _loadExistingObservation() async {
    // Implementation for loading existing observation for editing
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
          color: Theme.of(context).colorScheme.surfaceVariant,
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
              GPSAccuracyIndicator(accuracyMeters: _position!.accuracy),
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
              Text(
                '${_position!.latitude.toStringAsFixed(5)}, ${_position!.longitude.toStringAsFixed(5)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Spacer(),
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
              const Text('Location unavailable'),
              const Spacer(),
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
        ),
        
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, size: 16),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Who can see: ${_getPrivacyDescription()}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getPrivacyDescription() {
    switch (_privacyLevel) {
      case PrivacyLevel.private:
        return 'Only you';
      case PrivacyLevel.foray:
        return 'Foray participants';
      case PrivacyLevel.publicExact:
        return 'Everyone (exact location)';
      case PrivacyLevel.publicObscured:
        return 'Everyone (location hidden within ~10km)';
    }
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
          hint: 'Color, odor, texture, staining, latex, taste (if applicable)...',
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
  }

  Future<void> _saveDraft() async {
    // Save as draft without validation
    await _saveObservation(isDraft: true);
  }

  Future<void> _submit() async {
    if (_photos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one photo')),
      );
      return;
    }
    
    if (_position == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Waiting for location...')),
      );
      return;
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
            : _specimenIdController.text.trim()),
        collectionNumber: Value(_collectionNumberController.text.trim().isEmpty
            ? null
            : _collectionNumberController.text.trim()),
        substrate: Value(_substrate),
        habitatNotes: Value(_habitatNotesController.text.trim().isEmpty
            ? null
            : _habitatNotesController.text.trim()),
        fieldNotes: Value(_fieldNotesController.text.trim().isEmpty
            ? null
            : _fieldNotesController.text.trim()),
        sporePrintColor: Value(_sporePrintColor),
        preliminaryId: Value(_preliminaryId),
        preliminaryIdConfidence: Value(_preliminaryId != null ? _confidence : null),
        privacyLevel: Value(_privacyLevel),
        isDraft: Value(isDraft),
      ));
      
      // Add photos
      for (var i = 0; i < _photos.length; i++) {
        await db.observationsDao.addPhoto(PhotosCompanion.insert(
          id: _uuid.v4(),
          observationId: observationId,
          localPath: _photos[i].path,
          sortOrder: Value(i),
        ));
      }
      
      // Queue for sync
      if (!isDraft) {
        await db.syncDao.enqueue(
          entityType: 'observation',
          entityId: observationId,
          operation: SyncOperation.create,
        );
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isDraft ? 'Draft saved' : 'Observation saved')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving observation: $e')),
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

## 4. Species Search

### 4.1 Species Search Field

```dart
// lib/features/observations/presentation/widgets/species_search_field.dart
import 'package:flutter/material.dart';
import 'package:foray/core/theme/app_spacing.dart';

class SpeciesSearchField extends StatefulWidget {
  const SpeciesSearchField({
    super.key,
    this.initialValue,
    required this.onSelected,
  });

  final String? initialValue;
  final ValueChanged<String?> onSelected;

  @override
  State<SpeciesSearchField> createState() => _SpeciesSearchFieldState();
}

class _SpeciesSearchFieldState extends State<SpeciesSearchField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  List<SpeciesResult> _results = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      _controller.text = widget.initialValue!;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Species (preliminary ID)',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: AppSpacing.xs),
        
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: 'Search species name...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _controller.clear();
                      widget.onSelected(null);
                      setState(() => _results = []);
                    },
                  )
                : null,
          ),
          onChanged: _onSearchChanged,
        ),
        
        // Results dropdown
        if (_results.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final result = _results[index];
                return ListTile(
                  title: Text(
                    result.scientificName,
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                  subtitle: result.commonName != null
                      ? Text(result.commonName!)
                      : null,
                  onTap: () {
                    _controller.text = result.scientificName;
                    widget.onSelected(result.scientificName);
                    setState(() => _results = []);
                    _focusNode.unfocus();
                  },
                );
              },
            ),
          ),
        
        if (_isSearching)
          const Padding(
            padding: EdgeInsets.all(AppSpacing.sm),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _onSearchChanged(String query) async {
    if (query.length < 2) {
      setState(() => _results = []);
      return;
    }

    setState(() => _isSearching = true);

    // TODO: Replace with actual species database search
    // For now, use mock data
    await Future.delayed(const Duration(milliseconds: 300));
    
    final mockResults = _mockSpeciesSearch(query);
    
    if (mounted) {
      setState(() {
        _results = mockResults;
        _isSearching = false;
      });
    }
  }

  List<SpeciesResult> _mockSpeciesSearch(String query) {
    final allSpecies = [
      SpeciesResult('Cantharellus cibarius', 'Golden Chanterelle'),
      SpeciesResult('Cantharellus formosus', 'Pacific Golden Chanterelle'),
      SpeciesResult('Cantharellus cascadensis', 'Cascade Chanterelle'),
      SpeciesResult('Amanita muscaria', 'Fly Agaric'),
      SpeciesResult('Amanita phalloides', 'Death Cap'),
      SpeciesResult('Boletus edulis', 'Porcini'),
      SpeciesResult('Laetiporus sulphureus', 'Chicken of the Woods'),
      SpeciesResult('Morchella esculenta', 'Morel'),
      SpeciesResult('Grifola frondosa', 'Maitake'),
      SpeciesResult('Pleurotus ostreatus', 'Oyster Mushroom'),
    ];

    final lowerQuery = query.toLowerCase();
    return allSpecies.where((s) =>
        s.scientificName.toLowerCase().contains(lowerQuery) ||
        (s.commonName?.toLowerCase().contains(lowerQuery) ?? false)
    ).toList();
  }
}

class SpeciesResult {
  final String scientificName;
  final String? commonName;

  SpeciesResult(this.scientificName, [this.commonName]);
}
```

---

## 5-9. Remaining Sections

The remaining sections (Specimen ID, Observation Persistence, List/Detail Views, Editing) follow similar patterns. Key points:

### 5.5 Specimen ID Field
- Text input with optional barcode scanner
- Uses `mobile_scanner` package for QR/barcode scanning
- Validates uniqueness within foray

### 5.6 Observation Persistence
- Auto-save drafts every 30 seconds
- Explicit save creates non-draft observation
- Photos compressed before storage
- Sync queue entry created on save

### 5.7 Observation List View
- Uses `ObservationListTile` component
- Shows thumbnail, species, date, privacy badge
- "Updated" indicator when `updatedAt > lastViewedAt`
- Supports search and sort

### 5.8 Observation Detail View
- Full photo gallery (swipeable)
- All metadata displayed
- Mini-map with location
- "Navigate to" button
- IDs and Comments sections (Phase 6)

### 5.9 Observation Editing
- Same form as creation, pre-populated
- Respects foray lock state
- Tracks changes for sync

---

## Acceptance Criteria

Phase 5 is complete when:

1. [ ] Camera capture works with multiple photos
2. [ ] Gallery picker works
3. [ ] Photos can be deleted before save
4. [ ] GPS capture shows accuracy indicator
5. [ ] Privacy selector is prominent and functional
6. [ ] Species search/autocomplete works
7. [ ] All field data inputs work (substrate, habitat, spore print)
8. [ ] Observations save to local database
9. [ ] Observations appear in foray feed
10. [ ] Observation detail view shows all data
11. [ ] Edit mode works correctly
12. [ ] Sync queue entries created for new observations
