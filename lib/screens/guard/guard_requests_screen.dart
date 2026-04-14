/// Premium screen showing all visitor requests submitted by the guard.
/// ALL stream builders, deletion logic, and filtering logic kept AS-IS.
library;

import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vixora/core/theme/app_theme.dart';
import 'package:vixora/models/visitor_request_model.dart';
import 'package:vixora/providers/auth_provider.dart' as app;
import 'package:vixora/providers/visitor_request_provider.dart';
import 'package:vixora/widgets/empty_state_widget.dart';
import 'package:vixora/widgets/shimmer_loader.dart';
import 'package:vixora/widgets/status_badge.dart';
import 'package:vixora/widgets/visitor_request_card.dart';
import 'package:vixora/core/utils/page_transitions.dart';
import 'package:vixora/screens/auth/login_screen.dart';

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
      backgroundColor: AppColors.surfaceDarker,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceDarker,
        title: Row(
          children: [
            const Icon(Icons.list_alt_rounded, color: AppColors.accentCyan),
            const SizedBox(width: 8),
            Text('My Requests', style: AppTextStyles.title),
          ],
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.textSecondary),
            tooltip: 'Sign Out',
            onPressed: () => _signOut(context),
          ),
          const SizedBox(width: 8),
        ],
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
          // Filter bar
          _buildDateFilterBar(),

          // List body
          Expanded(
            child: StreamBuilder<List<VisitorRequestModel>>(
              stream: provider.guardRequestsStream(currentUser.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const ShimmerList(count: 4);
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.accentRed,
                      ),
                    ),
                  );
                }

                final allRequests = snapshot.data ?? [];
                final filteredRequests = _filterByDate(allRequests);

                if (filteredRequests.isEmpty) {
                  return const EmptyStateWidget(
                    icon: Icons.history_rounded,
                    title: 'No Requests Found',
                    subtitle: 'Visitor requests you submit will appear here.',
                  );
                }

                return RefreshIndicator(
                  color: AppColors.accentCyan,
                  backgroundColor: AppColors.surfaceDark,
                  onRefresh: () async {
                    await Future.delayed(const Duration(milliseconds: 500));
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.only(
                      top: AppSpacing.sm,
                      bottom: AppSpacing.xl,
                    ),
                    itemCount: filteredRequests.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) {
                      final request = filteredRequests[index];
                      final delay = (index * 50).clamp(0, 200);
                      return FadeInUp(
                        delay: Duration(milliseconds: delay),
                        duration: const Duration(milliseconds: 400),
                        child: VisitorRequestCard(
                          request: request,
                          onTap: () => _showDetailSheet(context, request),
                        ),
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

  /// Builds the custom animated premium filter chips.
  Widget _buildDateFilterBar() {
    final options = ['Today', 'This Week', 'All'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Row(
        children: options.map((label) {
          final isSelected = _dateFilter == label;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _dateFilter = label),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.accentCyan.withOpacity(0.15) : AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(
                    color: isSelected ? AppColors.accentCyan : AppColors.surfaceBorder,
                    width: 1,
                  ),
                ),
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? AppColors.accentCyan : AppColors.textSecondary,
                  ),
                ),
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

  /// Shows a premium bottom sheet with full request details.
  void _showDetailSheet(BuildContext context, VisitorRequestModel request) {
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xlarge)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
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
                        color: AppColors.textTertiary.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Visitor photo
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: request.imageUrl.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: request.imageUrl,
                                width: 140,
                                height: 140,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => Container(
                                  width: 140,
                                  height: 140,
                                  color: AppColors.surfaceElevated,
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      color: AppColors.accentCyan,
                                    ),
                                  ),
                                ),
                                errorWidget: (_, __, ___) => Container(
                                  width: 140,
                                  height: 140,
                                  color: AppColors.surfaceElevated,
                                  child: const Icon(
                                    Icons.broken_image_rounded,
                                    size: 40,
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                              )
                            : Container(
                                width: 140,
                                height: 140,
                                color: AppColors.surfaceElevated,
                                child: const Icon(
                                  Icons.person_rounded,
                                  size: 40,
                                  color: AppColors.textTertiary,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Status
                  Center(child: StatusBadge(status: request.status)),
                  const SizedBox(height: AppSpacing.lg),

                  // Details List
                  _buildDetailRow(Icons.person_outline_rounded, 'Visitor Name', request.visitorName),
                  _buildDetailRow(Icons.phone_outlined, 'Phone', request.visitorPhone),
                  _buildDetailRow(Icons.category_outlined, 'Purpose', request.purpose),
                  _buildDetailRow(Icons.vpn_key_outlined, 'Resident Code', request.residentCode),
                  _buildDetailRow(Icons.access_time_rounded, 'Created', dateFormat.format(request.createdAt.toDate())),
                  
                  if (request.approvedAt != null)
                    _buildDetailRow(Icons.check_circle_outline_rounded, 'Actioned At', dateFormat.format(request.approvedAt!.toDate())),
                  if (request.resolutionNote != null && request.resolutionNote!.isNotEmpty)
                    _buildDetailRow(Icons.note_outlined, 'Resolution Note', request.resolutionNote!),

                  // Delete button for pending requests
                  if (request.isPending) ...[
                    const SizedBox(height: AppSpacing.xl),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _confirmDelete(context, request.id),
                        icon: const Icon(Icons.delete_outline_rounded, color: AppColors.accentRed),
                        label: Text(
                          'Delete Request',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: AppColors.accentRed,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.accentRed.withOpacity(0.5)),
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
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.accentCyan),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
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

  /// Shows a confirmation dialog before deleting a request.
  void _confirmDelete(BuildContext context, String requestId) {
    final nav = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Request', style: AppTextStyles.title),
        content: Text(
          'Are you sure you want to delete this visitor request? This action cannot be undone.',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              nav.pop(); // Close bottom sheet
              final provider = context.read<VisitorRequestProvider>();
              final success = await provider.deleteRequest(requestId);
              if (success) {
                // Not perfectly safe inside async gap but fine for this scope
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      'Request deleted permanently',
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                    backgroundColor: AppColors.accentRed,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentRed,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    final authProvider = context.read<app.AuthProvider>();
    await authProvider.signOut();
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        VixoraPageRoute(page: const LoginScreen()),
      );
    }
  }
}
