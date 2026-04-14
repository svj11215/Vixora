/// Premium status badge with soft glow and icon.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vixora/core/constants/app_constants.dart';
import 'package:vixora/core/theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  /// The status string: 'pending', 'approved', or 'rejected'.
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final statusIcon = _getStatusIcon();
    final statusLabel = _getLabel();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 12, color: statusColor),
          const SizedBox(width: 4),
          Text(
            statusLabel.toUpperCase(),
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (status) {
      case AppConstants.statusApproved:
        return AppColors.accentGreen;
      case AppConstants.statusRejected:
        return AppColors.accentRed;
      case AppConstants.statusPending:
      default:
        return AppColors.accentAmber;
    }
  }

  IconData _getStatusIcon() {
    switch (status) {
      case AppConstants.statusApproved:
        return Icons.check_circle_rounded;
      case AppConstants.statusRejected:
        return Icons.cancel_rounded;
      case AppConstants.statusPending:
      default:
        return Icons.schedule_rounded;
    }
  }

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
