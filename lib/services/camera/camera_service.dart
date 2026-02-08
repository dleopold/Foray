import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';

/// Provides the camera service singleton.
final cameraServiceProvider = Provider<CameraService>((ref) {
  final service = CameraService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Service for camera operations and photo management.
///
/// Handles camera initialization, photo capture, gallery selection,
/// and local storage of photos.
class CameraService {
  final _uuid = const Uuid();
  final _picker = ImagePicker();

  List<CameraDescription>? _cameras;
  CameraController? _controller;

  /// Get available cameras on the device.
  Future<List<CameraDescription>> getCameras() async {
    _cameras ??= await availableCameras();
    return _cameras!;
  }

  /// Initialize camera with optional specific camera and resolution.
  Future<CameraController> initializeCamera({
    CameraDescription? camera,
    ResolutionPreset resolution = ResolutionPreset.high,
  }) async {
    final cameras = await getCameras();
    if (cameras.isEmpty) {
      throw CameraException('noCameras', 'No cameras available on this device');
    }

    final selectedCamera = camera ??
        cameras.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.back,
          orElse: () => cameras.first,
        );

    _controller = CameraController(
      selectedCamera,
      resolution,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await _controller!.initialize();
    return _controller!;
  }

  /// Get the current camera controller.
  CameraController? get controller => _controller;

  /// Capture a photo and save to local storage.
  Future<File?> capturePhoto() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return null;
    }

    try {
      final xFile = await _controller!.takePicture();
      final savedPath = await _saveToLocalStorage(File(xFile.path));
      return savedPath;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error capturing photo: $e');
      }
      return null;
    }
  }

  /// Pick a single image from gallery.
  Future<File?> pickFromGallery() async {
    final xFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: AppConstants.photoMaxDimension.toDouble(),
      maxHeight: AppConstants.photoMaxDimension.toDouble(),
      imageQuality: AppConstants.photoCompressionQuality,
    );

    if (xFile == null) return null;

    return _saveToLocalStorage(File(xFile.path));
  }

  /// Pick multiple images from gallery.
  Future<List<File>> pickMultipleFromGallery({int maxImages = 10}) async {
    final xFiles = await _picker.pickMultiImage(
      maxWidth: AppConstants.photoMaxDimension.toDouble(),
      maxHeight: AppConstants.photoMaxDimension.toDouble(),
      imageQuality: AppConstants.photoCompressionQuality,
    );

    final files = <File>[];
    for (final xFile in xFiles.take(maxImages)) {
      final saved = await _saveToLocalStorage(File(xFile.path));
      if (saved != null) files.add(saved);
    }
    return files;
  }

  /// Save a file to local storage with a unique name.
  Future<File?> _saveToLocalStorage(File sourceFile) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final photosDir = Directory(p.join(dir.path, 'photos'));
      // ignore: avoid_slow_async_io
      if (!await photosDir.exists()) {
        // ignore: avoid_slow_async_io
        await photosDir.create(recursive: true);
      }

      final fileName = '${_uuid.v4()}.jpg';
      final destPath = p.join(photosDir.path, fileName);

      return sourceFile.copy(destPath);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error saving photo: $e');
      }
      return null;
    }
  }

  /// Delete a photo file.
  Future<bool> deletePhoto(String path) async {
    try {
      final file = File(path);
      // ignore: avoid_slow_async_io
      if (await file.exists()) {
        // ignore: avoid_slow_async_io
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error deleting photo: $e');
      }
      return false;
    }
  }

  /// Dispose of camera resources.
  void dispose() {
    _controller?.dispose();
    _controller = null;
  }
}
