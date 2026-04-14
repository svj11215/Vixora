/// Screen for guards to submit a new visitor request with photo upload.
library;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vixora/core/constants/app_constants.dart';
import 'package:vixora/core/theme/app_theme.dart';
import 'package:vixora/core/utils/validators.dart';
import 'package:vixora/providers/auth_provider.dart' as app;
import 'package:vixora/providers/visitor_request_provider.dart';
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
            appBar: AppBar(
              title: const Text('Add Visitor Request'),
              automaticallyImplyLeading: false,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.primaryColor, Color(0xFF0D4F7E)],
                        ),
                        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.person_add_alt_1,
                              color: Colors.white, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'New Visitor Entry',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Fill in the visitor details below',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Visitor Name
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Visitor Name',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: Validators.validateVisitorName,
                    ),
                    const SizedBox(height: 16),

                    // Phone Number
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: Validators.validatePhoneNumber,
                    ),
                    const SizedBox(height: 16),

                    // Purpose Dropdown
                    DropdownButtonFormField<String>(
                      initialValue: _selectedPurpose,
                      decoration: const InputDecoration(
                        labelText: 'Purpose of Visit',
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      items: AppConstants.visitPurposes
                          .map((purpose) => DropdownMenuItem(
                                value: purpose,
                                child: Text(purpose),
                              ))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _selectedPurpose = value),
                      validator: Validators.validatePurpose,
                    ),
                    const SizedBox(height: 16),

                    // Resident Code
                    TextFormField(
                      controller: _residentCodeController,
                      decoration: const InputDecoration(
                        labelText: 'Resident Code',
                        prefixIcon: Icon(Icons.vpn_key_outlined),
                        hintText: '4-digit code',
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      validator: Validators.validateResidentCode,
                    ),
                    const SizedBox(height: 16),

                    // Visitor Photo Section
                    Text(
                      'Visitor Photo *',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ImagePickerWidget(
                      onImageSelected: _onImageSelected,
                    ),
                    const SizedBox(height: 12),

                    // Photo preview
                    if (_selectedImage != null)
                      Center(
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(AppTheme.cardRadius),
                              child: Image.file(
                                _selectedImage!,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                            if (_isUploadingImage)
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(
                                        AppTheme.cardRadius),
                                  ),
                                  child: const Center(
                                    child: SizedBox(
                                      width: 30,
                                      height: 30,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 3,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            if (_uploadedImageUrl != null && !_isUploadingImage)
                              Positioned(
                                bottom: 4,
                                right: 4,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: AppTheme.approvedColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                    if (_selectedImage == null)
                      Container(
                        height: 100,
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.grey.shade300, style: BorderStyle.solid),
                          borderRadius:
                              BorderRadius.circular(AppTheme.cardRadius),
                          color: Colors.grey.shade100,
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo_outlined,
                                  size: 32, color: Colors.grey.shade400),
                              const SizedBox(height: 4),
                              Text(
                                'No photo selected',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: (_isUploadingImage || provider.isSubmitting)
                            ? null
                            : _submitRequest,
                        child: const Text('Submit Request'),
                      ),
                    ),

                    // Error display
                    if (provider.submitError != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.rejectedColor.withValues(alpha: 0.1),
                          borderRadius:
                              BorderRadius.circular(AppTheme.buttonRadius),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline,
                                color: AppTheme.rejectedColor, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                provider.submitError!,
                                style: const TextStyle(
                                  color: AppTheme.rejectedColor,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Handles image selection and uploads to Cloudinary immediately.
  Future<void> _onImageSelected(File? file) async {
    if (file == null) return;

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please take or select a visitor photo')),
      );
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No resident found with this code'),
            backgroundColor: AppTheme.rejectedColor,
          ),
        );
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
      final messenger = ScaffoldMessenger.of(context);
      _resetForm();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Request submitted successfully'),
          backgroundColor: AppTheme.approvedColor,
        ),
      );
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
