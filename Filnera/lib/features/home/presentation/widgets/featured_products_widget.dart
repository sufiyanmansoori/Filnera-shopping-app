import 'package:flutter/material.dart';

import '../../domain/entities/home_entity.dart';

class FeaturedProductsWidget extends StatelessWidget {
  const FeaturedProductsWidget({super.key, required this.products});

  final List<HomeProductEntity> products;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.78,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Center(child: Icon(Icons.shopping_bag_outlined)),
                ),
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text('\$${product.price.toStringAsFixed(2)}'),
              ],
            ),
          ),
        );
      },
    );
  }
}
