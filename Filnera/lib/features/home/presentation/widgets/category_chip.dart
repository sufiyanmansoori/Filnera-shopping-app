import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onPressed(),
      selectedColor: AppColors.primary,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textSecondary,
        fontWeight: FontWeight.w600,
      ),
      side: const BorderSide(color: AppColors.border),
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    );
  }
}
