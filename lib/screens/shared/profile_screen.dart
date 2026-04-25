// UI_REDESIGN: Profile screen with VixoraColors palette — revert by restoring original
/// Premium profile screen with glass cards and animated editing state.
/// Contains editable name and read-only auth/resident fields.
/// ALL ProfileProvider and AuthProvider logic preserved AS-IS.
library;

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vixora/core/theme/app_theme.dart';
import 'package:vixora/core/utils/validators.dart';
import 'package:vixora/providers/auth_provider.dart' as app;
import 'package:vixora/providers/profile_provider.dart';
import 'package:vixora/screens/shared/about_screen.dart';
import 'package:vixora/widgets/app_button.dart';
import 'package:vixora/core/utils/page_transitions.dart';
import 'package:vixora/screens/auth/login_screen.dart';
import 'package:vixora/widgets/glass_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<app.AuthProvider>();
      final user = authProvider.currentUser;
      if (user != null) {
        _nameController.text = user.name;
        final profileProvider = context.read<ProfileProvider>();
        profileProvider.setProfile(user);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<app.AuthProvider>();
    final currentUser = authProvider.currentUser;
    if (currentUser == null) {
      return const Center(child: Text('Not authenticated'));
    }

    return Scaffold(
      // UI_REDESIGN: VixoraColors.background — revert to AppColors.surfaceDarker
      backgroundColor: VixoraColors.background,
      appBar: AppBar(
        backgroundColor: VixoraColors.background,
        title: Row(
          children: [
            // UI_REDESIGN: Primary-colored icon — revert to AppColors.accentCyan
            const Icon(Icons.person_rounded, color: VixoraColors.primary),
            const SizedBox(width: 8),
            Text('My Profile', style: AppTextStyles.title),
          ],
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(
              _isEditing ? Icons.close_rounded : Icons.edit_rounded,
              color: VixoraColors.textPrimary,
            ),
            tooltip: _isEditing ? 'Cancel Edit' : 'Edit Profile',
            onPressed: () {
              setState(() {
                if (_isEditing) {
                  // Reset to original name if cancelled
                  _nameController.text = currentUser.name;
                }
                _isEditing = !_isEditing;
              });
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: VixoraColors.border,
            height: 1,
          ),
        ),
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, profileProvider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.md),
                  // Avatar Header
                  // UI_REDESIGN: Lime initials avatar — revert to gradient circle
                  FadeInDown(
                    duration: const Duration(milliseconds: 400),
                    child: Center(
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              CircleAvatar(
                                radius: 44,
                                backgroundColor:
                                    VixoraColors.primary.withOpacity(0.2),
                                child: Text(
                                  _getInitials(currentUser.name),
                                  style: GoogleFonts.dmSans(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: VixoraColors.primary,
                                  ),
                                ),
                              ),
                              // UI_REDESIGN: Edit badge — revert to remove
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: const BoxDecoration(
                                    color: VixoraColors.accent,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.edit,
                                      size: 14,
                                      color: VixoraColors.background),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // UI_REDESIGN: Role badge with lime — revert to AppColors.accentCyan
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  VixoraColors.primary.withOpacity(0.12),
                              borderRadius:
                                  BorderRadius.circular(AppRadius.pill),
                              border: Border.all(
                                color:
                                    VixoraColors.primary.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  currentUser.isStaff
                                      ? Icons.security_rounded
                                      : Icons.home_rounded,
                                  size: 14,
                                  color: VixoraColors.primary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  currentUser.isStaff
                                      ? 'Security Guard'
                                      : 'Resident',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: VixoraColors.primary,
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
                  const SizedBox(height: AppSpacing.xl),

                  // Personal Information
                  FadeInUp(
                    delay: const Duration(milliseconds: 100),
                    duration: const Duration(milliseconds: 400),
                    child: GlassCard(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // UI_REDESIGN: Section header with lime bar — revert to plain text
                          Row(
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
                              Expanded(
                                child: Text(
                                  'Personal Information',
                                  style: AppTextStyles.subtitle.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Name field (Editable)
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.medium),
                              boxShadow:
                                  _isEditing ? [AppShadows.glowCyan] : [],
                            ),
                            child: TextFormField(
                              controller: _nameController,
                              style: AppTextStyles.body,
                              enabled: _isEditing,
                              decoration: InputDecoration(
                                labelText: 'Full Name',
                                prefixIcon: Icon(
                                  Icons.person_outline_rounded,
                                  color: _isEditing
                                      ? VixoraColors.accent
                                      : VixoraColors.textSecondary,
                                ),
                              ),
                              validator: Validators.validateName,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Email (Read-only)
                          TextFormField(
                            initialValue: currentUser.email,
                            enabled: false,
                            style: AppTextStyles.body.copyWith(
                              color: VixoraColors.textSecondary,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Email Address',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                          ),

                          // Resident specifics
                          if (currentUser.isResident) ...[
                            const SizedBox(height: 16),
                            TextFormField(
                              initialValue: currentUser.userCode,
                              enabled: false,
                              style: AppTextStyles.body.copyWith(
                                color: VixoraColors.textSecondary,
                              ),
                              decoration: const InputDecoration(
                                labelText: 'Resident Code',
                                prefixIcon: Icon(Icons.vpn_key_outlined),
                              ),
                            ),
                            if (currentUser.flatNo.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              TextFormField(
                                initialValue: currentUser.flatNo,
                                enabled: false,
                                style: AppTextStyles.body.copyWith(
                                  color: VixoraColors.textSecondary,
                                ),
                                decoration: const InputDecoration(
                                  labelText: 'Flat / Apartment No.',
                                  prefixIcon:
                                      Icon(Icons.home_work_outlined),
                                ),
                              ),
                            ]
                          ],

                          // Save Button
                          AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            child: _isEditing
                                ? Padding(
                                    padding:
                                        const EdgeInsets.only(top: 20),
                                    child: AppButton(
                                      label: 'Save Changes',
                                      icon: Icons.check_rounded,
                                      isLoading:
                                          profileProvider.isSaving,
                                      onPressed: _saveName,
                                      width: double.infinity,
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),

                          // Error
                          if (profileProvider.error != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              profileProvider.error!,
                              style: const TextStyle(
                                color: VixoraColors.rejected,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 3,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Actions & About
                  // UI_REDESIGN: VixoraButton sign-out with rejected color — revert to AppButton
                  FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    duration: const Duration(milliseconds: 400),
                    child: Column(
                      children: [
                        // UI_REDESIGN: Outlined about button — revert to AppButton outlined
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            VixoraPageRoute(page: const AboutScreen()),
                          ),
                          child: Container(
                            width: double.infinity,
                            height: 52,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(28),
                              border: Border.all(
                                  color: VixoraColors.border),
                            ),
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                      Icons.info_outline_rounded,
                                      size: 18,
                                      color:
                                          VixoraColors.textPrimary),
                                  const SizedBox(width: 8),
                                  Text(
                                    'About Vixora',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          VixoraColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        VixoraButton(
                          label: 'Sign Out',
                          icon: Icons.logout_rounded,
                          color: VixoraColors.rejected,
                          onPressed: () => _signOut(context),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Extracts initials from a name (first letters of first two words).
  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '?';
  }

  /// Saves the updated name via ProfileProvider.
  Future<void> _saveName() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final authProvider = context.read<app.AuthProvider>();
    final uid = authProvider.currentUser?.uid;
    if (uid == null) return;

    final profileProvider = context.read<ProfileProvider>();
    final success = await profileProvider.updateName(uid, name);

    if (success && mounted) {
      setState(() => _isEditing = false);
      // UI_REDESIGN: VixoraSnack — revert to ScaffoldMessenger.showSnackBar
      VixoraSnack.show(context, 'Profile updated successfully');
      // Reload user data in AuthProvider
      await authProvider.loadUser();
    }
  }

  Future<void> _signOut(BuildContext context) async {
    final authProvider = context.read<app.AuthProvider>();
    await authProvider.signOut();
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        VixoraPageRoute(page: const LoginScreen()),
      );
    }
  }
}
