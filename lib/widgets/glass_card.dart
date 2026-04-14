/// Glassmorphism card widget for premium surface styling.
library;

import 'package:flutter/material.dart';
import 'package:vixora/core/theme/app_theme.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final Gradient? gradient;
  final Border? border;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.gradient,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient ?? AppGradients.card,
        borderRadius: BorderRadius.circular(borderRadius ?? AppRadius.large),
        border: border ??
            Border.all(
              color: AppColors.surfaceBorder,
              width: 1,
            ),
        boxShadow: [AppShadows.cardShadow],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius ?? AppRadius.large),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(AppSpacing.md),
          child: child,
        ),
      ),
    );
  }
}
