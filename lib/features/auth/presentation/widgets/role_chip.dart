import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class RoleChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const RoleChip({
    super.key,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.borderLight,
            width: 1.4,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 20,
              color: selected ? AppColors.iconLight : AppColors.iconDarkSecondary,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? AppColors.textLight : AppColors.textLightSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
