/// About screen showing app information, version, and developer details.
library;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vixora/core/constants/app_constants.dart';
import 'package:vixora/core/theme/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // App icon
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryColor, Color(0xFF0D4F7E)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.apartment_rounded,
                size: 45,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppConstants.appName,
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryColor,
              ),
            ),
            Text(
              'Version ${AppConstants.appVersion}',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppConstants.appDescription,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Copyright
            _buildSection(
              context,
              icon: Icons.copyright_outlined,
              title: 'Copyright',
              content: AppConstants.appCopyright,
            ),

            // Developer info
            _buildSection(
              context,
              icon: Icons.code,
              title: 'Developer',
              content:
                  'Built with Flutter & Dart. Powered by Firebase for real-time data, authentication, and push notifications.',
            ),

            // Tech stack
            _buildSection(
              context,
              icon: Icons.layers_outlined,
              title: 'Technology Stack',
              content:
                  '• Flutter (Dart)\n• Firebase Authentication\n• Cloud Firestore\n• Firebase Cloud Messaging\n• Cloudinary (Image Storage)\n• Provider (State Management)',
            ),

            // Documentation
            _buildSection(
              context,
              icon: Icons.article_outlined,
              title: 'Documentation',
              content: 'For detailed setup instructions and API documentation, please refer to the README.md file in the project repository.',
            ),

            const SizedBox(height: 32),
            Divider(color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'Made with ❤️ for modern apartment living',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// Builds an information section card.
  Widget _buildSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppTheme.primaryColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                      height: 1.4,
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
