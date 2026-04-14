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
  late AnimationController _dotsController;
  late AnimationController _exitController;

  late Animation<double> _iconScale;
  late Animation<double> _iconFade;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;
  late Animation<double> _taglineFade;
  late Animation<double> _exitFade;

  // Dot controllers
  late AnimationController _dot1Controller;
  late AnimationController _dot2Controller;
  late AnimationController _dot3Controller;

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

    // Text: fades in + slides up 20px
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

    // Dots loading indicator
    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    // Staggered dot animations
    _dot1Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _dot2Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _dot3Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
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

    // 1200ms: loading dots appear
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    _dotsController.forward();

    // Start staggered dot animations
    _dot1Controller.repeat(reverse: true);
    await Future.delayed(const Duration(milliseconds: 150));
    if (!mounted) return;
    _dot2Controller.repeat(reverse: true);
    await Future.delayed(const Duration(milliseconds: 150));
    if (!mounted) return;
    _dot3Controller.repeat(reverse: true);
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
    _dotsController.dispose();
    _dot1Controller.dispose();
    _dot2Controller.dispose();
    _dot3Controller.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _exitFade,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(gradient: AppGradients.primary),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Shield icon
                ScaleTransition(
                  scale: _iconScale,
                  child: FadeTransition(
                    opacity: _iconFade,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: AppGradients.accent,
                        shape: BoxShape.circle,
                        boxShadow: [AppShadows.glowBlue],
                      ),
                      child: const Icon(
                        Icons.security_rounded,
                        size: 52,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // "VIXORA" text
                SlideTransition(
                  position: _textSlide,
                  child: FadeTransition(
                    opacity: _textFade,
                    child: Text(
                      'VIXORA',
                      style: GoogleFonts.poppins(
                        fontSize: 38,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
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
                    'Secure. Smart. Simple.',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.accentCyan,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 48),

                // Loading dots
                FadeTransition(
                  opacity: Tween<double>(
                    begin: 0.0,
                    end: 1.0,
                  ).animate(_dotsController),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _AnimatedDot(controller: _dot1Controller),
                      const SizedBox(width: 8),
                      _AnimatedDot(controller: _dot2Controller),
                      const SizedBox(width: 8),
                      _AnimatedDot(controller: _dot3Controller),
                    ],
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

class _AnimatedDot extends StatelessWidget {
  final AnimationController controller;

  const _AnimatedDot({required this.controller});

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(
        begin: 1.0,
        end: 1.5,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut)),
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: AppColors.accentCyan,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
