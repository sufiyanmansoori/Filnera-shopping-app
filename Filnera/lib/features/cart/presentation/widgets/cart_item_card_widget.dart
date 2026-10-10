import 'package:flutter/material.dart';

import '../../data/models/cart_item_model.dart';

class CartItemCardWidget extends StatelessWidget {
  const CartItemCardWidget({super.key, required this.item});

  final CartItemModel item;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item.productImage.isNotEmpty
                    ? item.productImage
                    : 'https://placehold.co/120x120',
                width: 90,
                height: 90,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox(
                  width: 90,
                  height: 90,
                  child: Center(
                    child: Icon(Icons.image_not_supported_outlined),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Variant: ${item.variant}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    'Seller: ${item.seller}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₹${item.price.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
                Text(
                  '${item.quantity}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                IconButton(onPressed: () {}, icon: const Icon(Icons.remove)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
