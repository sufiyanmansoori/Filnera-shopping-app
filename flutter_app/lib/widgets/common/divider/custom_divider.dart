import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class CustomDivider extends StatelessWidget {
  const CustomDivider({super.key, this.height = 1, this.color, this.margin});

  final double height;
  final Color? color;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: margin,
      color: color ?? AppColors.border,
    );
  }
}
