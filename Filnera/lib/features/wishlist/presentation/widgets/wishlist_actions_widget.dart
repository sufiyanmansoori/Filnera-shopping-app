import 'package:flutter/material.dart';

class WishlistActionsWidget extends StatelessWidget {
  const WishlistActionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.compare_arrows),
            label: const Text('Compare'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.shopping_cart),
            label: const Text('Add All to Cart'),
          ),
        ),
      ],
    );
  }
}
