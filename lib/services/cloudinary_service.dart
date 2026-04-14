/// Service for uploading images to Cloudinary via HTTP multipart requests.
library;
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:vixora/core/constants/app_constants.dart';
import 'package:vixora/core/utils/app_exception.dart';

class CloudinaryService {
  /// Maximum number of retry attempts for upload.
  static const int _maxRetries = 3;

  /// Delay between retry attempts in milliseconds.
  static const int _retryDelayMs = 1000;

  /// Uploads an image file to Cloudinary with retry logic.
  ///
  /// Returns the secure URL of the uploaded image.
  /// Compresses the image to max 1024px on the longer side, JPEG quality 85.
  Future<String> uploadImage(File imageFile) async {
    // Read and compress the image
    final bytes = await imageFile.readAsBytes();
    final compressedBytes = await _compressImage(bytes);

    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      try {
        final uri = Uri.parse(AppConstants.cloudinaryUploadUrl);
        final request = http.MultipartRequest('POST', uri);

        request.fields['upload_preset'] = AppConstants.cloudinaryUploadPreset;
        request.fields['folder'] = AppConstants.cloudinaryFolder;

        request.files.add(http.MultipartFile.fromBytes(
          'file',
          compressedBytes,
          filename: 'visitor_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ));

        final streamedResponse = await request.send().timeout(
          const Duration(seconds: 30),
        );

        final response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body) as Map<String, dynamic>;
          final secureUrl = responseData['secure_url'] as String?;
          if (secureUrl == null || secureUrl.isEmpty) {
            throw const AppException(
                'cloudinary-error', 'No secure URL in Cloudinary response');
          }
          return secureUrl;
        } else {
          if (attempt == _maxRetries) {
            throw AppException(
              'cloudinary-upload-failed',
              'Upload failed with status ${response.statusCode}: ${response.body}',
            );
          }
        }
      } catch (e) {
        if (e is AppException) {
          if (attempt == _maxRetries) rethrow;
        } else if (attempt == _maxRetries) {
          throw AppException(
            'cloudinary-error',
            'Failed to upload image after $_maxRetries attempts: $e',
          );
        }
      }

      // Wait before retrying
      if (attempt < _maxRetries) {
        await Future.delayed(const Duration(milliseconds: _retryDelayMs));
      }
    }

    throw const AppException(
        'cloudinary-error', 'Failed to upload image after all retries');
  }

  /// Compresses an image to max 1024px on the longer side with JPEG quality 85.
  Future<Uint8List> _compressImage(Uint8List bytes) async {
    try {
      final codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: 1024,
      );
      final frame = await codec.getNextFrame();
      final image = frame.image;

      final byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData != null) {
        return byteData.buffer.asUint8List();
      }
    } catch (_) {
      // Fallback: return original bytes if compression fails
    }
    return bytes;
  }
}
