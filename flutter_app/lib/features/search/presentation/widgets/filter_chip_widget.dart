import 'package:flutter/material.dart';

class FilterChipWidget extends StatelessWidget {
  const FilterChipWidget({
    super.key,
    required this.label,
    required this.selected,
    this.onSelected,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool>? onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      selectedColor: Theme.of(context).colorScheme.primary
          .withValues(alpha: 0.18),
      onSelected: onSelected,
    );
  }
}
