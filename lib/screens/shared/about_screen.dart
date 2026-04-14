/// Premium about screen showing app information and developer details.
/// Upgraded with glassmorphism and animated entry.
library;

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vixora/core/constants/app_constants.dart';
import 'package:vixora/core/theme/app_theme.dart';
import 'package:vixora/widgets/glass_card.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceDarker,
      appBar: AppBar(
        title: Text('About Vixora', style: AppTextStyles.title),
        backgroundColor: AppColors.surfaceDarker,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.surfaceBorder, height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.md),
            
            // App Icon
            FadeInDown(
              duration: const Duration(milliseconds: 500),
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: AppGradients.accent,
                  borderRadius: BorderRadius.circular(AppRadius.xlarge),
                  boxShadow: [AppShadows.glowBlue],
                ),
                child: const Icon(
                  Icons.shield_rounded,
                  size: 52,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            
            // App Name
            FadeInUp(
              delay: const Duration(milliseconds: 100),
              duration: const Duration(milliseconds: 400),
              child: Text(
                AppConstants.appName,
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                  color: Colors.white,
                ),
              ),
            ),
            
            // App Version
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              duration: const Duration(milliseconds: 400),
              child: Container(
                margin: const EdgeInsets.only(top: 8, bottom: 24),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: Text(
                  'Version ${AppConstants.appVersion}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accentCyan,
                  ),
                ),
              ),
            ),

            // Description
            FadeInUp(
              delay: const Duration(milliseconds: 300),
              duration: const Duration(milliseconds: 400),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  AppConstants.appDescription,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Details Sections
            FadeInUp(
              delay: const Duration(milliseconds: 400),
              duration: const Duration(milliseconds: 400),
              child: Column(
                children: [
                  _buildSection(
                    icon: Icons.copyright_rounded,
                    title: 'Copyright',
                    content: AppConstants.appCopyright,
                  ),
                  _buildSection(
                    icon: Icons.code_rounded,
                    title: 'System Architecture',
                    content: 'Built with Flutter 3.x & Dart. Powered by Firebase (Auth, Firestore, Cloud Messaging) for real-time infrastructure and Cloudinary for asset delivery.',
                  ),
                  _buildSection(
                    icon: Icons.layers_rounded,
                    title: 'Technology Stack',
                    content: '• Flutter UI Toolkit\n• Provider State Management\n• Firebase Core Services\n• NoSQL Data Store\n• Glassmorphism Design System',
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),
            
            // Footer
            FadeIn(
              delay: const Duration(milliseconds: 600),
              duration: const Duration(milliseconds: 500),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 2,
                    color: AppColors.surfaceBorder,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Crafted for modern living',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textTertiary,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Icon(
                    Icons.favorite_rounded,
                    size: 16,
                    color: AppColors.accentRed,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  /// Builds a glass card information section.
  Widget _buildSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: GlassCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.accentCyan.withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppRadius.medium),
              ),
              child: Icon(icon, color: AppColors.accentCyan, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.subtitle.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    content,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
