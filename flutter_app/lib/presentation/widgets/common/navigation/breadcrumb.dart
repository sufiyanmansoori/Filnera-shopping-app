import 'package:flutter/material.dart';

class Breadcrumb extends StatelessWidget {
  const Breadcrumb({super.key, required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: List.generate(items.length, (index) {
        final item = items[index];
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(item),
            if (index < items.length - 1) const Icon(Icons.chevron_right),
          ],
        );
      }),
    );
  }
}
