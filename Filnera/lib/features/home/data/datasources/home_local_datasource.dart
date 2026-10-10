import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class HomeLocalDataSource {
  static const String _cacheKey = 'home_feature_cache_v1';

  Future<void> saveHomePayload(Map<String, dynamic> payload) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey, jsonEncode(payload));
  }

  Future<Map<String, dynamic>?> loadHomePayload() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey);
    if (raw == null || raw.isEmpty) return null;

    final decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
    return null;
  }

  Future<void> clearHomePayload() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
  }
}
