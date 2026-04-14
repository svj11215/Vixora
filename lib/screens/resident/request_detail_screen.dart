/// Request detail screen with SliverAppBar and premium layout.
/// ALL existing logic, provider calls, navigation kept AS-IS.
library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vixora/core/constants/app_constants.dart';
import 'package:vixora/core/theme/app_theme.dart';
import 'package:vixora/models/visitor_request_model.dart';
import 'package:vixora/widgets/app_button.dart';
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
    return Scaffold(
      backgroundColor: AppColors.surfaceDarker,
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection(AppConstants.visitorRequestsCollection)
            .doc(widget.requestId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.accentCyan),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Text(
                'Request not found',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
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
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                backgroundColor: AppColors.surfaceDarker,
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
                        CachedNetworkImage(
                          imageUrl: requestModel.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: AppColors.surfaceElevated,
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.accentCyan,
                              ),
                            ),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: AppColors.surfaceElevated,
                            child: const Icon(
                              Icons.broken_image_rounded,
                              color: AppColors.textTertiary,
                              size: 60,
                            ),
                          ),
                        )
                      else
                        Container(
                          color: AppColors.surfaceElevated,
                          child: const Icon(
                            Icons.image_not_supported_rounded,
                            color: AppColors.textTertiary,
                            size: 60,
                          ),
                        ),
                      // Gradient overlay
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                AppColors.surfaceDarker,
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
                            ),
                          ),
                          StatusBadge(status: status),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatTimestamp(requestModel.createdAt),
                        style: AppTextStyles.caption,
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
                              color: AppColors.accentCyan,
                            ),
                            filled: true,
                            fillColor: AppColors.surfaceElevated,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppButton(
                          label: 'Approve Entry',
                          gradient: AppGradients.success,
                          icon: Icons.check_rounded,
                          width: double.infinity,
                          onPressed: () => _updateStatus(
                            context,
                            widget.requestId,
                            AppConstants.statusApproved,
                            requestModel.residentId,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm + AppSpacing.xs),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                                color: AppColors.accentRed),
                            minimumSize:
                                const Size(double.infinity, 52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  AppRadius.medium),
                            ),
                          ),
                          icon: const Icon(Icons.close_rounded,
                              color: AppColors.accentRed),
                          label: Text(
                            'Reject',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: AppColors.accentRed,
                            ),
                          ),
                          onPressed: () => _showRejectSheet(
                            context,
                            widget.requestId,
                            requestModel.residentId,
                          ),
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
      backgroundColor: AppColors.surfaceDark,
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
                  color: AppColors.textTertiary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
              const SizedBox(height: 20),
              Text('Rejection Reason', style: AppTextStyles.title),
              const SizedBox(height: 4),
              Text(
                'Optional — let guard know why',
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: noteController,
                style: AppTextStyles.body,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'e.g. Not expected today',
                  filled: true,
                  fillColor: AppColors.surfaceElevated,
                ),
              ),
              const SizedBox(height: 16),
              AppButton(
                label: 'Confirm Rejection',
                gradient: AppGradients.danger,
                width: double.infinity,
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Request ${newStatus.toLowerCase()}',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: newStatus == AppConstants.statusApproved
                ? AppColors.accentGreen
                : AppColors.accentRed,
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error updating request: $e',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: AppColors.accentRed,
          ),
        );
      }
    }
  }
}

/// Section wrapper with title and glass card children.
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
          Text(
            title,
            style: AppTextStyles.subtitle.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Divider(color: AppColors.surfaceBorder),
          const SizedBox(height: 4),
          ...children,
        ],
      ),
    );
  }
}

/// Detail row with icon, label, and value.
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
          Icon(icon, size: 16, color: AppColors.accentCyan),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.caption),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
