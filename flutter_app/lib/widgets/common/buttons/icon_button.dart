import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.size = 44,
    this.radius = 14,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double size;
  final double radius;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final widget = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.background,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: foregroundColor ?? AppColors.textPrimary),
        tooltip: tooltip,
        splashRadius: size * 0.6,
      ),
    );

    return widget;
  }
}
