/// Premium image picker widget with camera/gallery options and upload state display.
/// Keeps ALL existing callbacks.
library;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vixora/core/theme/app_theme.dart';
import 'package:vixora/widgets/glass_card.dart';

class ImagePickerWidget extends StatelessWidget {
  /// Callback invoked when an image is selected.
  final ValueChanged<File?> onImageSelected;

  /// The currently selected image file.
  final File? selectedImage;

  /// Whether the image is currently uploading.
  final bool isUploading;

  /// Whether the image has been uploaded successfully.
  final bool isUploaded;

  const ImagePickerWidget({
    super.key,
    required this.onImageSelected,
    this.selectedImage,
    this.isUploading = false,
    this.isUploaded = false,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedImage != null) {
      return _buildPreview();
    }
    return _buildPicker();
  }

  Widget _buildPicker() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _pickImage(ImageSource.camera),
            child: GlassCard(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
              child: Column(
                children: [
                  const Icon(Icons.camera_alt_rounded,
                      size: 28, color: AppColors.accentCyan),
                  const SizedBox(height: 8),
                  Text(
                    'Camera',
                    style: AppTextStyles.subtitle.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Take photo',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => _pickImage(ImageSource.gallery),
            child: GlassCard(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
              child: Column(
                children: [
                  const Icon(Icons.photo_library_rounded,
                      size: 28, color: AppColors.accentCyan),
                  const SizedBox(height: 8),
                  Text(
                    'Gallery',
                    style: AppTextStyles.subtitle.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Choose photo',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreview() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.large),
          child: Image.file(
            selectedImage!,
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
          ),
        ),
        // Remove button
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: () => onImageSelected(null),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.accentRed.withOpacity(0.8),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close_rounded,
                  size: 18, color: Colors.white),
            ),
          ),
        ),
        // Upload overlay
        if (isUploading)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(AppRadius.large),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              ),
            ),
          ),
        // Uploaded indicator
        if (isUploaded && !isUploading)
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.accentGreen,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_rounded,
                      size: 14, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    'Uploaded',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  /// Picks an image from the specified source with compression settings.
  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        onImageSelected(File(pickedFile.path));
      }
    } catch (e) {
      onImageSelected(null);
    }
  }
}
