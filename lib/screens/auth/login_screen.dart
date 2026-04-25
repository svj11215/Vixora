// UI_REDESIGN: New login screen with lime+cyan palette — revert by restoring original
/// Premium login screen with role-based sign-in buttons.
/// ALL existing onPressed callbacks kept exactly as-is.
library;

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vixora/core/theme/app_theme.dart';
import 'package:vixora/providers/auth_provider.dart' as app;
import 'package:vixora/widgets/loading_overlay.dart';
import 'package:vixora/screens/guard/guard_home_screen.dart';
import 'package:vixora/screens/resident/resident_home_screen.dart';
import 'package:vixora/core/utils/page_transitions.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // UI_REDESIGN: Responsive horizontal padding — revert to fixed 32
    final hPad = (size.width * 0.044).clamp(14.0, 20.0);

    return Consumer<app.AuthProvider>(
      builder: (context, authProvider, _) {
        return LoadingOverlay(
          isLoading: authProvider.isLoading,
          message: 'Signing in...',
          child: Scaffold(
            body: Stack(
              children: [
                // UI_REDESIGN: Background solid + subtle circles — revert to AppGradients.primary
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: VixoraColors.background,
                ),
                // Decorative circle top right
                Positioned(
                  top: -100,
                  right: -50,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      color: VixoraColors.primary.withOpacity(0.04),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                // Decorative circle bottom left
                Positioned(
                  bottom: -80,
                  left: -60,
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      color: VixoraColors.accent.withOpacity(0.04),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                // Content
                SafeArea(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: hPad),
                    child: SizedBox(
                      height: size.height -
                          MediaQuery.of(context).padding.top -
                          MediaQuery.of(context).padding.bottom,
                      child: Column(
                        children: [
                          const Spacer(flex: 2),

                          // Logo Section
                          // UI_REDESIGN: Lime radial glow icon — revert to gradient circle
                          FadeInDown(
                            duration: const Duration(milliseconds: 500),
                            child: Column(
                              children: [
                                Container(
                                  width: 110,
                                  height: 110,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        VixoraColors.primary.withOpacity(0.2),
                                        Colors.transparent,
                                      ],
                                    ),
                                    border: Border.all(
                                      color: VixoraColors.primary,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.security_rounded,
                                    size: 48,
                                    color: VixoraColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'VIXORA',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: VixoraColors.primary,
                                    letterSpacing: 8,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  width: 40,
                                  height: 2,
                                  color: VixoraColors.accent,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Visitor Management System',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: VixoraColors.textSecondary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),

                          const Spacer(flex: 2),

                          // Buttons Section
                          // UI_REDESIGN: GlassCard role selector + VixoraButton — revert to _RoleButton
                          Column(
                            children: [
                              FadeInUp(
                                delay: const Duration(milliseconds: 200),
                                duration: const Duration(milliseconds: 400),
                                child: Text(
                                  'CHOOSE YOUR ROLE',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 2,
                                    color: VixoraColors.textHint,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              const SizedBox(height: 16),
                              FadeInUp(
                                delay: const Duration(milliseconds: 350),
                                duration: const Duration(milliseconds: 400),
                                child: _RoleButton(
                                  icon: Icons.security_rounded,
                                  label: 'Security Guard',
                                  subtitle: 'Submit visitor requests',
                                  onPressed: () =>
                                      _handleSignIn(context, isGuard: true),
                                ),
                              ),
                              const SizedBox(height: 12),
                              FadeInUp(
                                delay: const Duration(milliseconds: 500),
                                duration: const Duration(milliseconds: 400),
                                child: _RoleButton(
                                  icon: Icons.home_rounded,
                                  label: 'Resident',
                                  subtitle: 'Approve visitor requests',
                                  onPressed: () =>
                                      _handleSignIn(context, isGuard: false),
                                ),
                              ),
                              const SizedBox(height: 24),
                              FadeInUp(
                                delay: const Duration(milliseconds: 650),
                                duration: const Duration(milliseconds: 400),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.lock_rounded,
                                        size: 12,
                                        color: VixoraColors.textHint),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Secured by Firebase',
                                      style: GoogleFonts.dmSans(
                                        fontSize: 12,
                                        color: VixoraColors.textHint,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Error display
                          if (authProvider.error != null)
                            // UI_REDESIGN: Error card with new colors — revert to AppColors.accentRed
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: VixoraColors.rejected.withOpacity(0.1),
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
                                      color: VixoraColors.rejected, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      authProvider.error!,
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

                          const Spacer(flex: 1),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Handles sign-in based on selected role.
  Future<void> _handleSignIn(BuildContext context,
      {required bool isGuard}) async {
    final authProvider = context.read<app.AuthProvider>();
    authProvider.clearError();

    if (isGuard) {
      await authProvider.signInAsGuard();
    } else {
      await authProvider.signInAsResident();
    }

    if (!context.mounted) return;

    final user = authProvider.currentUser;
    if (user != null) {
      if (user.isStaff) {
        Navigator.of(context).pushReplacement(
          VixoraPageRoute(page: const GuardHomeScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          VixoraPageRoute(page: const ResidentHomeScreen()),
        );
      }
    }
  }
}

/// UI_REDESIGN: Role button with VixoraColors surface card style — revert to gradient button
class _RoleButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onPressed;

  const _RoleButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onPressed,
  });

  @override
  State<_RoleButton> createState() => _RoleButtonState();
}

class _RoleButtonState extends State<_RoleButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          width: double.infinity,
          height: 72,
          decoration: BoxDecoration(
            color: VixoraColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.large),
            border: Border.all(color: VixoraColors.border),
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: VixoraColors.primary.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(widget.icon, size: 20, color: VixoraColors.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.label,
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: VixoraColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    Text(
                      widget.subtitle,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: VixoraColors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 16, color: VixoraColors.textHint),
              const SizedBox(width: 16),
            ],
          ),
        ),
      ),
    );
  }
}
