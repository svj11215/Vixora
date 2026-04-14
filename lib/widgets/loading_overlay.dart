/// Premium full-screen loading overlay with gradient spinner.
/// Keeps existing usage interface AS-IS.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vixora/core/theme/app_theme.dart';

class LoadingOverlay extends StatelessWidget {
  /// Whether the loading overlay should be visible.
  final bool isLoading;

  /// The child widget to display beneath the overlay.
  final Widget child;

  /// Optional loading message to display below the spinner.
  final String? message;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: AnimatedOpacity(
              opacity: isLoading ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                color: Colors.black.withOpacity(0.7),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          gradient: AppGradients.accent,
                          shape: BoxShape.circle,
                          boxShadow: [AppShadows.glowBlue],
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        message ?? 'Please wait...',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
