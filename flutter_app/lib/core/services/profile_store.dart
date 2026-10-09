import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

import 'session_service.dart';

class ProfileStore {
  static final currentUser = ValueNotifier<Map<String, String>?>(null);
  static bool _initialized = false;

  static const _nameKey = 'profile_name';
  static const _emailKey = 'profile_email';

  static Future<void> save({
    required String name,
    required String email,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_nameKey, name);
    await preferences.setString(_emailKey, email);
    currentUser.value = {'name': name, 'email': email};
    _initialized = true;
  }

  static Future<void> initialize() async {
    if (_initialized) return;
    final preferences = await SharedPreferences.getInstance();
    final email = preferences.getString(_emailKey);
    final name = preferences.getString(_nameKey);
    if (email != null && name != null) {
      currentUser.value = {'name': name, 'email': email};
    }
    _initialized = true;
  }

  static Future<void> logout() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_nameKey);
    await preferences.remove(_emailKey);
    await SessionService.clear();
    currentUser.value = null;
  }

  static Future<Map<String, String>> read() async {
    final preferences = await SharedPreferences.getInstance();
    return {
      'name': preferences.getString(_nameKey) ?? 'Guest shopper',
      'email':
          preferences.getString(_emailKey) ?? 'Sign in to view your account',
    };
  }
}
