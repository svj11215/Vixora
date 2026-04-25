// UI_REDESIGN: New splash screen with lime+cyan palette — revert by restoring original
/// 2-phase animated splash screen with auth check.
/// Auth logic kept EXACTLY as-is — only visual layer replaced.
library;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vixora/core/constants/app_constants.dart';
import 'package:vixora/core/theme/app_theme.dart';
import 'package:vixora/providers/auth_provider.dart' as app;

import 'package:vixora/screens/auth/login_screen.dart';
import 'package:vixora/screens/guard/guard_home_screen.dart';
import 'package:vixora/screens/resident/resident_home_screen.dart';
import 'package:vixora/core/utils/page_transitions.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Phase 1 animations
  late AnimationController _iconController;
  late AnimationController _textController;
  late AnimationController _taglineController;
  late AnimationController _spinnerController;
  late AnimationController _exitController;

  late Animation<double> _iconScale;
  late Animation<double> _iconFade;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;
  late Animation<double> _taglineFade;
  late Animation<double> _spinnerFade;
  late Animation<double> _exitFade;

  String? _targetRoute;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startSequence();

    // Delay auth check until AFTER first frame is built to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuth();
    });
  }

  void _setupAnimations() {
    // Icon: scales from 0.5→1.0 with elastic
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _iconScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.elasticOut),
    );
    _iconFade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _iconController, curve: Curves.easeOut));

    // Text: fades in + slides up
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
    );
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
        );

    // Tagline: fades in
    _taglineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _taglineFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _taglineController, curve: Curves.easeOut),
    );

    // Spinner fade-in
    _spinnerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _spinnerFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _spinnerController, curve: Curves.easeOut),
    );

    // Exit fade
    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _exitFade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeInOut),
    );
  }

  void _startSequence() async {
    // 200ms: icon appears
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    _iconController.forward();

    // 600ms: text appears
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    _textController.forward();

    // 900ms: tagline appears
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    _taglineController.forward();

    // 1200ms: spinner appears
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    _spinnerController.forward();
  }

  /// Checks if a user is already signed in and navigates accordingly.
  Future<void> _checkAuth() async {
    final startTime = DateTime.now();

    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      final authProvider = context.read<app.AuthProvider>();
      await authProvider.loadUser();

      if (!mounted) return;

      final user = authProvider.currentUser;
      if (user != null) {
        _targetRoute = user.isStaff
            ? AppConstants.routeGuardHome
            : AppConstants.routeResidentHome;
      }
    }

    _targetRoute ??= AppConstants.routeLogin;

    // Ensure minimum 2500ms splash time
    final elapsed = DateTime.now().difference(startTime).inMilliseconds;
    if (elapsed < 2500) {
      await Future.delayed(Duration(milliseconds: 2500 - elapsed));
    }

    if (!mounted) return;
    _navigateOut();
  }

  void _navigateOut() async {
    await _exitController.forward();
    if (!mounted) return;
    Widget targetScreen;
    if (_targetRoute == AppConstants.routeGuardHome) {
      targetScreen = const GuardHomeScreen();
    } else if (_targetRoute == AppConstants.routeResidentHome) {
      targetScreen = const ResidentHomeScreen();
    } else {
      targetScreen = const LoginScreen();
    }

    Navigator.of(context).pushReplacement(VixoraPageRoute(page: targetScreen));
  }

  @override
  void dispose() {
    _iconController.dispose();
    _textController.dispose();
    _taglineController.dispose();
    _spinnerController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // UI_REDESIGN: New splash visuals — revert by restoring original widget tree
    return Scaffold(
      body: FadeTransition(
        opacity: _exitFade,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: VixoraColors.background,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Shield icon with radial glow
                ScaleTransition(
                  scale: _iconScale,
                  child: FadeTransition(
                    opacity: _iconFade,
                    child: Container(
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
                        size: 52,
                        color: VixoraColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // "VIXORA" text
                SlideTransition(
                  position: _textSlide,
                  child: FadeTransition(
                    opacity: _textFade,
                    child: Text(
                      'VIXORA',
                      style: GoogleFonts.dmSans(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: VixoraColors.primary,
                        letterSpacing: 6,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Tagline
                FadeTransition(
                  opacity: _taglineFade,
                  child: Text(
                    'Smart Entry. Safe Living.',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: VixoraColors.textSecondary,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 48),

                // Loading spinner
                FadeTransition(
                  opacity: _spinnerFade,
                  child: const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: VixoraColors.accent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
