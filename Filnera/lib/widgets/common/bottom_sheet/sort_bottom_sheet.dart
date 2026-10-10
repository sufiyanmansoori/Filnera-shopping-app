import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import 'custom_bottom_sheet.dart';

class SortBottomSheet extends StatelessWidget {
  const SortBottomSheet({
    super.key,
    required this.options,
    this.selectedValue,
    this.onSelected,
  });

  final List<String> options;
  final String? selectedValue;
  final ValueChanged<String>? onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BottomSheetHeader(title: 'Sort By'),
          const SizedBox(height: 12),
          ...options.map((option) {
            final isSelected = option == selectedValue;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(option),
              trailing: isSelected
                  ? const Icon(Icons.check_rounded, color: AppColors.primary)
                  : null,
              onTap: () {
                onSelected?.call(option);
                Navigator.of(context).pop();
              },
            );
          }),
        ],
      ),
    );
  }
}
