import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../cart/data/models/cart_item_model.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../shop/shop_store.dart';
import '../providers/product_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final String productId;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ProductProvider>();
      provider.fetchProductById(widget.productId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(title: const Text('Product details')),
      body: Consumer<ProductProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.selectedProduct == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final product = provider.selectedProduct;
          if (product == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(provider.error ?? 'Product not found'),
              ),
            );
          }

          final imageList = product.images.isNotEmpty
              ? product.images
              : <String>[product.imageUrl];

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: SizedBox(
                    height: 320,
                    child: PageView.builder(
                      itemCount: imageList.length,
                      itemBuilder: (context, index) => ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          imageList[index],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) =>
                              const Center(
                                child: Icon(Icons.image_not_supported_outlined),
                              ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  product.name,
                  style: Theme.of(context).textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Colors.amber,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text('${product.rating} (${product.reviewCount} reviews)'),
                    const SizedBox(width: 10),
                    if (product.stock > 0)
                      const Chip(
                        label: Text('In stock'),
                        visualDensity: VisualDensity.compact,
                      )
                    else
                      const Chip(
                        label: Text('Out of stock'),
                        visualDensity: VisualDensity.compact,
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${product.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1F5EFF),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (product.compareAtPrice > 0)
                      Text(
                        '₹${product.compareAtPrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    const SizedBox(width: 8),
                    if (product.hasDiscount)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E8),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '${product.discountPercent.toStringAsFixed(0)}% off',
                          style: const TextStyle(
                            color: Color(0xFFB55F00),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                _infoCard(
                  title: 'Highlights',
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: product.tags.isEmpty
                        ? const [
                            Chip(label: Text('Top seller')),
                            Chip(label: Text('Fast delivery')),
                          ]
                        : product.tags
                              .take(6)
                              .map((tag) => Chip(label: Text(tag)))
                              .toList(),
                  ),
                ),
                const SizedBox(height: 16),
                _infoCard(
                  title: 'About this item',
                  child: Text(
                    product.description,
                    style: const TextStyle(height: 1.6, color: Colors.black87),
                  ),
                ),
                const SizedBox(height: 16),
                _infoCard(
                  title: 'Specifications',
                  child: Column(
                    children: product.specifications.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                entry.key,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 3,
                              child: Text(entry.value.toString()),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                _infoCard(
                  title: 'Offers',
                  child: product.offers.isEmpty
                      ? const Text('No offers available right now.')
                      : Column(
                          children: product.offers
                              .map(
                                (offer) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.local_offer_rounded,
                                        size: 18,
                                        color: Color(0xFF1F5EFF),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(child: Text(offer)),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: product.stock > 0
                            ? () {
                                context.read<CartProvider>().addItem(
                                  CartItemModel(
                                    id: product.id,
                                    productId: product.id,
                                    productName: product.name,
                                    productImage: product.imageUrl,
                                    price: product.price,
                                    quantity: 1,
                                    variant: 'Default',
                                    seller: product.sellerName,
                                  ),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Added to cart'),
                                  ),
                                );
                              }
                            : null,
                        icon: const Icon(Icons.shopping_bag_rounded),
                        label: const Text('Add to cart'),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                          backgroundColor: const Color(0xFF1F5EFF),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ValueListenableBuilder<Set<String>>(
                        valueListenable: ShopStore.wishlist,
                        builder: (context, savedItems, _) {
                          final isSaved = savedItems.contains(product.id);
                          return OutlinedButton.icon(
                            onPressed: () =>
                                ShopStore.toggleWishlist(product.id),
                            icon: Icon(
                              isSaved
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                            ),
                            label: Text(isSaved ? 'Saved' : 'Wishlist'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(52),
                              side: const BorderSide(color: Color(0xFF1F5EFF)),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (provider.similarProducts.isNotEmpty) ...[
                  const Text(
                    'Similar products',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 220,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: provider.similarProducts.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final item = provider.similarProducts[index];
                        return InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  ProductDetailScreen(productId: item.id),
                            ),
                          ),
                          child: Container(
                            width: 170,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      item.imageUrl,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  item.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '₹${item.price.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    color: Color(0xFF1F5EFF),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
