import 'package:flutter/material.dart';

class ProductActionsWidget extends StatelessWidget {
  const ProductActionsWidget({
    super.key,
    required this.onAddToCart,
    required this.onWishlist,
    this.inWishlist = false,
  });

  final VoidCallback onAddToCart;
  final VoidCallback onWishlist;
  final bool inWishlist;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onAddToCart,
            icon: const Icon(Icons.add_shopping_cart_outlined),
            label: const Text('Add to Cart'),
          ),
        ),
        const SizedBox(width: 12),
        IconButton.filledTonal(
          onPressed: onWishlist,
          icon: Icon(inWishlist ? Icons.favorite : Icons.favorite_border),
          color: inWishlist ? Colors.red : null,
        ),
      ],
    );
  }
}
