import 'package:flutter/material.dart';

import '../../data/admin_product_store.dart';

class AdminCatalogManagerPage extends StatelessWidget {
  const AdminCatalogManagerPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Catalog manager')),
    body: ValueListenableBuilder(
      valueListenable: AdminProductStore.products,
      builder: (context, products, _) => LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 1100
              ? 4
              : constraints.maxWidth >= 700
              ? 3
              : 1;
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: columns == 1 ? 4.2 : 1.7,
            ),
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(product.imageUrl),
                    onBackgroundImageError: (_, _) {},
                  ),
                  title: Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text('${product.category} • ₹${product.price}'),
                  trailing: IconButton(
                    tooltip: 'Remove product',
                    onPressed: () => _confirmRemove(context, product.id),
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                  ),
                ),
              );
            },
          );
        },
      ),
    ),
  );

  Future<void> _confirmRemove(BuildContext context, String productId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove product?'),
        content: const Text(
          'This product will be removed from the current catalog.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('REMOVE'),
          ),
        ],
      ),
    );
    if (confirmed == true) AdminProductStore.removeProduct(productId);
  }
}
