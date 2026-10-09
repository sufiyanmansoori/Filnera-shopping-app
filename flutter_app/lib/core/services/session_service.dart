import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SessionService {
  SessionService._();

  static const _accessTokenKey = 'manara_access_token';
  static const _refreshTokenKey = 'manara_refresh_token';
  static const _storage = FlutterSecureStorage();
  static final isAuthenticated = ValueNotifier<bool>(false);

  static Future<void> bootstrap() async {
    isAuthenticated.value = await readAccessToken() != null;
  }

  static Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
    }
    isAuthenticated.value = true;
  }

  static Future<String?> readAccessToken() async {
    final token = await _storage.read(key: _accessTokenKey);
    if (token == null || token.isEmpty || _isExpired(token)) {
      await clear();
      return null;
    }
    return token;
  }

  static Future<String?> readRefreshToken() =>
      _storage.read(key: _refreshTokenKey);

  static Future<void> clear() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    isAuthenticated.value = false;
  }

  static bool _isExpired(String token) {
    final parts = token.split('.');
    if (parts.length != 3) return false;
    try {
      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );
      final expiry = payload['exp'];
      return expiry is num &&
          DateTime.fromMillisecondsSinceEpoch(expiry.toInt() * 1000)
              .isBefore(DateTime.now());
    } catch (_) {
      return false;
    }
  }
}
