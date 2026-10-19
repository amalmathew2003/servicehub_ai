import 'package:flutter/material.dart';
import 'package:service_hub_ai/core/theme/app_colors.dart';

/// A small pill-shaped badge that shows whether the staff member is
/// online (green) or offline (grey).
class StaffStatusPill extends StatelessWidget {
  final bool isOnline;

  const StaffStatusPill({super.key, required this.isOnline});

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFF00E676);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isOnline
            ? activeColor.withValues(alpha: 0.1)
            : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isOnline
              ? activeColor.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isOnline ? activeColor : Colors.grey,
            ),
          ),
          const SizedBox(width: 7),
          Text(
            isOnline ? 'ONLINE' : 'OFFLINE',
            style: TextStyle(
              color: isOnline ? activeColor : AppColors.textLightSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.7,
            ),
          ),
        ],
      ),
    );
  }
}
