import 'package:flutter/material.dart';

import '../../data/models/product_model.dart';
import '../widgets/product_card_widget.dart';

class SimilarProductsScreen extends StatelessWidget {
  const SimilarProductsScreen({super.key, required this.products});

  final List<ProductModel> products;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Similar Products')),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.78,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return ProductCardWidget(product: product);
        },
      ),
    );
  }
}
