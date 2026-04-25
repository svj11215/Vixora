// UI_REDESIGN: Resident requests screen with lime+cyan palette — revert by restoring original
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

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<app.AuthProvider>();
    final currentUser = authProvider.currentUser;
    if (currentUser == null) {
      return const Center(
        child: Text('Not authenticated',
            style: TextStyle(color: VixoraColors.textSecondary)),
      );
    }

    final provider = context.read<VisitorRequestProvider>();
    // UI_REDESIGN: Responsive padding — revert to fixed AppSpacing.md
    final sw = MediaQuery.of(context).size.width;
    final hPad = (sw * 0.044).clamp(14.0, 20.0);

    return Scaffold(
      // UI_REDESIGN: VixoraColors.background scaffold — revert to AppColors.surfaceDarker
      backgroundColor: VixoraColors.background,
      appBar: AppBar(
        backgroundColor: VixoraColors.background,
        title: Row(
          children: [
            // UI_REDESIGN: Primary-colored icon — revert to AppColors.accentCyan
            const Icon(Icons.security_rounded,
                color: VixoraColors.primary, size: 20),
            const SizedBox(width: 8),
            Text('Vixora', style: AppTextStyles.title),
          ],
        ),
        automaticallyImplyLeading: false,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: VixoraColors.border,
            height: 1,
          ),
        ),
      ),
      body: Column(
        children: [
          // Resident code card
          // UI_REDESIGN: New access code card with glowing border — revert to old GlassCard gradient
          Padding(
            padding: EdgeInsets.all(hPad),
            child: FadeInDown(
              duration: const Duration(milliseconds: 400),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: VixoraColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.large),
                  border: Border.all(color: VixoraColors.borderGlow),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'YOUR ACCESS CODE',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: VixoraColors.textSecondary,
                            letterSpacing: 2,
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.copy_rounded,
                            size: 18, color: VixoraColors.accent),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // UI_REDESIGN: Individual digit containers — revert to single Text
                    Row(
                      children: currentUser.userCode
                          .split('')
                          .map((digit) => Expanded(
                                child: Container(
                                  height: 64,
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 3),
                                  decoration: BoxDecoration(
                                    color: VixoraColors.surfaceHigh,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: VixoraColors.border),
                                  ),
                                  child: Center(
                                    child: Text(
                                      digit,
                                      style: GoogleFonts.dmSans(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w800,
                                        color: VixoraColors.primary,
                                      ),
                                    ),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Share this code with your guard',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: VixoraColors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // UI_REDESIGN: Pill tab bar with lime active color — revert to old gradient indicator
          Padding(
            padding: EdgeInsets.symmetric(horizontal: hPad),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: VixoraColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: VixoraColors.primary,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: VixoraColors.background,
                unselectedLabelColor: VixoraColors.textSecondary,
                labelStyle: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: GoogleFonts.dmSans(fontSize: 13),
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
                          .copyWith(color: VixoraColors.rejected),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
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
                      // UI_REDESIGN: Primary refresh color — revert to AppColors.accentCyan
                      color: VixoraColors.primary,
                      backgroundColor: VixoraColors.surface,
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
      // UI_REDESIGN: VixoraColors.surface sheet — revert to AppColors.surfaceDark
      backgroundColor: VixoraColors.surface,
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
                                  color: VixoraColors.textHint
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
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                                // UI_REDESIGN: StatusChip — revert to StatusBadgeInline
                                StatusChip(status: request.status),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              dateFormat
                                  .format(request.createdAt.toDate()),
                              style: AppTextStyles.caption,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
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
                                      color: VixoraColors.accent),
                                  filled: true,
                                  fillColor: VixoraColors.surfaceHigh,
                                ),
                                maxLines: 2,
                              ),
                              const SizedBox(height: 16),
                              // UI_REDESIGN: Approve/Reject buttons with new colors — revert to old gradients
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
                                                    .dmSans(
                                                  fontSize: 15,
                                                  fontWeight:
                                                      FontWeight.w700,
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
                                            color: VixoraColors.rejected
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
                                                      VixoraColors.rejected,
                                                  size: 18),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Reject',
                                                style: GoogleFonts
                                                    .dmSans(
                                                  fontSize: 15,
                                                  fontWeight:
                                                      FontWeight.w700,
                                                  color:
                                                      VixoraColors.rejected,
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
      // UI_REDESIGN: VixoraSnack — revert to ScaffoldMessenger.showSnackBar
      VixoraSnack.show(
        scaffoldMessenger.context,
        status == AppConstants.statusApproved
            ? 'Visitor approved'
            : 'Visitor rejected',
        error: status == AppConstants.statusRejected,
      );
    }
  }

  /// Builds a detail row for the bottom sheet.
  // UI_REDESIGN: Detail row with accent icon — revert to AppColors.accentCyan
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: VixoraColors.accent),
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
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
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
