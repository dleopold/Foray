import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
import '../supabase_service.dart';

final photoUploadServiceProvider = Provider<PhotoUploadService>((ref) {
  return PhotoUploadService(ref.watch(supabaseClientProvider));
});

/// Exception thrown when photo operations fail due to Supabase being unavailable.
class PhotoUploadUnavailableException implements Exception {
  const PhotoUploadUnavailableException([this.message = 'Photo upload unavailable: Supabase not configured']);
  final String message;
  @override
  String toString() => message;
}

class PhotoUploadService {
  PhotoUploadService(this._supabase);

  final SupabaseClient? _supabase;
  
  /// Whether photo upload is available (Supabase configured).
  bool get isAvailable => _supabase != null;
  static const _uuid = Uuid();
  static const _bucketName = 'photos';

  Future<String> uploadPhoto({
    required File file,
    required String observationId,
    void Function(double)? onProgress,
  }) async {
    if (_supabase == null) {
      throw const PhotoUploadUnavailableException();
    }
    
    final compressedBytes = await _compressIfNeeded(file);
    
    final extension = p.extension(file.path).toLowerCase();
    final fileName = '${_uuid.v4()}${extension.isEmpty ? '.jpg' : extension}';
    final storagePath = 'observations/$observationId/$fileName';

    await _supabase.storage.from(_bucketName).uploadBinary(
      storagePath,
      compressedBytes,
      fileOptions: const FileOptions(
        cacheControl: '31536000',
        contentType: 'image/jpeg',
      ),
    );

    return _supabase.storage.from(_bucketName).getPublicUrl(storagePath);
  }

  Future<Uint8List> _compressIfNeeded(File file) async {
    final bytes = await file.readAsBytes();
    
    return compute(_processImage, _ImageProcessParams(
      bytes: bytes,
      maxDimension: AppConstants.photoMaxDimension,
      quality: AppConstants.photoCompressionQuality,
    ));
  }

  Future<void> deletePhoto(String storagePath) async {
    if (_supabase == null) return; // No-op when offline
    await _supabase.storage.from(_bucketName).remove([storagePath]);
  }

  Future<void> deleteObservationPhotos(String observationId) async {
    if (_supabase == null) return; // No-op when offline
    final files = await _supabase.storage
        .from(_bucketName)
        .list(path: 'observations/$observationId');
    
    if (files.isNotEmpty) {
      final paths = files
          .map((f) => 'observations/$observationId/${f.name}')
          .toList();
      await _supabase.storage.from(_bucketName).remove(paths);
    }
  }
}

class _ImageProcessParams {
  const _ImageProcessParams({
    required this.bytes,
    required this.maxDimension,
    required this.quality,
  });

  final Uint8List bytes;
  final int maxDimension;
  final int quality;
}

Uint8List _processImage(_ImageProcessParams params) {
  final image = img.decodeImage(params.bytes);
  if (image == null) return params.bytes;

  img.Image processed = image;
  
  if (image.width > params.maxDimension || image.height > params.maxDimension) {
    processed = img.copyResize(
      image,
      width: image.width > image.height ? params.maxDimension : null,
      height: image.height >= image.width ? params.maxDimension : null,
      interpolation: img.Interpolation.linear,
    );
  }

  return Uint8List.fromList(
    img.encodeJpg(processed, quality: params.quality),
  );
}
