/// Vixora Design System — Single Source of Truth
/// Premium dark theme with glassmorphism, gradients, and Poppins typography.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// COLOR PALETTE
// ═══════════════════════════════════════════════════════════════════════════════
class AppColors {
  AppColors._();

  // Primary
  static const Color primaryDark = Color(0xFF0F172A);
  static const Color primaryNavy = Color(0xFF1E3A8A);
  static const Color primaryBlue = Color(0xFF2563EB);

  // Accents
  static const Color accentCyan = Color(0xFF06B6D4);
  static const Color accentGreen = Color(0xFF22C55E);
  static const Color accentRed = Color(0xFFEF4444);
  static const Color accentAmber = Color(0xFFF59E0B);

  // Surfaces
  static const Color surfaceDark = Color(0xFF111827);
  static const Color surfaceDarker = Color(0xFF0B0F1A);
  static const Color surfaceElevated = Color(0xFF1F2937);
  static const Color surfaceBorder = Color(0xFF374151);

  // Text
  static const Color textPrimary = Color(0xFFF9FAFB);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textTertiary = Color(0xFF6B7280);
}

// ═══════════════════════════════════════════════════════════════════════════════
// GRADIENTS
// ═══════════════════════════════════════════════════════════════════════════════
class AppGradients {
  AppGradients._();

  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primaryDark, AppColors.primaryNavy],
  );

  static const LinearGradient accent = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [AppColors.primaryBlue, AppColors.accentCyan],
  );

  static const LinearGradient card = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.surfaceDark, AppColors.surfaceElevated],
  );

  static const LinearGradient success = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF065F46), Color(0xFF059669)],
  );

  static const LinearGradient danger = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF7F1D1D), Color(0xFFDC2626)],
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
  static const double medium = 12.0;
  static const double large = 16.0;
  static const double xlarge = 24.0;
  static const double pill = 100.0;
}

// ═══════════════════════════════════════════════════════════════════════════════
// SHADOWS
// ═══════════════════════════════════════════════════════════════════════════════
class AppShadows {
  AppShadows._();

  static final BoxShadow cardShadow = BoxShadow(
    color: Colors.black.withOpacity(0.4),
    blurRadius: 20,
    offset: const Offset(0, 8),
    spreadRadius: -4,
  );

  static final BoxShadow glowCyan = BoxShadow(
    color: const Color(0xFF06B6D4).withOpacity(0.3),
    blurRadius: 20,
    spreadRadius: -2,
  );

  static final BoxShadow glowBlue = BoxShadow(
    color: const Color(0xFF2563EB).withOpacity(0.4),
    blurRadius: 24,
    spreadRadius: -4,
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// TEXT STYLES (Poppins via Google Fonts)
// ═══════════════════════════════════════════════════════════════════════════════
class AppTextStyles {
  AppTextStyles._();

  static TextStyle display = GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );

  static TextStyle headline = GoogleFonts.poppins(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    color: AppColors.textPrimary,
  );

  static TextStyle title = GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  static TextStyle subtitle = GoogleFonts.poppins(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    color: AppColors.textPrimary,
  );

  static TextStyle body = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
    color: AppColors.textPrimary,
  );

  static TextStyle caption = GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    color: AppColors.textSecondary,
  );

  static TextStyle label = GoogleFonts.poppins(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.2,
    color: AppColors.textSecondary,
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// APP THEME
// ═══════════════════════════════════════════════════════════════════════════════
class AppTheme {
  AppTheme._();

  // Legacy references for backward compatibility where needed
  static const Color primaryColor = AppColors.primaryBlue;
  static const Color secondaryColor = AppColors.accentAmber;
  static const Color approvedColor = AppColors.accentGreen;
  static const Color rejectedColor = AppColors.accentRed;
  static const Color pendingColor = AppColors.accentAmber;

  /// Premium dark theme — the only theme used in Vixora.
  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primaryBlue,
        secondary: AppColors.accentCyan,
        surface: AppColors.surfaceDark,
        error: AppColors.accentRed,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimary,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.surfaceDarker,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.large),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceElevated,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: const BorderSide(color: AppColors.surfaceBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: const BorderSide(color: AppColors.accentCyan, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: const BorderSide(color: AppColors.accentRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: const BorderSide(color: AppColors.accentRed, width: 1.5),
        ),
        labelStyle: GoogleFonts.poppins(color: AppColors.textSecondary),
        hintStyle: GoogleFonts.poppins(color: AppColors.textTertiary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.surfaceBorder),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        selectedItemColor: AppColors.accentCyan,
        unselectedItemColor: AppColors.textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 13),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surfaceElevated,
        contentTextStyle: GoogleFonts.poppins(color: AppColors.textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.surfaceBorder,
        thickness: 1,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.large),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceDark,
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
