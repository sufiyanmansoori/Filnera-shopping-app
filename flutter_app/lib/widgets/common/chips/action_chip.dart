import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class ActionChipWidget extends StatelessWidget {
  const ActionChipWidget({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 16), const SizedBox(width: 6)],
          Text(label),
        ],
      ),
      onPressed: onPressed,
      backgroundColor: AppColors.background,
      labelStyle: const TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
