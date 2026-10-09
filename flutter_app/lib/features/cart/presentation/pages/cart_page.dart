import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../data/mock/mock_products.dart';
import '../../../address/data/address_store.dart';
import '../../../shop/shop_store.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool _minutes = false;

  @override
  void initState() {
    super.initState();
    AddressStore.load();
  }

  @override
  Widget build(BuildContext context) =>
      ValueListenableBuilder<Map<String, int>>(
        valueListenable: ShopStore.cart,
        builder: (context, quantities, _) {
          final items = mockProducts
              .where((product) => quantities.containsKey(product.id))
              .toList();
          final mrp = items.fold<double>(
            0,
            (sum, product) =>
                sum + product.originalPrice * quantities[product.id]!,
          );
          final itemTotal = items.fold<double>(
            0,
            (sum, product) => sum + product.price * quantities[product.id]!,
          );
          const platformFee = 10.0;
          final discount = mrp - itemTotal;
          final total = itemTotal + platformFee;
          return Scaffold(
            appBar: AppBar(
              title: Row(
                children: [
                  _tab(
                    'Flipkart (${quantities.length})',
                    !_minutes,
                    () => setState(() => _minutes = false),
                  ),
                  _tab(
                    'Minutes',
                    _minutes,
                    () => setState(() => _minutes = true),
                  ),
                ],
              ),
            ),
            body: items.isEmpty
                ? const Center(child: Text('Your cart is empty'))
                : Column(
                    children: [
                      _addressSelector(),
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                          children: [
                            ...items.map(
                              (product) =>
                                  _cartItem(product, quantities[product.id]!),
                            ),
                            _savingsCard(discount),
                            _priceDetails(mrp, discount, total),
                          ],
                        ),
                      ),
                    ],
                  ),
            bottomNavigationBar: items.isEmpty
                ? null
                : _checkoutBar(total, context),
          );
        },
      );

  Widget _tab(String title, bool active, VoidCallback onTap) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Text(
        title,
        style: TextStyle(
          color: active ? AppColors.primary : Colors.grey,
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
  );

  Widget _addressSelector() => ValueListenableBuilder<DeliveryAddress?>(
    valueListenable: AddressStore.selected,
    builder: (context, address, _) => ListTile(
      dense: true,
      leading: const Icon(Icons.location_on_outlined, color: AppColors.primary),
      title: Text(
        address?.formatted ?? 'Add delivery address',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.push('/addresses'),
    ),
  );

  Widget _cartItem(dynamic product, int count) {
    final outOfStock = product.stock <= 0;
    return Card(
      color: outOfStock ? const Color(0xFFFFF8E1) : Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  product.imageUrl,
                  width: 82,
                  height: 82,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) =>
                      const Icon(Icons.image_not_supported, size: 60),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        product.category,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 2,
                            ),
                            color: Colors.green,
                            child: Text(
                              '${product.rating} ★',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '${product.reviewCount} reviews',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            '✓ Assured',
                            style: TextStyle(color: Colors.blue, fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        AppFormatters.currency(product.price),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            AppFormatters.currency(product.originalPrice),
                            style: const TextStyle(
                              color: Colors.grey,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${_discount(product)}% off',
                            style: const TextStyle(color: Colors.green),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (outOfStock)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Currently out of stock',
                  style: TextStyle(
                    color: Colors.deepOrange,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            Row(
              children: [
                if (!outOfStock) ...[
                  IconButton(
                    onPressed: () => ShopStore.removeFromCart(product.id),
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Text(
                    '$count',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  IconButton(
                    onPressed: () => ShopStore.addToCart(product.id),
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
                TextButton(
                  onPressed: () => ShopStore.toggleWishlist(product.id),
                  child: const Text('Move to Wishlist'),
                ),
                TextButton(
                  onPressed: () => _message('Similar products opened'),
                  child: Text(outOfStock ? 'Similar Products' : 'Buy Now'),
                ),
                if (!outOfStock)
                  IconButton(
                    tooltip: 'Remove',
                    onPressed: () => _remove(product.id),
                    icon: const Icon(Icons.delete_outline),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _savingsCard(double discount) => Card(
    color: const Color(0xFFE8F5E9),
    child: ListTile(
      leading: const Icon(Icons.local_offer, color: Colors.green),
      title: const Text(
        'WOW! Savings Zone',
        style: TextStyle(fontWeight: FontWeight.w800),
      ),
      subtitle: Text(
        "You'll save ${AppFormatters.currency(discount)} on this order",
      ),
    ),
  );

  Widget _priceDetails(double mrp, double discount, double total) => Card(
    child: ExpansionTile(
      initiallyExpanded: true,
      title: const Text(
        'Price Details',
        style: TextStyle(fontWeight: FontWeight.w800),
      ),
      children: [
        _row('MRP', AppFormatters.currency(mrp)),
        _row(
          'Discounts',
          '-${AppFormatters.currency(discount)}',
          color: Colors.green,
        ),
        _row('Platform fee', AppFormatters.currency(10)),
        _row('Total Amount', AppFormatters.currency(total), bold: true),
        const SizedBox(height: 8),
      ],
    ),
  );

  Widget _row(String label, String value, {Color? color, bool bold = false}) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: bold ? FontWeight.w800 : null,
              ),
            ),
          ],
        ),
      );

  Widget _checkoutBar(double total, BuildContext context) => BottomAppBar(
    child: Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              AppFormatters.currency(total),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
          ),
          ElevatedButton(
            onPressed: () => context.push('/checkout'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF9F00),
              foregroundColor: Colors.white,
            ),
            child: const Text('Proceed to buy'),
          ),
        ],
      ),
    ),
  );

  int _discount(dynamic product) =>
      ((1 - product.price / product.originalPrice) * 100).round();

  void _remove(String id) {
    final next = {...ShopStore.cart.value}..remove(id);
    ShopStore.cart.value = next;
  }

  void _message(String message) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
}
