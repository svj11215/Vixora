/// Premium visitor request card with glass card styling.
/// Keeps ALL existing props and callbacks.
library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:vixora/core/theme/app_theme.dart';
import 'package:vixora/models/visitor_request_model.dart';
import 'package:vixora/widgets/glass_card.dart';
import 'package:vixora/widgets/status_badge.dart';

class VisitorRequestCard extends StatelessWidget {
  /// The visitor request data to display.
  final VisitorRequestModel request;

  /// Callback when the card is tapped.
  final VoidCallback onTap;

  /// Whether to show approve/reject action buttons.
  final bool showActions;

  /// Callback for the approve action.
  final VoidCallback? onApprove;

  /// Callback for the reject action.
  final VoidCallback? onReject;

  const VisitorRequestCard({
    super.key,
    required this.request,
    required this.onTap,
    this.showActions = false,
    this.onApprove,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        child: GlassCard(
          padding: EdgeInsets.zero,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.large),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Visitor photo
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.medium),
                        child: request.imageUrl.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: request.imageUrl,
                                width: 72,
                                height: 72,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  width: 72,
                                  height: 72,
                                  color: AppColors.surfaceElevated,
                                  child: const Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.accentCyan,
                                      ),
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  width: 72,
                                  height: 72,
                                  color: AppColors.surfaceElevated,
                                  child: const Icon(
                                    Icons.broken_image_rounded,
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                              )
                            : Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceElevated,
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.medium),
                                ),
                                child: const Icon(
                                  Icons.person_rounded,
                                  color: AppColors.textTertiary,
                                  size: 30,
                                ),
                              ),
                      ),
                      const SizedBox(width: AppSpacing.sm + AppSpacing.xs),
                      // Request details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    request.visitorName,
                                    style: AppTextStyles.subtitle.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                StatusBadge(status: request.status),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.phone_rounded,
                                    size: 12,
                                    color: AppColors.textTertiary),
                                const SizedBox(width: 4),
                                Text(
                                  request.visitorPhone,
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(Icons.category_rounded,
                                    size: 12,
                                    color: AppColors.textTertiary),
                                const SizedBox(width: 4),
                                Text(
                                  request.purpose,
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.access_time_rounded,
                                    size: 10,
                                    color: AppColors.textTertiary),
                                const SizedBox(width: 4),
                                Text(
                                  dateFormat
                                      .format(request.createdAt.toDate()),
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Action buttons
                  if (showActions)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.sm + AppSpacing.xs),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: onReject,
                              child: Container(
                                height: 44,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(AppRadius.pill),
                                  border: Border.all(
                                    color: AppColors.accentRed.withOpacity(0.6),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    'Reject',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.accentRed,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: GestureDetector(
                              onTap: onApprove,
                              child: Container(
                                height: 44,
                                decoration: BoxDecoration(
                                  gradient: AppGradients.success,
                                  borderRadius: BorderRadius.circular(AppRadius.pill),
                                ),
                                child: Center(
                                  child: Text(
                                    'Approve',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
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
