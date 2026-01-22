import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../services/camera/camera_service.dart';

/// Screen for capturing multiple photos for an observation.
///
/// Shows camera preview with controls for capturing, gallery selection,
/// and camera switching. Displays thumbnail strip of captured photos.
class CameraCaptureScreen extends ConsumerStatefulWidget {
  const CameraCaptureScreen({
    super.key,
    this.existingPhotos = const [],
  });

  final List<File> existingPhotos;

  @override
  ConsumerState<CameraCaptureScreen> createState() =>
      _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends ConsumerState<CameraCaptureScreen> {
  CameraController? _controller;
  List<File> _capturedPhotos = [];
  bool _isInitializing = true;
  bool _isCapturing = false;
  String? _error;

  int get _remainingSlots =>
      AppConstants.maxPhotosPerObservation -
      widget.existingPhotos.length -
      _capturedPhotos.length;

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
      if (mounted) {
        setState(() => _isInitializing = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isInitializing = false;
          _error = 'Failed to initialize camera: $e';
        });
      }
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
                color:
                    _capturedPhotos.isNotEmpty ? AppColors.primary : Colors.grey,
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
                onPressed: () {
                  setState(() {
                    _isInitializing = true;
                    _error = null;
                  });
                  _initCamera();
                },
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
                    cacheWidth: 128,
                    cacheHeight: 128,
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
            icon:
                const Icon(Icons.photo_library, color: Colors.white, size: 32),
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
            icon:
                const Icon(Icons.flip_camera_ios, color: Colors.white, size: 32),
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
    _controller =
        await cameraService.initializeCamera(camera: cameras[nextIndex]);
    setState(() {});
  }
}
