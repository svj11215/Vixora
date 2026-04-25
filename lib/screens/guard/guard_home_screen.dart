// UI_REDESIGN: Guard home screen with VixoraColors bottom nav — revert by restoring original
/// Guard home screen with premium bottom navigation.
/// ALL navigation logic kept AS-IS.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vixora/core/theme/app_theme.dart';
import 'package:vixora/screens/guard/add_visitor_screen.dart';
import 'package:vixora/screens/guard/guard_requests_screen.dart';

class GuardHomeScreen extends StatefulWidget {
  const GuardHomeScreen({super.key});

  @override
  State<GuardHomeScreen> createState() => _GuardHomeScreenState();
}

class _GuardHomeScreenState extends State<GuardHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    AddVisitorScreen(),
    GuardRequestsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      // UI_REDESIGN: Bottom nav with VixoraColors lime palette — revert to AppColors.accentCyan
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
              icon: const Icon(Icons.person_add_rounded),
              activeIcon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: VixoraColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.person_add_rounded,
                    color: VixoraColors.primary),
              ),
              label: 'Add Request',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.list_alt_rounded),
              activeIcon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: VixoraColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.list_alt_rounded,
                    color: VixoraColors.primary),
              ),
              label: 'My Requests',
            ),
          ],
        ),
      ),
    );
  }
}
