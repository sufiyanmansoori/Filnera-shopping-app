import 'package:flutter/material.dart';

class CartBadge extends StatelessWidget {
  const CartBadge({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Badge(
      label: Text(count.toString()),
      child: const Icon(Icons.shopping_cart),
    );
  }
}
