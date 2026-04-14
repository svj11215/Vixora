/// Resident requests screen with premium access code card, pill tab bar, and shimmer loading.
/// ALL StreamBuilder, provider calls, and business logic kept AS-IS.
library;

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vixora/core/constants/app_constants.dart';
import 'package:vixora/core/theme/app_theme.dart';
import 'package:vixora/models/visitor_request_model.dart';
import 'package:vixora/providers/auth_provider.dart' as app;
import 'package:vixora/providers/visitor_request_provider.dart';
import 'package:vixora/widgets/empty_state_widget.dart';
import 'package:vixora/widgets/glass_card.dart';
import 'package:vixora/widgets/loading_overlay.dart';
import 'package:vixora/widgets/shimmer_loader.dart';
import 'package:vixora/widgets/visitor_request_card.dart';

class ResidentRequestsScreen extends StatefulWidget {
  const ResidentRequestsScreen({super.key});

  @override
  State<ResidentRequestsScreen> createState() =>
      _ResidentRequestsScreenState();
}

class _ResidentRequestsScreenState extends State<ResidentRequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _tabs = ['Pending', 'Approved', 'Rejected', 'All'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatCode(String code) {
    return code.split('').join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<app.AuthProvider>();
    final currentUser = authProvider.currentUser;
    if (currentUser == null) {
      return const Center(
        child: Text('Not authenticated',
            style: TextStyle(color: AppColors.textSecondary)),
      );
    }

    final provider = context.read<VisitorRequestProvider>();

    return Scaffold(
      backgroundColor: AppColors.surfaceDarker,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceDarker,
        title: Row(
          children: [
            const Icon(Icons.security_rounded,
                color: AppColors.accentCyan, size: 20),
            const SizedBox(width: 8),
            Text('Vixora', style: AppTextStyles.title),
          ],
        ),
        automaticallyImplyLeading: false,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: AppColors.surfaceBorder,
            height: 1,
          ),
        ),
      ),
      body: Column(
        children: [
          // Resident code card
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: FadeInDown(
              duration: const Duration(milliseconds: 400),
              child: GlassCard(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1E3A8A),
                    Color(0xFF1E40AF),
                    Color(0xFF0369A1),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.vpn_key_rounded,
                                  color: AppColors.accentCyan, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                'YOUR ACCESS CODE',
                                style: AppTextStyles.label.copyWith(
                                  color:
                                      AppColors.accentCyan.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _formatCode(currentUser.userCode),
                            style: GoogleFonts.poppins(
                              fontSize: 36,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Share this code with your guard',
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.white.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.shield_rounded,
                          color: Colors.white, size: 28),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Custom pill tab bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  gradient: AppGradients.accent,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: GoogleFonts.poppins(fontSize: 13),
                dividerColor: Colors.transparent,
                tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // Requests list in tabs
          Expanded(
            child: StreamBuilder<List<VisitorRequestModel>>(
              stream: provider.residentRequestsStream(currentUser.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const ShimmerList(count: 3);
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: AppTextStyles.body
                          .copyWith(color: AppColors.accentRed),
                    ),
                  );
                }

                final allRequests = snapshot.data ?? [];

                return TabBarView(
                  controller: _tabController,
                  children: _tabs.map((tab) {
                    final filtered = _filterByStatus(allRequests, tab);
                    if (filtered.isEmpty) {
                      return EmptyStateWidget(
                        icon: _getEmptyIcon(tab),
                        title: _getEmptyTitle(tab),
                        subtitle: _getEmptySubtitle(tab),
                      );
                    }

                    return RefreshIndicator(
                      color: AppColors.accentCyan,
                      backgroundColor: AppColors.surfaceDark,
                      onRefresh: () async {
                        await Future.delayed(
                            const Duration(milliseconds: 500));
                      },
                      child: ListView.separated(
                        padding: const EdgeInsets.only(
                            top: AppSpacing.sm, bottom: AppSpacing.md),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          final request = filtered[index];
                          final delay = (index * 50).clamp(0, 200);
                          return FadeInUp(
                            delay: Duration(milliseconds: delay),
                            duration: const Duration(milliseconds: 400),
                            child: VisitorRequestCard(
                              request: request,
                              onTap: () =>
                                  _showDetailSheet(context, request),
                            ),
                          );
                        },
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Filters requests by status tab.
  List<VisitorRequestModel> _filterByStatus(
      List<VisitorRequestModel> requests, String tab) {
    switch (tab) {
      case 'Pending':
        return requests.where((r) => r.isPending).toList();
      case 'Approved':
        return requests.where((r) => r.isApproved).toList();
      case 'Rejected':
        return requests.where((r) => r.isRejected).toList();
      default:
        return requests;
    }
  }

  /// Shows a detail bottom sheet with approve/reject actions.
  void _showDetailSheet(BuildContext context, VisitorRequestModel request) {
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    final noteController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.xlarge)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.75,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              expand: false,
              builder: (context, scrollController) {
                return Consumer<VisitorRequestProvider>(
                  builder: (context, provider, _) {
                    return LoadingOverlay(
                      isLoading: provider.isSubmitting,
                      message: 'Updating request...',
                      child: SingleChildScrollView(
                        controller: scrollController,
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Handle bar
                            Center(
                              child: Container(
                                width: 40,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: AppColors.textTertiary
                                      .withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(
                                      AppRadius.pill),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Visitor name + status
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    request.visitorName,
                                    style: AppTextStyles.headline,
                                  ),
                                ),
                                StatusBadgeInline(status: request.status),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              dateFormat
                                  .format(request.createdAt.toDate()),
                              style: AppTextStyles.caption,
                            ),
                            const SizedBox(height: 24),

                            // Detail rows
                            _buildDetailRow(Icons.person_rounded,
                                'Visitor Name', request.visitorName),
                            _buildDetailRow(Icons.phone_rounded,
                                'Phone', request.visitorPhone),
                            _buildDetailRow(Icons.category_rounded,
                                'Purpose', request.purpose),
                            _buildDetailRow(Icons.vpn_key_rounded,
                                'Resident Code', request.residentCode),
                            _buildDetailRow(
                                Icons.schedule_rounded,
                                'Submitted',
                                dateFormat.format(
                                    request.createdAt.toDate())),
                            if (request.approvedAt != null)
                              _buildDetailRow(
                                  Icons.done_all_rounded,
                                  'Resolved',
                                  dateFormat.format(
                                      request.approvedAt!.toDate())),
                            if (request.resolutionNote != null &&
                                request.resolutionNote!.isNotEmpty)
                              _buildDetailRow(Icons.note_rounded,
                                  'Note', request.resolutionNote!),

                            // Action buttons for pending requests
                            if (request.isPending) ...[
                              const SizedBox(height: 24),
                              // Resolution note field
                              TextFormField(
                                controller: noteController,
                                style: AppTextStyles.body,
                                decoration: InputDecoration(
                                  labelText:
                                      'Add resolution note (optional)',
                                  prefixIcon: const Icon(
                                      Icons.note_add_outlined,
                                      color: AppColors.accentCyan),
                                  filled: true,
                                  fillColor: AppColors.surfaceElevated,
                                ),
                                maxLines: 2,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => _updateStatus(
                                        context,
                                        request.id,
                                        AppConstants.statusApproved,
                                        noteController.text.trim(),
                                      ),
                                      child: Container(
                                        height: 52,
                                        decoration: BoxDecoration(
                                          gradient: AppGradients.success,
                                          borderRadius:
                                              BorderRadius.circular(
                                                  AppRadius.pill),
                                        ),
                                        child: Center(
                                          child: Row(
                                            mainAxisSize:
                                                MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                  Icons.check_rounded,
                                                  color: Colors.white,
                                                  size: 18),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Approve',
                                                style: GoogleFonts
                                                    .poppins(
                                                  fontSize: 15,
                                                  fontWeight:
                                                      FontWeight.w600,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => _updateStatus(
                                        context,
                                        request.id,
                                        AppConstants.statusRejected,
                                        noteController.text.trim(),
                                      ),
                                      child: Container(
                                        height: 52,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(
                                                  AppRadius.pill),
                                          border: Border.all(
                                            color: AppColors.accentRed
                                                .withOpacity(0.6),
                                          ),
                                        ),
                                        child: Center(
                                          child: Row(
                                            mainAxisSize:
                                                MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                  Icons.close_rounded,
                                                  color:
                                                      AppColors.accentRed,
                                                  size: 18),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Reject',
                                                style: GoogleFonts
                                                    .poppins(
                                                  fontSize: 15,
                                                  fontWeight:
                                                      FontWeight.w600,
                                                  color:
                                                      AppColors.accentRed,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  /// Updates the visitor request status.
  Future<void> _updateStatus(BuildContext context, String requestId,
      String status, String note) async {
    final nav = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final provider = context.read<VisitorRequestProvider>();
    final success = await provider.updateRequestStatus(
      requestId: requestId,
      status: status,
      resolutionNote: note.isNotEmpty ? note : null,
    );

    if (success) {
      nav.pop();
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(
            status == AppConstants.statusApproved
                ? 'Visitor approved'
                : 'Visitor rejected',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: status == AppConstants.statusApproved
              ? AppColors.accentGreen
              : AppColors.accentRed,
        ),
      );
    }
  }

  /// Builds a detail row for the bottom sheet.
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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

  /// Returns the empty state icon for each tab.
  IconData _getEmptyIcon(String tab) {
    switch (tab) {
      case 'Pending':
        return Icons.hourglass_empty_rounded;
      case 'Approved':
        return Icons.check_circle_outline_rounded;
      case 'Rejected':
        return Icons.cancel_outlined;
      default:
        return Icons.inbox_outlined;
    }
  }

  /// Returns the empty state title for each tab.
  String _getEmptyTitle(String tab) {
    switch (tab) {
      case 'Pending':
        return 'No Pending Requests';
      case 'Approved':
        return 'No Approved Requests';
      case 'Rejected':
        return 'No Rejected Requests';
      default:
        return 'No Requests Yet';
    }
  }

  /// Returns the empty state subtitle for each tab.
  String _getEmptySubtitle(String tab) {
    switch (tab) {
      case 'Pending':
        return 'You have no pending visitor requests to review.';
      case 'Approved':
        return 'No visitors have been approved yet.';
      case 'Rejected':
        return 'No visitors have been rejected.';
      default:
        return 'Visitor requests from the guard will appear here.';
    }
  }
}

/// Inline status badge used in bottom sheet (reuses StatusBadge logic).
class StatusBadgeInline extends StatelessWidget {
  final String status;
  const StatusBadgeInline({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final statusColor = _getColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Text(
        status.toUpperCase(),
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
          color: statusColor,
        ),
      ),
    );
  }

  Color _getColor() {
    switch (status) {
      case AppConstants.statusApproved:
        return AppColors.accentGreen;
      case AppConstants.statusRejected:
        return AppColors.accentRed;
      default:
        return AppColors.accentAmber;
    }
  }
}
