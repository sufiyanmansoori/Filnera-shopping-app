import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class ChoiceChipWidget extends StatelessWidget {
  const ChoiceChipWidget({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onSelected,
  });

  final String label;
  final bool isSelected;
  final ValueChanged<bool>? onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: AppColors.secondary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textPrimary,
      ),
      backgroundColor: Colors.white,
    );
  }
}
