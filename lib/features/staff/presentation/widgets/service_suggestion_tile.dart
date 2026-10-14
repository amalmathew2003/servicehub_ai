import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ServiceSuggestionTile extends StatelessWidget {
  final String serviceName;
  final bool selected;
  final ValueChanged<bool> onChanged;

  const ServiceSuggestionTile({
    super.key,
    required this.serviceName,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: selected,
      onChanged: (value) => onChanged(value ?? false),
      activeColor: AppColors.primary,
      checkColor: Colors.white,
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      title: Text(
        serviceName,
        style: const TextStyle(
          color: AppColors.textLight,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}