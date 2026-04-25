// UI_REDESIGN: Add visitor screen with VixoraColors palette — revert by restoring original
/// Premium screen for guards to submit a new visitor request.
/// ALL form submission, validation, and layout logic kept AS-IS.
library;

import 'dart:io';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vixora/core/constants/app_constants.dart';
import 'package:vixora/core/theme/app_theme.dart';
import 'package:vixora/core/utils/validators.dart';
import 'package:vixora/providers/auth_provider.dart' as app;
import 'package:vixora/providers/visitor_request_provider.dart';
import 'package:vixora/widgets/app_button.dart';
import 'package:vixora/widgets/glass_card.dart';
import 'package:vixora/widgets/image_picker_widget.dart';
import 'package:vixora/widgets/loading_overlay.dart';

class AddVisitorScreen extends StatefulWidget {
  const AddVisitorScreen({super.key});

  @override
  State<AddVisitorScreen> createState() => _AddVisitorScreenState();
}

class _AddVisitorScreenState extends State<AddVisitorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _residentCodeController = TextEditingController();
  String? _selectedPurpose;
  File? _selectedImage;
  String? _uploadedImageUrl;
  bool _isUploadingImage = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _residentCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VisitorRequestProvider>(
      builder: (context, provider, _) {
        return LoadingOverlay(
          isLoading: provider.isSubmitting,
          message: 'Submitting request...',
          child: Scaffold(
            // UI_REDESIGN: VixoraColors.background scaffold — revert to default
            backgroundColor: VixoraColors.background,
            appBar: AppBar(
              backgroundColor: VixoraColors.background,
              title: Row(
                children: [
                  // UI_REDESIGN: Primary icon — revert to AppColors.accentCyan
                  const Icon(Icons.person_add_rounded,
                      color: VixoraColors.primary),
                  const SizedBox(width: 8),
                  Text('New Request', style: AppTextStyles.title),
                ],
              ),
              automaticallyImplyLeading: false,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(
                  color: VixoraColors.border,
                  height: 1,
                ),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Area
                    // UI_REDESIGN: Surface card header — revert to gradient GlassCard
                    FadeInDown(
                      duration: const Duration(milliseconds: 400),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: VixoraColors.surface,
                          borderRadius:
                              BorderRadius.circular(AppRadius.large),
                          border:
                              Border.all(color: VixoraColors.borderGlow),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color:
                                    VixoraColors.primary.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.shield_rounded,
                                  color: VixoraColors.primary, size: 28),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Create Entry Request',
                                    style: GoogleFonts.dmSans(
                                      color: VixoraColors.textPrimary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  Text(
                                    'Fill the details to notify resident',
                                    style: GoogleFonts.dmSans(
                                      color: VixoraColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Section: Visitor Details
                    // UI_REDESIGN: Section header with lime bar — revert to icon+text row
                    FadeInUp(
                      delay: const Duration(milliseconds: 100),
                      duration: const Duration(milliseconds: 400),
                      child: _buildSectionHeader('Visitor Details'),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    FadeInUp(
                      delay: const Duration(milliseconds: 150),
                      duration: const Duration(milliseconds: 400),
                      child: GlassCard(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _nameController,
                              style: AppTextStyles.body,
                              decoration: const InputDecoration(
                                labelText: 'Visitor Name',
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                              textCapitalization:
                                  TextCapitalization.words,
                              validator: Validators.validateVisitorName,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _phoneController,
                              style: AppTextStyles.body,
                              decoration: const InputDecoration(
                                labelText: 'Phone Number',
                                prefixIcon: Icon(Icons.phone_outlined),
                              ),
                              keyboardType: TextInputType.phone,
                              validator: Validators.validatePhoneNumber,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Section: Visit Info
                    FadeInUp(
                      delay: const Duration(milliseconds: 200),
                      duration: const Duration(milliseconds: 400),
                      child: _buildSectionHeader('Visit Information'),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    FadeInUp(
                      delay: const Duration(milliseconds: 250),
                      duration: const Duration(milliseconds: 400),
                      child: GlassCard(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          children: [
                            DropdownButtonFormField<String>(
                              value: _selectedPurpose,
                              style: AppTextStyles.body,
                              dropdownColor: VixoraColors.surfaceHigh,
                              icon: const Icon(
                                  Icons.arrow_drop_down_rounded,
                                  color: VixoraColors.textSecondary),
                              decoration: const InputDecoration(
                                labelText: 'Purpose of Visit',
                                prefixIcon:
                                    Icon(Icons.category_outlined),
                              ),
                              items: AppConstants.visitPurposes
                                  .map((purpose) => DropdownMenuItem(
                                        value: purpose,
                                        child: Text(purpose),
                                      ))
                                  .toList(),
                              onChanged: (value) => setState(
                                  () => _selectedPurpose = value),
                              validator: Validators.validatePurpose,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _residentCodeController,
                              style: AppTextStyles.body,
                              decoration: const InputDecoration(
                                labelText: 'Resident Code',
                                prefixIcon:
                                    Icon(Icons.vpn_key_outlined),
                                hintText: '4-digit code',
                              ),
                              keyboardType: TextInputType.number,
                              maxLength: 4,
                              validator:
                                  Validators.validateResidentCode,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Section: Photo
                    FadeInUp(
                      delay: const Duration(milliseconds: 300),
                      duration: const Duration(milliseconds: 400),
                      child: _buildSectionHeader('Visitor Photo *'),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    FadeInUp(
                      delay: const Duration(milliseconds: 350),
                      duration: const Duration(milliseconds: 400),
                      child: ImagePickerWidget(
                        onImageSelected: _onImageSelected,
                        selectedImage: _selectedImage,
                        isUploading: _isUploadingImage,
                        isUploaded: _uploadedImageUrl != null,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Error display
                    if (provider.submitError != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                              VixoraColors.rejected.withOpacity(0.1),
                          borderRadius:
                              BorderRadius.circular(AppRadius.medium),
                          border: Border.all(
                            color:
                                VixoraColors.rejected.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline,
                                color: VixoraColors.rejected,
                                size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                provider.submitError!,
                                style: GoogleFonts.dmSans(
                                  color: VixoraColors.rejected,
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Submit Button
                    FadeInUp(
                      delay: const Duration(milliseconds: 400),
                      duration: const Duration(milliseconds: 400),
                      child: AppButton(
                        label: 'Submit Request',
                        icon: Icons.send_rounded,
                        isLoading:
                            _isUploadingImage || provider.isSubmitting,
                        onPressed: _submitRequest,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // UI_REDESIGN: Section header with lime accent bar — revert to icon+text Row
  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            color: VixoraColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            title,
            style: GoogleFonts.dmSans(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: VixoraColors.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  /// Handles image selection and uploads to Cloudinary immediately.
  Future<void> _onImageSelected(File? file) async {
    if (file == null) {
      if (_selectedImage != null) {
        setState(() {
          _selectedImage = null;
          _uploadedImageUrl = null;
        });
      }
      return;
    }

    setState(() {
      _selectedImage = file;
      _isUploadingImage = true;
      _uploadedImageUrl = null;
    });

    final provider = context.read<VisitorRequestProvider>();
    final url = await provider.uploadVisitorPhoto(file);

    if (mounted) {
      setState(() {
        _isUploadingImage = false;
        _uploadedImageUrl = url;
      });
    }
  }

  /// Validates the form and submits the visitor request.
  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    if (_uploadedImageUrl == null) {
      // UI_REDESIGN: VixoraSnack — revert to ScaffoldMessenger.showSnackBar
      VixoraSnack.show(context, 'Please take or select a visitor photo',
          error: true);
      return;
    }

    final provider = context.read<VisitorRequestProvider>();
    final authProvider = context.read<app.AuthProvider>();
    final currentUser = authProvider.currentUser;
    if (currentUser == null) return;

    // Lookup resident by code
    final code = _residentCodeController.text.trim();
    final resident = await provider.lookupResidentByCode(code);
    if (resident == null) {
      if (mounted) {
        VixoraSnack.show(context, 'No resident found with this code',
            error: true);
      }
      return;
    }

    final success = await provider.submitVisitorRequest(
      visitorName: _nameController.text.trim(),
      visitorPhone: _phoneController.text.trim(),
      purpose: _selectedPurpose!,
      imageUrl: _uploadedImageUrl!,
      residentCode: code,
      residentId: resident.uid,
      guardId: currentUser.uid,
    );

    if (success && mounted) {
      _resetForm();
      VixoraSnack.show(context, 'Request submitted successfully');
    }
  }

  /// Resets the form to its initial state.
  void _resetForm() {
    _formKey.currentState?.reset();
    _nameController.clear();
    _phoneController.clear();
    _residentCodeController.clear();
    setState(() {
      _selectedPurpose = null;
      _selectedImage = null;
      _uploadedImageUrl = null;
    });
  }
}
