import 'package:flutter/material.dart';

class EmptyWishlistWidget extends StatelessWidget {
  const EmptyWishlistWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 56),
          SizedBox(height: 12),
          Text('Your wishlist is empty'),
        ],
      ),
    );
  }
}
