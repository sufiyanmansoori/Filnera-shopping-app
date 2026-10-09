import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../data/models/product_model.dart';
import '../../../shop/shop_store.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key, required this.product});

  final ProductModel product;

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  String _color = 'Black';
  String _size = 'Standard';

  ProductModel get product => widget.product;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(product.name),
      actions: [
        IconButton(
          onPressed: () => ShopStore.toggleWishlist(product.id),
          icon: const Icon(Icons.favorite_border),
        ),
        IconButton(
          onPressed: () => context.push('/cart'),
          icon: const Icon(Icons.shopping_cart_outlined),
        ),
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.only(bottom: 90),
      children: [
        SizedBox(
          height: 280,
          child: PageView.builder(
            itemCount: product.gallery.length,
            itemBuilder: (context, index) => Hero(
              tag: '${product.id}-$index',
              child: product.gallery[index].startsWith('http')
                  ? CachedNetworkImage(
                      imageUrl: product.gallery[index],
                      fit: BoxFit.cover,
                      errorWidget: (_, _, _) => const Center(
                        child: Icon(Icons.image_not_supported, size: 48),
                      ),
                    )
                  : Image.file(
                      File(product.gallery[index]),
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Center(
                        child: Icon(Icons.image_not_supported, size: 48),
                      ),
                    ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.category,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                product.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 18),
                  const SizedBox(width: 4),
                  Text('${product.rating} (${product.reviewCount} reviews)'),
                  const SizedBox(width: 8),
                  const Chip(
                    label: Text('Verified Purchase'),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                AppFormatters.currency(product.price),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                AppFormatters.currency(product.originalPrice),
                style: const TextStyle(
                  color: Colors.grey,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              const SizedBox(height: 18),
              _variant(
                'Color',
                ['Black', 'White', 'Blue'],
                _color,
                (value) => setState(() => _color = value),
              ),
              _variant(
                'Size',
                ['Standard', 'Large', 'XL'],
                _size,
                (value) => setState(() => _size = value),
              ),
              const SizedBox(height: 18),
              const Text(
                'Highlights',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              ...product.features.map(
                (feature) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.check_circle,
                    color: AppColors.success,
                    size: 18,
                  ),
                  title: Text(feature),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Delivery estimate',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.local_shipping_outlined),
                title: Text('Deliver to your saved address'),
                subtitle: Text('Expected delivery in 3–5 days'),
              ),
              const Text(
                'Description',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                product.description,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
    bottomNavigationBar: SafeArea(
      minimum: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => ShopStore.addToCart(product.id),
              icon: const Icon(Icons.shopping_bag_outlined),
              label: const Text('Add to Cart'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                ShopStore.addToCart(product.id);
                context.push('/checkout');
              },
              child: const Text('Buy Now'),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _variant(
    String title,
    List<String> values,
    String selected,
    ValueChanged<String> onSelected,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      const SizedBox(height: 6),
      Wrap(
        spacing: 8,
        children: values
            .map(
              (value) => ChoiceChip(
                label: Text(value),
                selected: selected == value,
                onSelected: (_) => onSelected(value),
              ),
            )
            .toList(),
      ),
      const SizedBox(height: 12),
    ],
  );
}
