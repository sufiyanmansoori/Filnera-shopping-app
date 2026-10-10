import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class FloatingActionButtonWidget extends StatelessWidget {
  const FloatingActionButtonWidget({
    super.key,
    required this.icon,
    this.onPressed,
    this.label,
    this.extended = false,
    this.backgroundColor,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? label;
  final bool extended;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    if (extended && label != null) {
      return FloatingActionButton.extended(
        onPressed: onPressed,
        backgroundColor: backgroundColor ?? AppColors.primary,
        foregroundColor: Colors.white,
        icon: Icon(icon),
        label: Text(label!),
      );
    }

    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: backgroundColor ?? AppColors.primary,
      foregroundColor: Colors.white,
      child: Icon(icon),
    );
  }
}
