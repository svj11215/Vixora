/// Profile screen shared by both guard and resident roles. Shows user info with editable name.
library;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vixora/core/constants/app_constants.dart';
import 'package:vixora/core/theme/app_theme.dart';
import 'package:vixora/core/utils/validators.dart';
import 'package:vixora/providers/auth_provider.dart' as app;
import 'package:vixora/providers/profile_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
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
      appBar: AppBar(
        title: const Text('Profile'),
        automaticallyImplyLeading: false,
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, profileProvider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Avatar
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primaryColor, Color(0xFF0D4F7E)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      _getInitials(currentUser.name),
                      style: GoogleFonts.poppins(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Role badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: currentUser.isStaff
                        ? AppTheme.secondaryColor.withValues(alpha: 0.15)
                        : AppTheme.primaryColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppTheme.chipRadius),
                  ),
                  child: Text(
                    currentUser.isStaff ? '🛡️ Security Guard' : '🏠 Resident',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: currentUser.isStaff
                          ? AppTheme.secondaryColor
                          : AppTheme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Name field
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Personal Information',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Name
                        TextFormField(
                          controller: _nameController,
                          enabled: _isEditing,
                          decoration: InputDecoration(
                            labelText: 'Name',
                            prefixIcon: const Icon(Icons.person_outline),
                            suffixIcon: IconButton(
                              icon: Icon(_isEditing
                                  ? Icons.close
                                  : Icons.edit_outlined),
                              onPressed: () =>
                                  setState(() => _isEditing = !_isEditing),
                            ),
                          ),
                          validator: Validators.validateName,
                        ),
                        const SizedBox(height: 12),

                        // Email (read-only)
                        TextFormField(
                          initialValue: currentUser.email,
                          enabled: false,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // User Code (read-only for residents)
                        if (currentUser.isResident) ...[
                          TextFormField(
                            initialValue: currentUser.userCode,
                            enabled: false,
                            decoration: const InputDecoration(
                              labelText: 'Resident Code',
                              prefixIcon: Icon(Icons.vpn_key_outlined),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],

                        // Flat No (read-only)
                        if (currentUser.isResident &&
                            currentUser.flatNo.isNotEmpty)
                          TextFormField(
                            initialValue: currentUser.flatNo,
                            enabled: false,
                            decoration: const InputDecoration(
                              labelText: 'Flat No.',
                              prefixIcon: Icon(Icons.home_outlined),
                            ),
                          ),

                        // Save button
                        if (_isEditing) ...[
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: profileProvider.isSaving
                                  ? null
                                  : _saveName,
                              child: profileProvider.isSaving
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text('Save'),
                            ),
                          ),
                        ],

                        // Error
                        if (profileProvider.error != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            profileProvider.error!,
                            style: const TextStyle(
                              color: AppTheme.rejectedColor,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Sign Out
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _signOut(context),
                    icon: const Icon(Icons.logout, color: AppTheme.rejectedColor),
                    label: const Text('Sign Out'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.rejectedColor,
                      side: const BorderSide(color: AppTheme.rejectedColor),
                      padding: const EdgeInsets.symmetric(vertical: 14),
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
    final name = _nameController.text.trim();
    if (name.isEmpty || name.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name must be at least 2 characters')),
      );
      return;
    }

    final authProvider = context.read<app.AuthProvider>();
    final uid = authProvider.currentUser?.uid;
    if (uid == null) return;

    final profileProvider = context.read<ProfileProvider>();
    final success = await profileProvider.updateName(uid, name);

    if (success && mounted) {
      final messenger = ScaffoldMessenger.of(context);
      setState(() => _isEditing = false);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Name updated successfully'),
          backgroundColor: AppTheme.approvedColor,
        ),
      );
      // Reload user data in AuthProvider
      await authProvider.loadUser();
    }
  }

  Future<void> _signOut(BuildContext context) async {
    final nav = Navigator.of(context);
    final authProvider = context.read<app.AuthProvider>();
    await authProvider.signOut();
    nav.pushReplacementNamed(AppConstants.routeLogin);
  }
}
