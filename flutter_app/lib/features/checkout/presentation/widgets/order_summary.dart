import 'package:flutter/material.dart';

class OrderSummary extends StatelessWidget {
  const OrderSummary({super.key, required this.items});

  final List<Map<String, dynamic>> items;

  @override
  Widget build(BuildContext context) {
    final subtotal = items.fold<double>(0, (sum, item) {
      final price = double.tryParse(item['price']?.toString() ?? '0') ?? 0;
      final quantity = int.tryParse(item['quantity']?.toString() ?? '1') ?? 1;
      return sum + (price * quantity);
    });

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order summary',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          ...items.map((item) {
            final title = item['title']?.toString() ?? 'Product';
            final price =
                double.tryParse(item['price']?.toString() ?? '0') ?? 0;
            final quantity =
                int.tryParse(item['quantity']?.toString() ?? '1') ?? 1;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '$title × $quantity',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text('₹${(price * quantity).toStringAsFixed(0)}'),
                ],
              ),
            );
          }),
          const Divider(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal'),
              Text('₹${subtotal.toStringAsFixed(0)}'),
            ],
          ),
        ],
      ),
    );
  }
}
