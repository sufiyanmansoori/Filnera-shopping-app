import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import 'custom_bottom_sheet.dart';

class FilterBottomSheet extends StatelessWidget {
  const FilterBottomSheet({
    super.key,
    required this.options,
    this.selectedValues = const <String>[],
    this.onApply,
    this.onClear,
  });

  final List<String> options;
  final List<String> selectedValues;
  final ValueChanged<List<String>>? onApply;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final selected = List<String>.from(selectedValues);

    return StatefulBuilder(
      builder: (context, setState) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BottomSheetHeader(title: 'Filter'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: options.map((option) {
                  final isSelected = selected.contains(option);
                  return ChoiceChip(
                    label: Text(option),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    onSelected: (_) {
                      setState(() {
                        if (isSelected) {
                          selected.remove(option);
                        } else {
                          selected.add(option);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed:
                          onClear ?? () => setState(() => selected.clear()),
                      child: const Text('Clear'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        onApply?.call(List<String>.from(selected));
                        Navigator.of(context).pop();
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
