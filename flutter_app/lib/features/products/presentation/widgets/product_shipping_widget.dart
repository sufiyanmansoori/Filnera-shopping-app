import 'package:flutter/material.dart';

class ProductShippingWidget extends StatelessWidget {
  const ProductShippingWidget({super.key, required this.shipping});

  final Map<String, dynamic> shipping;

  @override
  Widget build(BuildContext context) {
    final deliveryText =
        shipping['deliveryText']?.toString() ??
        shipping['text']?.toString() ??
        shipping['eta']?.toString() ??
        'Delivery available';
    final freeShipping = shipping['freeShipping'] as bool? ?? false;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.local_shipping_outlined),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                freeShipping ? 'Free shipping • $deliveryText' : deliveryText,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
