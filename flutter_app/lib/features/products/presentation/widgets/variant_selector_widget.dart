import 'package:flutter/material.dart';

class VariantSelectorWidget extends StatelessWidget {
  const VariantSelectorWidget({
    super.key,
    required this.variants,
    required this.selectedVariant,
    required this.onChanged,
  });

  final List<String> variants;
  final String selectedVariant;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: variants.map((variant) {
        final isSelected = variant == selectedVariant;
        return ChoiceChip(
          label: Text(variant),
          selected: isSelected,
          onSelected: (_) => onChanged(variant),
        );
      }).toList(),
    );
  }
}
