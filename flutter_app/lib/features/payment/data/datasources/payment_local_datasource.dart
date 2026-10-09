import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/payment_method_model.dart';

class PaymentLocalDatasource {
  PaymentLocalDatasource({this._sharedPreferences});

  final SharedPreferences? _sharedPreferences;

  static const String _cacheKey = 'payment_methods_cache';

  Future<SharedPreferences> get _prefs async {
    return _sharedPreferences ?? await SharedPreferences.getInstance();
  }

  Future<List<PaymentMethodModel>> getCachedMethods() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_cacheKey);
    if (raw == null || raw.isEmpty) {
      return const <PaymentMethodModel>[];
    }

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map(
          (item) =>
              PaymentMethodModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  Future<void> cacheMethods(List<PaymentMethodModel> methods) async {
    final prefs = await _prefs;
    final payload = jsonEncode(
      methods.map((method) => method.toJson()).toList(),
    );
    await prefs.setString(_cacheKey, payload);
  }
}
