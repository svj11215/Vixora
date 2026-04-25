// UI_REDESIGN: Request detail screen with VixoraColors palette — revert by restoring original
/// Request detail screen with SliverAppBar and premium layout.
/// ALL existing logic, provider calls, navigation kept AS-IS.
library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:vixora/core/constants/app_constants.dart';
import 'package:vixora/core/theme/app_theme.dart';
import 'package:vixora/models/visitor_request_model.dart';

import 'package:vixora/widgets/glass_card.dart';
import 'package:vixora/widgets/status_badge.dart';

class RequestDetailScreen extends StatefulWidget {
  /// The ID of the visitor request document in Firestore.
  final String requestId;

  const RequestDetailScreen({required this.requestId, super.key});

  @override
  State<RequestDetailScreen> createState() => _RequestDetailScreenState();
}

class _RequestDetailScreenState extends State<RequestDetailScreen> {
  late final TextEditingController _resolutionNotesController;

  @override
  void initState() {
    super.initState();
    _resolutionNotesController = TextEditingController();
  }

  @override
  void dispose() {
    _resolutionNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sh = MediaQuery.of(context).size.height;

    return Scaffold(
      // UI_REDESIGN: VixoraColors.background — revert to AppColors.surfaceDarker
      backgroundColor: VixoraColors.background,
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection(AppConstants.visitorRequestsCollection)
            .doc(widget.requestId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              // UI_REDESIGN: Accent spinner — revert to AppColors.accentCyan
              child: CircularProgressIndicator(color: VixoraColors.accent),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Text(
                'Request not found',
                style: AppTextStyles.body.copyWith(
                  color: VixoraColors.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final requestModel = VisitorRequestModel.fromMap(
            data,
            widget.requestId,
          );
          final status = requestModel.status;

          return CustomScrollView(
            slivers: [
              // Sliver App Bar with hero image
              // UI_REDESIGN: Rounded bottom clip on hero — revert to default
              SliverAppBar(
                expandedHeight: sh * 0.32,
                pinned: true,
                backgroundColor: VixoraColors.background,
                leading: Padding(
                  padding: const EdgeInsets.all(8),
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(0.4),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_rounded,
                          color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (requestModel.imageUrl.isNotEmpty)
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(24),
                            bottomRight: Radius.circular(24),
                          ),
                          child: CachedNetworkImage(
                            imageUrl: requestModel.imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              color: VixoraColors.surfaceHigh,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: VixoraColors.accent,
                                ),
                              ),
                            ),
                            errorWidget: (_, __, ___) => Container(
                              color: VixoraColors.surfaceHigh,
                              child: const Icon(
                                Icons.broken_image_rounded,
                                color: VixoraColors.textHint,
                                size: 60,
                              ),
                            ),
                          ),
                        )
                      else
                        Container(
                          color: VixoraColors.surfaceHigh,
                          child: const Icon(
                            Icons.image_not_supported_rounded,
                            color: VixoraColors.textHint,
                            size: 60,
                          ),
                        ),
                      // Gradient overlay
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(24),
                              bottomRight: Radius.circular(24),
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                VixoraColors.background,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppSpacing.md),

                      // Visitor name + status
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              requestModel.visitorName,
                              style: AppTextStyles.headline,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          StatusBadge(status: status),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatTimestamp(requestModel.createdAt),
                        style: AppTextStyles.caption,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Visitor Information section
                      _DetailSection(
                        title: 'Visitor Information',
                        children: [
                          _DetailRow(
                            icon: Icons.person_rounded,
                            label: 'Name',
                            value: requestModel.visitorName,
                          ),
                          _DetailRow(
                            icon: Icons.phone_rounded,
                            label: 'Phone',
                            value: requestModel.visitorPhone,
                          ),
                          _DetailRow(
                            icon: Icons.category_rounded,
                            label: 'Purpose',
                            value: requestModel.purpose,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Request Details section
                      _DetailSection(
                        title: 'Request Details',
                        children: [
                          _DetailRow(
                            icon: Icons.badge_rounded,
                            label: 'Resident Code',
                            value: requestModel.residentCode,
                          ),
                          _DetailRow(
                            icon: Icons.schedule_rounded,
                            label: 'Submitted',
                            value: _formatTimestamp(
                                requestModel.createdAt),
                          ),
                          if (requestModel.approvedAt != null)
                            _DetailRow(
                              icon: Icons.done_all_rounded,
                              label: 'Resolved',
                              value: _formatTimestamp(
                                  requestModel.approvedAt!),
                            ),
                        ],
                      ),

                      // Resolution note
                      if (requestModel.resolutionNote != null &&
                          requestModel.resolutionNote!.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.md),
                        _DetailSection(
                          title: 'Resolution Note',
                          children: [
                            _DetailRow(
                              icon: Icons.note_rounded,
                              label: 'Note',
                              value: requestModel.resolutionNote!,
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: AppSpacing.xl),

                      // Action buttons — only if pending
                      if (status == AppConstants.statusPending) ...[
                        TextFormField(
                          controller: _resolutionNotesController,
                          style: AppTextStyles.body,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: 'Resolution note (optional)',
                            hintText:
                                'Add a note about your decision...',
                            prefixIcon: const Icon(
                              Icons.note_add_outlined,
                              color: VixoraColors.accent,
                            ),
                            filled: true,
                            fillColor: VixoraColors.surfaceHigh,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        // UI_REDESIGN: Row of approve/reject VixoraButtons — revert to AppButton + OutlinedButton
                        Row(
                          children: [
                            Expanded(
                              child: VixoraButton(
                                label: 'Approve',
                                icon: Icons.check_rounded,
                                color: VixoraColors.approved,
                                onPressed: () => _updateStatus(
                                  context,
                                  widget.requestId,
                                  AppConstants.statusApproved,
                                  requestModel.residentId,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: VixoraButton(
                                label: 'Reject',
                                icon: Icons.close_rounded,
                                color: VixoraColors.rejected,
                                onPressed: () => _showRejectSheet(
                                  context,
                                  widget.requestId,
                                  requestModel.residentId,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: AppSpacing.xl),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showRejectSheet(
      BuildContext context, String requestId, String residentId) {
    final noteController = TextEditingController();
    showModalBottomSheet(
      context: context,
      backgroundColor: VixoraColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xlarge),
        ),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: VixoraColors.textHint.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
              const SizedBox(height: 20),
              Text('Rejection Reason', style: AppTextStyles.title),
              const SizedBox(height: 4),
              Text(
                'Optional — let guard know why',
                style: AppTextStyles.caption,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: noteController,
                style: AppTextStyles.body,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'e.g. Not expected today',
                  filled: true,
                  fillColor: VixoraColors.surfaceHigh,
                ),
              ),
              const SizedBox(height: 16),
              VixoraButton(
                label: 'Confirm Rejection',
                color: VixoraColors.rejected,
                onPressed: () {
                  Navigator.pop(context);
                  _updateStatus(
                    context,
                    requestId,
                    AppConstants.statusRejected,
                    residentId,
                    note: noteController.text.trim(),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  /// Formats a Firestore Timestamp to a readable string.
  String _formatTimestamp(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// Updates the status of the visitor request in Firestore.
  Future<void> _updateStatus(
    BuildContext context,
    String requestId,
    String newStatus,
    String residentId, {
    String? note,
  }) async {
    try {
      final resolvedNote =
          note ?? _resolutionNotesController.text.trim();
      await FirebaseFirestore.instance
          .collection(AppConstants.visitorRequestsCollection)
          .doc(requestId)
          .update({
            AppConstants.fieldStatus: newStatus,
            AppConstants.fieldApprovedAt: FieldValue.serverTimestamp(),
            if (resolvedNote.isNotEmpty)
              AppConstants.fieldResolutionNote: resolvedNote,
          });

      if (context.mounted) {
        // UI_REDESIGN: VixoraSnack — revert to ScaffoldMessenger.showSnackBar
        VixoraSnack.show(
          context,
          'Request ${newStatus.toLowerCase()}',
          error: newStatus == AppConstants.statusRejected,
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        VixoraSnack.show(context, 'Error updating request: $e', error: true);
      }
    }
  }
}

/// Section wrapper with title and glass card children.
// UI_REDESIGN: Section header with lime accent bar — revert to plain text
class _DetailSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _DetailSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 18,
                decoration: BoxDecoration(
                  color: VixoraColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.subtitle.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Divider(color: VixoraColors.border),
          const SizedBox(height: 4),
          ...children,
        ],
      ),
    );
  }
}

/// Detail row with icon, label, and value.
// UI_REDESIGN: Accent icon color — revert to AppColors.accentCyan
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: VixoraColors.accent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: AppTextStyles.caption.copyWith(fontSize: 11)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
