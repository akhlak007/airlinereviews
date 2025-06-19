import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import '../../../core/configs/cloudinary.dart';

class CloudinaryService {
  late final CloudinaryPublic _cloudinary;

  CloudinaryService() {
    _cloudinary = CloudinaryPublic(
      CloudinaryConfig.cloudName,
      CloudinaryConfig.uploadPreset,
      cache: false,
    );
  }

  /// Now takes the exact callback signature expected by `uploadFile`
  Future<String> uploadMedia(
      File file, {
        void Function(int sentBytes, int totalBytes)? onProgress,
      }) async {
    try {
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          file.path,
          resourceType: _getResourceType(file.path),
        ),
        onProgress: onProgress,
      );
      return response.secureUrl;
    } catch (e) {
      throw Exception('Failed to upload media: ${e.toString()}');
    }
  }

  CloudinaryResourceType _getResourceType(String filePath) {
    final extension = filePath.toLowerCase().split('.').last;
    if (['mp4', 'mov', 'avi', 'mkv'].contains(extension)) {
      return CloudinaryResourceType.Video;
    }
    return CloudinaryResourceType.Image;
  }

  String getMediaType(String filePath) {
    final extension = filePath.toLowerCase().split('.').last;
    if (['mp4', 'mov', 'avi', 'mkv'].contains(extension)) {
      return 'video';
    }
    return 'image';
  }
}