/// Resident home screen with custom bottom nav bar.
/// ALL initState() FCM handler logic kept EXACTLY AS-IS.
library;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vixora/core/theme/app_theme.dart';
import 'package:vixora/core/utils/page_transitions.dart';
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
    _setupNotificationTapHandlers();
  }

  /// Sets up notification tap handlers for background and cold start scenarios.
  Future<void> _setupNotificationTapHandlers() async {
    // Scenario A: App in background, user tapped notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final requestId = message.data['requestId'];
      if (requestId != null && requestId.isNotEmpty) {
        _navigateToRequest(requestId);
      }
    });

    // Scenario B: App was terminated, user tapped notification (cold start)
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      final requestId = initialMessage.data['requestId'];
      if (requestId != null && requestId.isNotEmpty) {
        // Delay to allow the widget to fully build
        Future.delayed(const Duration(seconds: 1), () {
          _navigateToRequest(requestId);
        });
      }
    }
  }

  /// Navigates to RequestDetailScreen with the given request ID.
  void _navigateToRequest(String requestId) {
    Navigator.of(context).push(
      VixoraPageRoute(
        page: RequestDetailScreen(requestId: requestId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          border: const Border(
            top: BorderSide(color: AppColors.surfaceBorder, width: 1),
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
          selectedItemColor: AppColors.accentCyan,
          unselectedItemColor: AppColors.textTertiary,
          selectedLabelStyle: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.inbox_rounded),
              activeIcon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accentCyan.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.inbox_rounded,
                    color: AppColors.accentCyan),
              ),
              label: 'Requests',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_rounded),
              activeIcon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accentCyan.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.person_rounded,
                    color: AppColors.accentCyan),
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
