import 'package:flutter/material.dart';

class PriceBreakdownWidget extends StatelessWidget {
  const PriceBreakdownWidget({
    super.key,
    required this.subtotal,
    required this.discount,
    required this.deliveryFee,
  });

  final double subtotal;
  final double discount;
  final double deliveryFee;

  @override
  Widget build(BuildContext context) {
    final total = subtotal - discount + deliveryFee;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _priceRow('Subtotal', subtotal),
            _priceRow('Discount', -discount),
            _priceRow('Delivery', deliveryFee),
            const Divider(),
            _priceRow('Total', total, isBold: true),
          ],
        ),
      ),
    );
  }

  Widget _priceRow(String title, double value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(
            '₹${value.toStringAsFixed(2)}',
            style: isBold ? const TextStyle(fontWeight: FontWeight.bold) : null,
          ),
        ],
      ),
    );
  }
}
