// UI_REDESIGN: Glass card with VixoraColors — revert by restoring original
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
        // UI_REDESIGN: VixoraColors.surface solid + subtle gradient — revert to AppGradients.card
        gradient: gradient ?? AppGradients.card,
        borderRadius: BorderRadius.circular(borderRadius ?? AppRadius.large),
        border: border ??
            Border.all(
              // UI_REDESIGN: VixoraColors.border — revert to AppColors.surfaceBorder
              color: VixoraColors.border,
              width: 1,
            ),
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
