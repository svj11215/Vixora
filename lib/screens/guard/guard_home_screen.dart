/// Guard home screen with BottomNavigationBar: Add Request and My Requests tabs.
library;
import 'package:flutter/material.dart';
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add_alt_1_rounded),
            activeIcon: Icon(Icons.person_add_alt_1),
            label: 'Add Request',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_rounded),
            activeIcon: Icon(Icons.list_alt),
            label: 'My Requests',
          ),
        ],
      ),
    );
  }
}
