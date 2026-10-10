import 'package:flutter/foundation.dart';

/// Auth state provider. This file intentionally stays dependency-light so
/// it can be injected into the app without introducing network code.
class AuthProvider extends ChangeNotifier {
  AuthProvider({this.isAuthenticated = false, this.userId, this.accessToken});

  bool isAuthenticated;
  String? userId;
  String? accessToken;
  String? _lastError;

  bool get hasToken => accessToken != null && accessToken!.trim().isNotEmpty;
  String? get lastError => _lastError;

  void login({required String userId, required String accessToken}) {
    this.userId = userId;
    this.accessToken = accessToken;
    isAuthenticated = true;
    _lastError = null;
    notifyListeners();
  }

  void logout() {
    userId = null;
    accessToken = null;
    isAuthenticated = false;
    _lastError = null;
    notifyListeners();
  }

  void setAuthError(String message) {
    _lastError = message;
    notifyListeners();
  }

  void clearError() {
    _lastError = null;
    notifyListeners();
  }
}
