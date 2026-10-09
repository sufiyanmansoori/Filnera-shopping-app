import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../data/mock/mock_products.dart';
import '../../../shop/shop_store.dart';

class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Wishlist')),
    body: ValueListenableBuilder<Set<String>>(
      valueListenable: ShopStore.wishlist,
      builder: (context, saved, _) {
        final items = mockProducts.where((p) => saved.contains(p.id)).toList();
        if (items.isEmpty) {
          return const Center(child: Text('No favourites yet'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final product = items[index];
            return Card(
              child: ListTile(
                onTap: () => context.push('/product/${product.id}'),
                leading: Image.network(
                  product.imageUrl,
                  width: 52,
                  height: 52,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) =>
                      const Icon(Icons.image_not_supported),
                ),
                title: Text(product.name),
                subtitle: Text(product.category),
                trailing: IconButton(
                  icon: const Icon(Icons.favorite, color: Colors.red),
                  onPressed: () => ShopStore.toggleWishlist(product.id),
                ),
              ),
            );
          },
        );
      },
    ),
  );
}
