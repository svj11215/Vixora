/// Reusable gradient button with loading state and press animation.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vixora/core/theme/app_theme.dart';

class AppButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final Gradient? gradient;
  final bool outlined;
  final Color? outlineColor;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
    this.gradient,
    this.outlined = false,
    this.outlineColor,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null && !widget.isLoading;

    if (widget.outlined) {
      return AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: widget.isLoading ? null : widget.onPressed,
          child: Opacity(
            opacity: isDisabled ? 0.5 : 1.0,
            child: Container(
              width: widget.width,
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.pill),
                border: Border.all(
                  color: widget.outlineColor ?? AppColors.surfaceBorder,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: widget.isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(widget.icon, size: 18,
                                color: widget.outlineColor ?? AppColors.textPrimary),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            widget.label,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: widget.outlineColor ?? AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      );
    }

    return AnimatedScale(
      scale: _isPressed ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 150),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.isLoading ? null : widget.onPressed,
        child: Opacity(
          opacity: isDisabled ? 0.5 : 1.0,
          child: Container(
            width: widget.width,
            height: 52,
            decoration: BoxDecoration(
              gradient: widget.gradient ?? AppGradients.accent,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              boxShadow: [AppShadows.cardShadow],
            ),
            child: Center(
              child: widget.isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(widget.icon, size: 18, color: Colors.white),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          widget.label,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
