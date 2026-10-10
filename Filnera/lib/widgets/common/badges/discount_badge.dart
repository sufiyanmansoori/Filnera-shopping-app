import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class DiscountBadge extends StatelessWidget {
  const DiscountBadge({super.key, required this.percent});

  final String percent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$percent OFF',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 10,
        ),
      ),
    );
  }
}
