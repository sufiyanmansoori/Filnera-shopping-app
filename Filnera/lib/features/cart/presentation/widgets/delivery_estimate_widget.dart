import 'package:flutter/material.dart';

class DeliveryEstimateWidget extends StatelessWidget {
  const DeliveryEstimateWidget({super.key, required this.estimate});

  final String estimate;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.local_shipping_outlined),
            const SizedBox(width: 8),
            Expanded(child: Text('Estimated delivery: $estimate')),
          ],
        ),
      ),
    );
  }
}
