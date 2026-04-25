// UI_REDESIGN: Central theme file — delete this file to fully revert UI
/// Vixora Design System v2 — Dark + Lime palette with DM Sans typography.
/// All legacy class names (AppColors, AppGradients, AppTextStyles, etc.)
/// are preserved as aliases so that existing imports keep working.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// NEW COLOR PALETTE
// ═══════════════════════════════════════════════════════════════════════════════

// UI_REDESIGN: New Vixora color system — revert by restoring old AppColors
class VixoraColors {
  VixoraColors._();

  // Primary palette — bold dark + lime
  static const background = Color(0xFF111318); // near-black charcoal
  static const surface = Color(0xFF1C1F2A); // card background
  static const surfaceHigh = Color(0xFF252836); // elevated card
  static const primary = Color(0xFFC6F135); // lime yellow-green
  static const primaryDark = Color(0xFF9BBF1A); // pressed state
  static const accent = Color(0xFF00E5CC); // cyan teal
  static const accentSoft = Color(0xFF00B4A0); // cyan pressed

  // Status colors
  static const approved = Color(0xFF00C896);
  static const approvedBg = Color(0x18009E76); // 10% opacity
  static const rejected = Color(0xFFFF4565);
  static const rejectedBg = Color(0x18FF4565);
  static const pending = Color(0xFFFFB547);
  static const pendingBg = Color(0x18FFB547);

  // Text
  static const textPrimary = Color(0xFFF5F7FA);
  static const textSecondary = Color(0xFF8892A4);
  static const textHint = Color(0xFF4A5168);

  // Divider / border
  static const border = Color(0xFF2A2D3E);
  static const borderGlow = Color(0x30C6F135); // lime at 20% opacity
}

// ═══════════════════════════════════════════════════════════════════════════════
// LEGACY ALIASES — maps old names to new palette
// ═══════════════════════════════════════════════════════════════════════════════

// UI_REDESIGN: Legacy color aliases — revert by restoring original AppColors class
class AppColors {
  AppColors._();

  // Primary → mapped
  static const Color primaryDark = VixoraColors.background;
  static const Color primaryNavy = Color(0xFF1E3A8A); // kept for gradients
  static const Color primaryBlue = VixoraColors.primary;

  // Accents → mapped
  static const Color accentCyan = VixoraColors.accent;
  static const Color accentGreen = VixoraColors.approved;
  static const Color accentRed = VixoraColors.rejected;
  static const Color accentAmber = VixoraColors.pending;

  // Surfaces → mapped
  static const Color surfaceDark = VixoraColors.surface;
  static const Color surfaceDarker = VixoraColors.background;
  static const Color surfaceElevated = VixoraColors.surfaceHigh;
  static const Color surfaceBorder = VixoraColors.border;

  // Text → mapped
  static const Color textPrimary = VixoraColors.textPrimary;
  static const Color textSecondary = VixoraColors.textSecondary;
  static const Color textTertiary = VixoraColors.textHint;
}

// ═══════════════════════════════════════════════════════════════════════════════
// GRADIENTS
// ═══════════════════════════════════════════════════════════════════════════════

// UI_REDESIGN: Updated gradients with lime+cyan palette — revert by restoring old
class AppGradients {
  AppGradients._();

  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [VixoraColors.background, Color(0xFF1A1D28)],
  );

  static const LinearGradient accent = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [VixoraColors.primary, VixoraColors.accent],
  );

  static const LinearGradient card = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [VixoraColors.surface, VixoraColors.surfaceHigh],
  );

  static const LinearGradient success = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF00805E), VixoraColors.approved],
  );

  static const LinearGradient danger = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFB0203A), VixoraColors.rejected],
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// SPACING (8pt grid)
// ═══════════════════════════════════════════════════════════════════════════════
class AppSpacing {
  AppSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

// ═══════════════════════════════════════════════════════════════════════════════
// BORDER RADIUS
// ═══════════════════════════════════════════════════════════════════════════════
class AppRadius {
  AppRadius._();

  static const double small = 8.0;
  static const double medium = 14.0;
  static const double large = 18.0;
  static const double xlarge = 24.0;
  static const double pill = 100.0;
}

// ═══════════════════════════════════════════════════════════════════════════════
// SHADOWS
// ═══════════════════════════════════════════════════════════════════════════════

// UI_REDESIGN: Updated shadows for new palette — revert by restoring old
class AppShadows {
  AppShadows._();

  static final BoxShadow cardShadow = BoxShadow(
    color: Colors.black.withOpacity(0.4),
    blurRadius: 20,
    offset: const Offset(0, 8),
    spreadRadius: -4,
  );

  static final BoxShadow glowCyan = BoxShadow(
    color: VixoraColors.accent.withOpacity(0.25),
    blurRadius: 20,
    spreadRadius: -2,
  );

