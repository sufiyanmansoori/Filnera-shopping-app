import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class CustomProgressIndicator extends StatelessWidget {
  const CustomProgressIndicator({
    super.key,
    this.value,
    this.backgroundColor,
    this.valueColor,
  });

  final double? value;
  final Color? backgroundColor;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: value,
      minHeight: 8,
      borderRadius: BorderRadius.circular(8),
      backgroundColor: backgroundColor ?? AppColors.border,
      valueColor: AlwaysStoppedAnimation<Color>(
        valueColor ?? AppColors.primary,
      ),
    );
  }
}
