// UI_REDESIGN: Visitor request card with VixoraColors — revert by restoring original
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
  final VisitorRequestModel request;
  final VoidCallback onTap;
  final bool showActions;
  final VoidCallback? onApprove;
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
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
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
                      _buildPhoto(),
                      const SizedBox(width: AppSpacing.sm + AppSpacing.xs),
                      Expanded(child: _buildDetails(dateFormat)),
                    ],
                  ),
                  if (showActions) _buildActions(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoto() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.medium),
      child: request.imageUrl.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: request.imageUrl, width: 72, height: 72, fit: BoxFit.cover,
              placeholder: (_, __) => Container(width: 72, height: 72, color: VixoraColors.surfaceHigh,
                child: const Center(child: SizedBox(width: 20, height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: VixoraColors.accent)))),
              errorWidget: (_, __, ___) => Container(width: 72, height: 72, color: VixoraColors.surfaceHigh,
                child: const Icon(Icons.broken_image_rounded, color: VixoraColors.textHint)))
          : Container(width: 72, height: 72,
              decoration: BoxDecoration(color: VixoraColors.surfaceHigh, borderRadius: BorderRadius.circular(AppRadius.medium)),
              child: const Icon(Icons.person_rounded, color: VixoraColors.textHint, size: 30)),
    );
  }

  Widget _buildDetails(DateFormat dateFormat) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Text(request.visitorName, style: AppTextStyles.subtitle.copyWith(fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis)),
          StatusBadge(status: request.status),
        ]),
        const SizedBox(height: 4),
        _infoRow(Icons.phone_rounded, request.visitorPhone),
        const SizedBox(height: 2),
        _infoRow(Icons.category_rounded, request.purpose),
        const SizedBox(height: 4),
        Row(children: [
          const Icon(Icons.access_time_rounded, size: 10, color: VixoraColors.textHint),
          const SizedBox(width: 4),
          Flexible(child: Text(dateFormat.format(request.createdAt.toDate()),
            style: GoogleFonts.dmSans(fontSize: 10, color: VixoraColors.textHint), overflow: TextOverflow.ellipsis, maxLines: 1)),
        ]),
      ],
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(children: [
      Icon(icon, size: 12, color: VixoraColors.textHint),
      const SizedBox(width: 4),
      Flexible(child: Text(text, style: AppTextStyles.caption.copyWith(color: VixoraColors.textSecondary), overflow: TextOverflow.ellipsis, maxLines: 1)),
    ]);
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm + AppSpacing.xs),
      child: Row(children: [
        Expanded(child: GestureDetector(onTap: onReject, child: Container(height: 44,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(color: VixoraColors.rejected.withOpacity(0.6))),
          child: Center(child: Text('Reject', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w700, color: VixoraColors.rejected)))))),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: GestureDetector(onTap: onApprove, child: Container(height: 44,
          decoration: BoxDecoration(gradient: AppGradients.success, borderRadius: BorderRadius.circular(AppRadius.pill)),
          child: Center(child: Text('Approve', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)))))),
      ]),
    );
  }
}
