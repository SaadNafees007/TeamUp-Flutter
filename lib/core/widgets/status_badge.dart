import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final String? customText;

  const StatusBadge({super.key, required this.status, this.customText});

  @override
  Widget build(BuildContext context) {
    final lower = status.toLowerCase();
    Color bg;
    Color fg;
    IconData icon;

    switch (lower) {
      case 'accepted':
        bg = AppColors.statusAcceptedLight;
        fg = AppColors.statusAccepted;
        icon = Icons.check_circle_outline_rounded;
        break;
      case 'rejected':
        bg = AppColors.statusRejectedLight;
        fg = AppColors.statusRejected;
        icon = Icons.cancel_outlined;
        break;
      case 'cancelled':
        bg = AppColors.statusCancelledLight;
        fg = AppColors.statusCancelled;
        icon = Icons.remove_circle_outline_rounded;
        break;
      case 'expired':
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFFDC2626);
        icon = Icons.timer_off_outlined;
        break;
      case 'pending':
      default:
        bg = AppColors.statusPendingLight;
        fg = AppColors.statusPending;
        icon = Icons.hourglass_top_rounded;
        break;
    }

    final displayText = customText ?? status.toUpperCase();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 4),
          Text(
            displayText,
            style: TextStyle(
              color: fg,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