  static final BoxShadow glowBlue = BoxShadow(
    color: VixoraColors.primary.withOpacity(0.3),
    blurRadius: 24,
    spreadRadius: -4,
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// TEXT STYLES (DM Sans via Google Fonts)
// ═══════════════════════════════════════════════════════════════════════════════

// UI_REDESIGN: Switched from Poppins to DM Sans — revert by changing GoogleFonts.dmSans → GoogleFonts.poppins
class AppTextStyles {
  AppTextStyles._();

  static TextStyle display = GoogleFonts.dmSans(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    color: VixoraColors.textPrimary,
  );

  static TextStyle headline = GoogleFonts.dmSans(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    color: VixoraColors.textPrimary,
  );

  static TextStyle title = GoogleFonts.dmSans(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.3,
    color: VixoraColors.textPrimary,
  );

  static TextStyle subtitle = GoogleFonts.dmSans(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    color: VixoraColors.textPrimary,
  );

  static TextStyle body = GoogleFonts.dmSans(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
    color: VixoraColors.textPrimary,
  );

  static TextStyle caption = GoogleFonts.dmSans(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    color: VixoraColors.textSecondary,
  );

  static TextStyle label = GoogleFonts.dmSans(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.2,
    color: VixoraColors.textSecondary,
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// APP THEME
// ═══════════════════════════════════════════════════════════════════════════════

// UI_REDESIGN: Completely new ThemeData — revert by restoring old AppTheme class
class AppTheme {
  AppTheme._();

  // Legacy references for backward compatibility
  static const Color primaryColor = VixoraColors.primary;
  static const Color secondaryColor = VixoraColors.pending;
  static const Color approvedColor = VixoraColors.approved;
  static const Color rejectedColor = VixoraColors.rejected;
  static const Color pendingColor = VixoraColors.pending;

  /// Premium dark theme — the only theme used in Vixora.
  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: VixoraColors.primary,
        secondary: VixoraColors.accent,
        surface: VixoraColors.surface,
        error: VixoraColors.rejected,
        onPrimary: VixoraColors.background,
        onSecondary: VixoraColors.background,
        onSurface: VixoraColors.textPrimary,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: VixoraColors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: VixoraColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.dmSans(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: VixoraColors.textPrimary,
          letterSpacing: 0.3,
        ),
        iconTheme: const IconThemeData(color: VixoraColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: VixoraColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.large),
          side: const BorderSide(color: VixoraColors.border),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: VixoraColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: GoogleFonts.dmSans(
          color: VixoraColors.textHint,
          fontSize: 14,
        ),
        labelStyle: GoogleFonts.dmSans(color: VixoraColors.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: const BorderSide(color: VixoraColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: const BorderSide(color: VixoraColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide:
              const BorderSide(color: VixoraColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: const BorderSide(color: VixoraColors.rejected),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide:
              const BorderSide(color: VixoraColors.rejected, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: VixoraColors.primary,
          foregroundColor: VixoraColors.background,
          elevation: 0,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          textStyle: GoogleFonts.dmSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: VixoraColors.textPrimary,
          side: const BorderSide(color: VixoraColors.border),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
          textStyle: GoogleFonts.dmSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: VixoraColors.surface,
        selectedItemColor: VixoraColors.primary,
        unselectedItemColor: VixoraColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: GoogleFonts.dmSans(
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: GoogleFonts.dmSans(
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: VixoraColors.background,
        unselectedLabelColor: VixoraColors.textSecondary,
        labelStyle: GoogleFonts.dmSans(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.dmSans(fontSize: 13),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: VixoraColors.surfaceHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: VixoraColors.surfaceHigh,
        contentTextStyle: GoogleFonts.dmSans(color: VixoraColors.textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: VixoraColors.border,
        thickness: 1,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: VixoraColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.large),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: VixoraColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xlarge),
          ),
        ),
      ),
    );
  }

  /// Kept for backward compatibility — maps to darkTheme.
  static ThemeData lightTheme() => darkTheme();
}

// ═══════════════════════════════════════════════════════════════════════════════
// REUSABLE WIDGET HELPERS
// ═══════════════════════════════════════════════════════════════════════════════

/// Gradient primary button (use instead of ElevatedButton where prominent).
// UI_REDESIGN: Custom gradient button — revert to ElevatedButton if needed
class VixoraButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final Color? color;

  const VixoraButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 54,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: color != null
                ? [color!, color!.withOpacity(0.8)]
                : [VixoraColors.primary, VixoraColors.accent],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: (color ?? VixoraColors.primary).withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: VixoraColors.background,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 18, color: VixoraColors.background),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      label,
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: VixoraColors.background,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// Status chip widget.
// UI_REDESIGN: Status chip — revert to plain Text widget if needed
class StatusChip extends StatelessWidget {
  final String status; // "pending" | "approved" | "rejected"
  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (Color fg, Color bg, String text) = switch (status.toLowerCase()) {
      'approved' => (
          VixoraColors.approved,
          VixoraColors.approvedBg,
          '✓ APPROVED'
        ),
      'rejected' => (
          VixoraColors.rejected,
          VixoraColors.rejectedBg,
          '✕ REJECTED'
        ),
      _ => (VixoraColors.pending, VixoraColors.pendingBg, '⏳ PENDING'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withOpacity(0.4)),
      ),
      child: Text(
        text,
        style: GoogleFonts.dmSans(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: fg,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// Glass card container.
// UI_REDESIGN: GlassCard helper in theme — revert to plain Container if needed
class VixoraGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? borderColor;
  const VixoraGlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: VixoraColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: borderColor ?? VixoraColors.border,
        ),
      ),
      child: child,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SNACK BAR HELPER
// ═══════════════════════════════════════════════════════════════════════════════

// UI_REDESIGN: Centralized snack bar helper — revert by removing calls
class VixoraSnack {
  VixoraSnack._();

  static void show(BuildContext ctx, String msg, {bool error = false}) {
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
      content: Text(
        msg,
        style: GoogleFonts.dmSans(color: VixoraColors.background),
      ),
      backgroundColor: error ? VixoraColors.rejected : VixoraColors.approved,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    ));
  }
}
