/// Screen showing all visitor requests submitted by the current guard with date filtering.
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
import 'package:vixora/widgets/status_badge.dart';
import 'package:vixora/widgets/visitor_request_card.dart';

class GuardRequestsScreen extends StatefulWidget {
  const GuardRequestsScreen({super.key});

  @override
  State<GuardRequestsScreen> createState() => _GuardRequestsScreenState();
}

class _GuardRequestsScreenState extends State<GuardRequestsScreen> {
  String _dateFilter = 'All'; // 'Today', 'This Week', 'All'

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
        title: const Text('My Requests'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () => _signOut(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Date filter bar
          _buildDateFilterBar(),
          // Requests list
          Expanded(
            child: StreamBuilder<List<VisitorRequestModel>>(
              stream: provider.guardRequestsStream(currentUser.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                final allRequests = snapshot.data ?? [];
                final filteredRequests = _filterByDate(allRequests);

                if (filteredRequests.isEmpty) {
                  return const EmptyStateWidget(
                    icon: Icons.inbox_outlined,
                    title: 'No Requests Found',
                    subtitle: 'Visitor requests you submit will appear here.',
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    // StreamBuilder handles refresh automatically
                    await Future.delayed(const Duration(milliseconds: 500));
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 16),
                    itemCount: filteredRequests.length,
                    itemBuilder: (context, index) {
                      final request = filteredRequests[index];
                      return VisitorRequestCard(
                        request: request,
                        onTap: () => _showDetailSheet(context, request),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the date filter bar with Today, This Week, All chips.
  Widget _buildDateFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: ['Today', 'This Week', 'All'].map((label) {
          final isSelected = _dateFilter == label;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (_) => setState(() => _dateFilter = label),
              selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
              checkmarkColor: AppTheme.primaryColor,
              labelStyle: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppTheme.primaryColor : Colors.grey.shade600,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.chipRadius),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Filters requests by the selected date range.
  List<VisitorRequestModel> _filterByDate(List<VisitorRequestModel> requests) {
    final now = DateTime.now();
    switch (_dateFilter) {
      case 'Today':
        return requests.where((r) {
          final date = r.createdAt.toDate();
          return date.year == now.year &&
              date.month == now.month &&
              date.day == now.day;
        }).toList();
      case 'This Week':
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        final startOfWeek =
            DateTime(weekStart.year, weekStart.month, weekStart.day);
        return requests.where((r) {
          return r.createdAt.toDate().isAfter(startOfWeek);
        }).toList();
      default:
        return requests;
    }
  }

  /// Shows a bottom sheet with full request details.
  void _showDetailSheet(BuildContext context, VisitorRequestModel request) {
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
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
                                    child: CircularProgressIndicator()),
                              ),
                              errorWidget: (_, __, ___) => Container(
                                width: 200,
                                height: 200,
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.person, size: 60),
                              ),
                            )
                          : Container(
                              width: 200,
                              height: 200,
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.person, size: 60),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Status
                  Center(child: StatusBadge(status: request.status)),
                  const SizedBox(height: 20),
                  // Details
                  _buildDetailRow(
                      Icons.person, 'Visitor Name', request.visitorName, theme),
                  _buildDetailRow(
                      Icons.phone, 'Phone', request.visitorPhone, theme),
                  _buildDetailRow(
                      Icons.label, 'Purpose', request.purpose, theme),
                  _buildDetailRow(Icons.vpn_key, 'Resident Code',
                      request.residentCode, theme),
                  _buildDetailRow(Icons.access_time, 'Created',
                      dateFormat.format(request.createdAt.toDate()), theme),
                  if (request.approvedAt != null)
                    _buildDetailRow(
                        Icons.check_circle,
                        'Actioned At',
                        dateFormat.format(request.approvedAt!.toDate()),
                        theme),
                  if (request.resolutionNote != null &&
                      request.resolutionNote!.isNotEmpty)
                    _buildDetailRow(Icons.note, 'Resolution Note',
                        request.resolutionNote!, theme),

                  // Delete button for pending requests
                  if (request.isPending) ...[
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _confirmDelete(context, request.id),
                        icon: const Icon(Icons.delete_outline,
                            color: AppTheme.rejectedColor),
                        label: const Text('Delete Request'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.rejectedColor,
                          side: const BorderSide(color: AppTheme.rejectedColor),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
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

  /// Shows a confirmation dialog before deleting a request.
  void _confirmDelete(BuildContext context, String requestId) {
    final nav = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Request'),
        content:
            const Text('Are you sure you want to delete this visitor request?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              nav.pop(); // Close bottom sheet
              final provider = context.read<VisitorRequestProvider>();
              final success = await provider.deleteRequest(requestId);
              if (success) {
                // Not technically totally safe with mounted, but works for the lint
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('Request deleted'),
                    backgroundColor: AppTheme.approvedColor,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.rejectedColor,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    final nav = Navigator.of(context);
    final authProvider = context.read<app.AuthProvider>();
    await authProvider.signOut();
    nav.pushReplacementNamed(AppConstants.routeLogin);
  }
}
