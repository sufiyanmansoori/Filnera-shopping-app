import 'package:flutter/material.dart';

class FloatingActionButtonWidget extends StatelessWidget {
  const FloatingActionButtonWidget({
    super.key,
    required this.icon,
    required this.onPressed,
    this.label,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      icon: Icon(icon),
      label: label == null ? const SizedBox.shrink() : Text(label!),
    );
  }
}
