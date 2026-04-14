/// Pill-shaped status badge widget with color-coded background for pending/approved/rejected.
library;
import 'package:flutter/material.dart';
import 'package:vixora/core/constants/app_constants.dart';
import 'package:vixora/core/theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  /// The status string: 'pending', 'approved', or 'rejected'.
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(AppTheme.chipRadius),
      ),
      child: Text(
        _getLabel(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Returns the background color based on status.
  Color _getBackgroundColor() {
    switch (status) {
      case AppConstants.statusApproved:
        return AppTheme.approvedColor;
      case AppConstants.statusRejected:
        return AppTheme.rejectedColor;
      case AppConstants.statusPending:
      default:
        return AppTheme.pendingColor;
    }
  }

  /// Returns the capitalized label text.
  String _getLabel() {
    switch (status) {
      case AppConstants.statusApproved:
        return 'Approved';
      case AppConstants.statusRejected:
        return 'Rejected';
      case AppConstants.statusPending:
      default:
        return 'Pending';
    }
  }
}
