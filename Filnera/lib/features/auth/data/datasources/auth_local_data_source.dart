import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/auth_response_model.dart';

class AuthLocalDataSource {
  const AuthLocalDataSource();

  static const String _sessionKey = 'auth_session';

  Future<void> saveSession(AuthResponseModel session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, jsonEncode(session.toJson()));
  }

  Future<AuthResponseModel?> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_sessionKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final session = AuthResponseModel.fromJson(decoded);
      if (session.isExpired) {
        await clearSession();
        return null;
      }
      return session;
    } catch (_) {
      return null;
    }
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }
}
