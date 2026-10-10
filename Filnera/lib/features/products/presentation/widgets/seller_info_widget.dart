import 'package:flutter/material.dart';

class SellerInfoWidget extends StatelessWidget {
  const SellerInfoWidget({
    super.key,
    required this.sellerName,
    this.rating = 0,
    this.sellerImage,
  });

  final String sellerName;
  final double rating;
  final String? sellerImage;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              backgroundImage: sellerImage != null
                  ? NetworkImage(sellerImage!)
                  : null,
              child: sellerImage == null ? const Icon(Icons.storefront) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sellerName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(rating.toStringAsFixed(1)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
