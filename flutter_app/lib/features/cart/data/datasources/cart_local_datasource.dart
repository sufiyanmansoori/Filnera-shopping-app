import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/cart_model.dart';

class CartLocalDataSource {
  static const String _cartKey = 'manara_cart_v1';

  Future<CartModel?> getCart() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cartKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return CartModel.fromJson(Map<String, dynamic>.from(decoded));
      }
    } on FormatException {
      return null;
    }
    return null;
  }

  Future<void> saveCart(CartModel cart) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cartKey, jsonEncode(cart.toJson()));
  }

  Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cartKey);
  }
}
