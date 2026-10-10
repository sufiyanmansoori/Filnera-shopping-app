import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class Breadcrumb extends StatelessWidget {
  const Breadcrumb({super.key, required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(items.length, (index) {
        final item = items[index];
        final isLast = index == items.length - 1;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              item,
              style: TextStyle(
                color: isLast ? AppColors.textPrimary : AppColors.textSecondary,
                fontWeight: isLast ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            if (!isLast)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        );
      }),
    );
  }
}
