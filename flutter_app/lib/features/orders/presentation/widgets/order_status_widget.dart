import 'package:flutter/material.dart';

class OrderStatusWidget extends StatelessWidget {
  const OrderStatusWidget({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status.toLowerCase()) {
      'delivered' => Colors.green,
      'cancelled' => Colors.red,
      'returned' => Colors.orange,
      _ => Colors.blue,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.local_shipping_outlined, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                status.toUpperCase(),
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
