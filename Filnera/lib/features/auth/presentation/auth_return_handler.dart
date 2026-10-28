import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../cart/data/models/cart_item_model.dart';
import '../../cart/presentation/providers/cart_provider.dart';
import '../../checkout/data/checkout_intent_store.dart';
import '../../products/presentation/providers/product_provider.dart';

class AuthReturnHandler {
  const AuthReturnHandler._();

  static String safeLocation(String? location) {
    if (location == null || location.isEmpty) return '/';
    final uri = Uri.tryParse(location);
    if (uri == null ||
        uri.hasScheme ||
        uri.hasAuthority ||
        !uri.path.startsWith('/') ||
        uri.path.startsWith('//')) {
      return '/';
    }
    return uri.toString();
  }

  static Future<void> complete(
    BuildContext context, {
    required String? returnTo,
  }) async {
    final location = safeLocation(returnTo);
    final uri = Uri.parse(location);
    final purchase = uri.queryParameters['purchase'];
    if (uri.pathSegments.length == 2 &&
        uri.pathSegments.first == 'product' &&
        (purchase == 'add' || purchase == 'buy')) {
      final productId = uri.pathSegments.last;
      final products = context.read<ProductProvider>();
      await products.fetchProductById(productId);
      if (!context.mounted) return;
      final product = products.selectedProduct;
      if (product == null || product.id != productId) {
        throw StateError(products.error ?? 'Product is no longer available.');
      }

      final item = CartItemModel(
        id: product.id,
        productId: product.id,
        productName: product.name,
        productImage: product.imageUrl,
        price: product.price,
        quantity: 1,
        variant: 'Default',
        seller: product.sellerName,
      );
      if (purchase == 'buy') {
        CheckoutIntentStore.startBuyNow(item);
        context.go('/checkout?buyNow=true');
        return;
      }
      final cart = context.read<CartProvider>();
      await cart.addItem(item);
      if (!context.mounted) return;
      if (cart.error != null) throw StateError(cart.error!);
      context.go('/cart');
      return;
    }
    context.go(location);
  }
}
