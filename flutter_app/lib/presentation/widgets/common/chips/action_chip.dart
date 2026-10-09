import 'package:flutter/material.dart';

class ActionChipWidget extends StatelessWidget {
  const ActionChipWidget({super.key, required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ActionChip(label: Text(label), onPressed: onPressed);
  }
}
