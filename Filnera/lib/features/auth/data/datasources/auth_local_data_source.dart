import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/services/session_service.dart';
import '../models/auth_response_model.dart';

class AuthLocalDataSource {
  const AuthLocalDataSource();

  static const String _sessionKey = 'auth_session';

  Future<void> saveSession(AuthResponseModel session) async {
    final prefs = await SharedPreferences.getInstance();
    final safeSession = session.copyWith(accessToken: '', refreshToken: '');
    await prefs.setString(_sessionKey, jsonEncode(safeSession.toJson()));
    try {
      await SessionService.saveTokens(
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
      );
    } catch (_) {
      await prefs.remove(_sessionKey);
      await SessionService.clear();
      rethrow;
    }
  }

  Future<AuthResponseModel?> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_sessionKey);
    if (raw == null || raw.isEmpty) {
      await SessionService.clear();
      return null;
    }

    try {
      final value = jsonDecode(raw);
      if (value is! Map<String, dynamic>) {
        throw const FormatException('The saved session is malformed.');
      }
      final decoded = value;
      final token = await SessionService.readAccessToken();
      if (token == null) {
        await clearSession();
        return null;
      }
      decoded['accessToken'] = token;
      final session = AuthResponseModel.fromJson(decoded);
      if (session.isExpired) {
        await clearSession();
        return null;
      }
      return session.copyWith(accessToken: token, refreshToken: '');
    } on FormatException {
      await clearSession();
      return null;
    }
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    await SessionService.clear();
  }
}
