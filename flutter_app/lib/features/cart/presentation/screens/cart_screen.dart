import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../widgets/cart_summary_widget.dart';
import '../widgets/empty_cart_widget.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: const Text('My Cart'),
        actions: [
          IconButton(
            onPressed: () => context.push('/products'),
            icon: const Icon(Icons.shopping_bag_outlined),
          ),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.cart.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && provider.cart.items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(provider.error!, textAlign: TextAlign.center),
              ),
            );
          }

          if (provider.cart.items.isEmpty) {
            return const EmptyCartWidget();
          }

          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0B4FBE), Color(0xFF5AA5FF)],
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.local_offer_rounded, color: Colors.white),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Save up to 70% with curated cart deals',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Cart items (${provider.cart.items.length})',
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    Text(
                      '₹${provider.subtotal.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: const Color(0xFF1F5EFF),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...provider.cart.items.map(
                  (item) => Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              item.productImage.isNotEmpty
                                  ? item.productImage
                                  : 'https://placehold.co/120x120',
                              width: 92,
                              height: 92,
                              fit: BoxFit.cover,
                              errorBuilder: (context, _, _) => const SizedBox(
                                width: 92,
                                height: 92,
                                child: Center(
                                  child: Icon(
                                    Icons.image_not_supported_rounded,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.productName,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Variant: ${item.variant}',
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Text(
                                      '₹${item.price.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 18,
                                        color: Color(0xFF1F5EFF),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '₹${(item.price * 1.3).toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    InkWell(
                                      onTap: () => provider.updateQuantity(
                                        item.productId,
                                        quantity: item.quantity - 1,
                                      ),
                                      child: const CircleAvatar(
                                        radius: 14,
                                        backgroundColor: Color(0xFFEEF3FF),
                                        child: Icon(
                                          Icons.remove,
                                          color: Color(0xFF1F5EFF),
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      child: Text(
                                        '${item.quantity}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () => provider.updateQuantity(
                                        item.productId,
                                        quantity: item.quantity + 1,
                                      ),
                                      child: const CircleAvatar(
                                        radius: 14,
                                        backgroundColor: Color(0xFFEEF3FF),
                                        child: Icon(
                                          Icons.add,
                                          color: Color(0xFF1F5EFF),
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    TextButton(
                                      onPressed: () =>
                                          provider.removeItem(item.productId),
                                      child: const Text('Remove'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.local_offer_rounded,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: provider.cart.couponCode.isEmpty
                              ? const Text('Apply coupon to unlock savings')
                              : Text(
                                  'Coupon applied: ${provider.cart.couponCode}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                        TextButton(
                          onPressed: () => provider.applyCoupon('WELCOME10'),
                          child: const Text('Apply'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                CartSummaryWidget(cart: provider.cart),
                const SizedBox(height: 20),
                SizedBox(
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: () => context.push('/checkout'),
                    icon: const Icon(Icons.lock_outline_rounded),
                    label: const Text('Proceed to checkout'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9F00),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
