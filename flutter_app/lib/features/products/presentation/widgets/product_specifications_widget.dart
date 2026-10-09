import 'package:flutter/material.dart';

class ProductSpecificationsWidget extends StatelessWidget {
  const ProductSpecificationsWidget({super.key, required this.specifications});

  final Map<String, dynamic> specifications;

  @override
  Widget build(BuildContext context) {
    if (specifications.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Specifications',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ...specifications.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(flex: 2, child: Text(entry.key)),
                    Expanded(flex: 3, child: Text(entry.value.toString())),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
