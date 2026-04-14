/// Screen for residents to view, approve, and reject visitor requests.
library;
import 'package:cached_network_image/cached_network_image.dart';
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
import 'package:vixora/widgets/status_badge.dart';
import 'package:vixora/widgets/visitor_request_card.dart';

class ResidentRequestsScreen extends StatefulWidget {
  const ResidentRequestsScreen({super.key});

  @override
  State<ResidentRequestsScreen> createState() => _ResidentRequestsScreenState();
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
      return const Center(child: Text('Not authenticated'));
    }

    final provider = context.read<VisitorRequestProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Visitor Requests'),
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.primaryColor,
          labelStyle: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
        ),
      ),
      body: Column(
        children: [
          // Resident code card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0D9488), Color(0xFF14B8A6)],
              ),
              borderRadius: BorderRadius.circular(AppTheme.cardRadius),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0D9488).withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.vpn_key, color: Colors.white, size: 22),
                const SizedBox(width: 12),
                Text(
                  'Your Resident Code: ',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
                Text(
                  currentUser.userCode,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 4,
                  ),
                ),
              ],
            ),
          ),

          // Requests list in tabs
          Expanded(
            child: StreamBuilder<List<VisitorRequestModel>>(
              stream: provider.residentRequestsStream(currentUser.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
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
                      onRefresh: () async {
                        await Future.delayed(
                            const Duration(milliseconds: 500));
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.only(top: 8, bottom: 16),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final request = filtered[index];
                          return VisitorRequestCard(
                            request: request,
                            onTap: () =>
                                _showDetailSheet(context, request),
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
    final theme = Theme.of(context);
    final noteController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Handle bar
                            Center(
                              child: Container(
                                width: 40,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Visitor photo
                            Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: request.imageUrl.isNotEmpty
                                    ? CachedNetworkImage(
                                        imageUrl: request.imageUrl,
                                        width: 200,
                                        height: 200,
                                        fit: BoxFit.cover,
                                        placeholder: (_, __) => Container(
                                          width: 200,
                                          height: 200,
                                          color: Colors.grey.shade200,
                                          child: const Center(
                                              child:
                                                  CircularProgressIndicator()),
                                        ),
                                        errorWidget: (_, __, ___) => Container(
                                          width: 200,
                                          height: 200,
                                          color: Colors.grey.shade200,
                                          child: const Icon(Icons.person,
                                              size: 60),
                                        ),
                                      )
                                    : Container(
                                        width: 200,
                                        height: 200,
                                        color: Colors.grey.shade200,
                                        child:
                                            const Icon(Icons.person, size: 60),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Center(
                                child: StatusBadge(status: request.status)),
                            const SizedBox(height: 20),
                            // Details
                            _buildDetailRow(Icons.person, 'Visitor Name',
                                request.visitorName, theme),
                            _buildDetailRow(Icons.phone, 'Phone',
                                request.visitorPhone, theme),
                            _buildDetailRow(Icons.label, 'Purpose',
                                request.purpose, theme),
                            _buildDetailRow(Icons.vpn_key, 'Resident Code',
                                request.residentCode, theme),
                            _buildDetailRow(
                                Icons.access_time,
                                'Created',
                                dateFormat
                                    .format(request.createdAt.toDate()),
                                theme),

                            if (request.approvedAt != null)
                              _buildDetailRow(
                                  Icons.check_circle,
                                  'Actioned At',
                                  dateFormat
                                      .format(request.approvedAt!.toDate()),
                                  theme),

                            if (request.resolutionNote != null &&
                                request.resolutionNote!.isNotEmpty)
                              _buildDetailRow(Icons.note, 'Resolution Note',
                                  request.resolutionNote!, theme),

                            // Action buttons for pending requests
                            if (request.isPending) ...[
                              const Divider(height: 32),
                              Text(
                                'Take Action',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Resolution note field
                              TextFormField(
                                controller: noteController,
                                decoration: const InputDecoration(
                                  labelText:
                                      'Add resolution note (optional)',
                                  prefixIcon: Icon(Icons.note_add_outlined),
                                ),
                                maxLines: 2,
                              ),
                              const SizedBox(height: 16),
                              // Approve / Reject buttons
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () => _updateStatus(
                                        context,
                                        request.id,
                                        AppConstants.statusApproved,
                                        noteController.text.trim(),
                                      ),
                                      icon: const Icon(Icons.check_circle),
                                      label: const Text('Approve'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            AppTheme.approvedColor,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () => _updateStatus(
                                        context,
                                        request.id,
                                        AppConstants.statusRejected,
                                        noteController.text.trim(),
                                      ),
                                      icon: const Icon(Icons.cancel),
                                      label: const Text('Reject'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            AppTheme.rejectedColor,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14),
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
      nav.pop(); // Close bottom sheet
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(
            status == AppConstants.statusApproved
                ? 'Visitor approved'
                : 'Visitor rejected',
          ),
          backgroundColor: status == AppConstants.statusApproved
              ? AppTheme.approvedColor
              : AppTheme.rejectedColor,
        ),
      );
    }
  }

  /// Builds a detail row for the bottom sheet.
  Widget _buildDetailRow(
      IconData icon, String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
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
        return Icons.hourglass_empty;
      case 'Approved':
        return Icons.check_circle_outline;
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
