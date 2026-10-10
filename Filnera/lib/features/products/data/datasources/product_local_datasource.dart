import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/product_model.dart';

class ProductLocalDataSource {
  static const String _productKey = 'products_cache_v1';
  static const String _detailsKey = 'product_details_cache_v1';

  Future<List<ProductModel>> getCachedProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_productKey) ?? <String>[];
    return raw
        .map((value) => ProductModel.fromJson(jsonDecode(value)))
        .toList();
  }

  Future<void> cacheProducts(List<ProductModel> products) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = products
        .map((product) => jsonEncode(product.toJson()))
        .toList();
    await prefs.setStringList(_productKey, payload);
  }

  Future<ProductModel?> getCachedProduct(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('${_detailsKey}_$id');
    if (raw == null) return null;
    return ProductModel.fromJson(jsonDecode(raw));
  }

  Future<void> cacheProduct(ProductModel product) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '${_detailsKey}_${product.id}',
      jsonEncode(product.toJson()),
    );
  }
}
