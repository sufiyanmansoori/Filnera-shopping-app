import 'package:flutter/material.dart';

class OrderTimelineWidget extends StatelessWidget {
  const OrderTimelineWidget({super.key, required this.timeline});

  final List<String> timeline;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Timeline', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ...timeline.map(
              (step) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(step)),
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
