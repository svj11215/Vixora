/// Resident home screen with BottomNavigationBar: Requests, Profile, and About tabs.
library;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:vixora/screens/resident/request_detail_screen.dart';
import 'package:vixora/screens/resident/resident_requests_screen.dart';
import 'package:vixora/screens/shared/about_screen.dart';
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
    AboutScreen(),
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
      MaterialPageRoute(
        builder: (_) => RequestDetailScreen(requestId: requestId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined),
            activeIcon: Icon(Icons.notifications),
            label: 'Requests',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info_outline),
            activeIcon: Icon(Icons.info),
            label: 'About',
          ),
        ],
      ),
    );
  }
}
