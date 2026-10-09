import 'package:flutter/material.dart';

class ReorderButton extends StatelessWidget {
  const ReorderButton({super.key, required this.onReorder});

  final VoidCallback onReorder;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: onReorder,
        icon: const Icon(Icons.repeat),
        label: const Text('Reorder'),
      ),
    );
  }
}
