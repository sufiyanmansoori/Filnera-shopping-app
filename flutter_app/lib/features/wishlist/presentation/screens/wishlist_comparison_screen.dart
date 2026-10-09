import 'package:flutter/material.dart';

class WishlistComparisonScreen extends StatelessWidget {
  const WishlistComparisonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Compare Wishlist')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            Card(
              child: ListTile(title: Text('Model A'), subtitle: Text('₹2999')),
            ),
            Card(
              child: ListTile(title: Text('Model B'), subtitle: Text('₹2499')),
            ),
          ],
        ),
      ),
    );
  }
}
