import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/order_model.dart';

class OrderLocalDataSource {
  static const String _ordersKey = 'orders_cache_v1';

  Future<List<OrderModel>> getCachedOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_ordersKey);
    if (raw == null || raw.isEmpty) {
      return const <OrderModel>[];
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .map(
              (item) => OrderModel.fromJson(
                Map<String, dynamic>.from(item as Map<dynamic, dynamic>),
              ),
            )
            .toList();
      }
    } catch (_) {
      return const <OrderModel>[];
    }

    return const <OrderModel>[];
  }

  Future<void> cacheOrders(List<OrderModel> orders) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = orders.map((order) => order.toJson()).toList();
    await prefs.setString(_ordersKey, jsonEncode(payload));
  }
}
