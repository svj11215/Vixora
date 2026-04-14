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

    return Consumer<app.AuthProvider>(
      builder: (context, authProvider, _) {
        return LoadingOverlay(
          isLoading: authProvider.isLoading,
          message: 'Signing in...',
          child: Scaffold(
            body: Stack(
              children: [
                // Background gradient
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: AppGradients.primary,
                  ),
                ),
                // Decorative circle top right
                Positioned(
                  top: -100,
                  right: -50,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      color: AppColors.accentCyan.withOpacity(0.08),
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
                      color: AppColors.primaryBlue.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                // Content
                SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: SizedBox(
                      height: size.height -
                          MediaQuery.of(context).padding.top -
                          MediaQuery.of(context).padding.bottom,
                      child: Column(
                        children: [
                          const Spacer(flex: 2),

                          // Logo Section
                          FadeInDown(
                            duration: const Duration(milliseconds: 500),
                            child: Column(
                              children: [
                                Container(
                                  width: 88,
                                  height: 88,
                                  decoration: BoxDecoration(
                                    gradient: AppGradients.accent,
                                    shape: BoxShape.circle,
                                    boxShadow: [AppShadows.glowBlue],
                                  ),
                                  child: const Icon(
                                    Icons.security_rounded,
                                    size: 44,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'VIXORA',
                                  style: AppTextStyles.display.copyWith(
                                    color: Colors.white,
                                    letterSpacing: 8,
                                    fontSize: 28,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  width: 40,
                                  height: 2,
                                  color: AppColors.accentCyan,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Visitor Management System',
                                  style: AppTextStyles.subtitle.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const Spacer(flex: 2),

                          // Buttons Section
                          Column(
                            children: [
                              FadeInUp(
                                delay: const Duration(milliseconds: 200),
                                duration: const Duration(milliseconds: 400),
                                child: Text(
                                  'CHOOSE YOUR ROLE',
                                  style: AppTextStyles.label.copyWith(
                                    color: AppColors.textTertiary,
                                  ),
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
                                  gradient: AppGradients.accent,
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
                                  gradient: AppGradients.success,
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
                                        color: AppColors.textTertiary),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Secured by Firebase',
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.textTertiary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Error display
                          if (authProvider.error != null)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.accentRed.withOpacity(0.1),
                                borderRadius:
                                    BorderRadius.circular(AppRadius.medium),
                                border: Border.all(
                                  color: AppColors.accentRed.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline,
                                      color: AppColors.accentRed, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      authProvider.error!,
                                      style: GoogleFonts.poppins(
                                        color: AppColors.accentRed,
                                        fontSize: 13,
                                      ),
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

/// Private role button widget with scale press animation.
class _RoleButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Gradient gradient;
  final VoidCallback onPressed;

  const _RoleButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.gradient,
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
            gradient: widget.gradient,
            borderRadius: BorderRadius.circular(AppRadius.large),
            boxShadow: [AppShadows.cardShadow],
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(widget.icon, size: 20, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.label,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    widget.subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 16, color: Colors.white.withOpacity(0.5)),
              const SizedBox(width: 16),
            ],
          ),
        ),
      ),
    );
  }
}
