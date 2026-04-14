/// Premium empty state widget with gradient icon container and optional action.
library;

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:vixora/core/theme/app_theme.dart';
import 'package:vixora/widgets/app_button.dart';

class EmptyStateWidget extends StatelessWidget {
  /// The icon to display.
  final IconData icon;

  /// The title text.
  final String title;

  /// The descriptive subtitle text.
  final String subtitle;

  /// Optional action button label.
  final String? actionLabel;

  /// Optional action button callback.
  final VoidCallback? onAction;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FadeIn(
        duration: const Duration(milliseconds: 500),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: AppGradients.accent,
                  shape: BoxShape.circle,
                  boxShadow: [AppShadows.glowBlue],
                ),
                child: Icon(icon, size: 36, color: Colors.white),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: AppTextStyles.headline,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              if (actionLabel != null) ...[
                const SizedBox(height: 20),
                AppButton(
                  label: actionLabel!,
                  onPressed: onAction,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
