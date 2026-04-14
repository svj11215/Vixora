/// Custom page route with slide + fade transition for premium navigation feel.
library;

import 'package:flutter/material.dart';

class VixoraPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  VixoraPageRoute({required this.page})
      : super(
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 250),
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            );
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(curvedAnimation),
              child: FadeTransition(
                opacity: Tween<double>(begin: 0.0, end: 1.0)
                    .animate(curvedAnimation),
                child: child,
              ),
            );
          },
        );
}
