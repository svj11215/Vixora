// UI_REDESIGN: Resident home screen with lime+cyan bottom nav — revert by restoring original
/// Resident home screen with custom bottom nav bar.
/// ALL initState() FCM handler logic kept EXACTLY AS-IS.
library;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vixora/core/theme/app_theme.dart';
import 'package:vixora/screens/resident/request_detail_screen.dart';
import 'package:vixora/screens/resident/resident_requests_screen.dart';
import 'package:vixora/screens/shared/profile_screen.dart';

class ResidentHomeScreen extends StatefulWidget {
  const ResidentHomeScreen({super.key});

  @override
  State<ResidentHomeScreen> createState() => _ResidentHomeScreenState();
}

class _ResidentHomeScreenState extends State<ResidentHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    ResidentRequestsScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initFCMHandlers();
    });
  }

  void _initFCMHandlers() {
    // HANDLER 1: App in FOREGROUND — message arrives
    // (already handled by FCMService.onMessage — no action needed here)

    // HANDLER 2: App in BACKGROUND — user taps notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('🔔 onMessageOpenedApp: ${message.data}');
      final requestId = message.data['requestId'];
      if (requestId != null && requestId.isNotEmpty) {
        _navigateToRequestDetail(requestId);
      }
    });

    // HANDLER 3: App TERMINATED — user taps notification (cold start)
    FirebaseMessaging.instance.getInitialMessage().then((
      RemoteMessage? message,
    ) {
      if (message != null) {
        print('🔔 getInitialMessage: ${message.data}');
        final requestId = message.data['requestId'];
        if (requestId != null && requestId.isNotEmpty) {
          // Delay to ensure navigation stack is ready
          Future.delayed(const Duration(milliseconds: 1200), () {
            if (mounted) {
              _navigateToRequestDetail(requestId);
            }
          });
        }
      }
    });
  }

  void _navigateToRequestDetail(String requestId) {
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RequestDetailScreen(requestId: requestId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      // UI_REDESIGN: Bottom nav with VixoraColors — revert to AppColors.surfaceDark etc.
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: VixoraColors.surface,
          border: const Border(
            top: BorderSide(color: VixoraColors.border, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.transparent,
          // UI_REDESIGN: Lime selected color — revert to AppColors.accentCyan
          selectedItemColor: VixoraColors.primary,
          unselectedItemColor: VixoraColors.textSecondary,
          selectedLabelStyle: GoogleFonts.dmSans(
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: GoogleFonts.dmSans(
            fontSize: 11,
            fontWeight: FontWeight.w400,
          ),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.inbox_rounded),
              activeIcon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: VixoraColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.inbox_rounded,
                  color: VixoraColors.primary,
                ),
              ),
              label: 'Requests',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_rounded),
              activeIcon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: VixoraColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: VixoraColors.primary,
                ),
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
