import 'package:flutter/material.dart';

class ProductPriceWidget extends StatelessWidget {
  const ProductPriceWidget({super.key, required this.price, this.oldPrice});

  final double price;
  final double? oldPrice;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '₹${price.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (oldPrice != null && oldPrice! > price) ...[
          const SizedBox(width: 8),
          Text(
            '₹${oldPrice!.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              decoration: TextDecoration.lineThrough,
              color: Colors.grey,
            ),
          ),
        ],
      ],
    );
  }
}
