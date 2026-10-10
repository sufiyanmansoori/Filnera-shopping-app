import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/mock/mock_products.dart';
import '../../data/models/product_model.dart';

class ShopStore {
  static const _cartKey = 'manara_cart';
  static const _wishlistKey = 'manara_wishlist';
  static final location = ValueNotifier<String>('Select delivery location');
  static final wishlist = ValueNotifier<Set<String>>(<String>{});
  static final cart = ValueNotifier<Map<String, int>>(<String, int>{});

  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    final preferences = await SharedPreferences.getInstance();
    final savedCart = preferences.getString(_cartKey);
    final savedWishlist = preferences.getString(_wishlistKey);
    if (savedCart != null) {
      final decoded = jsonDecode(savedCart);
      if (decoded is Map) {
        cart.value = decoded.map(
          (key, value) => MapEntry(key.toString(), (value as num).toInt()),
        );
      }
    }
    if (savedWishlist != null) {
      final decoded = jsonDecode(savedWishlist);
      if (decoded is List) wishlist.value = decoded.cast<String>().toSet();
    }
    _initialized = true;
  }

  static ProductModel product(String id) => mockProducts.firstWhere(
    (item) => item.id == id,
    orElse: () => mockProducts.first,
  );

  static void toggleWishlist(String id) {
    final next = {...wishlist.value};
    next.contains(id) ? next.remove(id) : next.add(id);
    wishlist.value = next;
    _persistWishlist(next);
  }

  static void addToCart(String id) {
    final next = {...cart.value};
    next[id] = (next[id] ?? 0) + 1;
    cart.value = next;
    _persistCart(next);
  }

  static void removeFromCart(String id) {
    final next = {...cart.value};
    if ((next[id] ?? 0) > 1) {
      next[id] = next[id]! - 1;
    } else {
      next.remove(id);
    }
    cart.value = next;
    _persistCart(next);
  }

  static Future<void> _persistCart(Map<String, int> value) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_cartKey, jsonEncode(value));
  }

  static Future<void> _persistWishlist(Set<String> value) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_wishlistKey, jsonEncode(value.toList()));
  }
}
