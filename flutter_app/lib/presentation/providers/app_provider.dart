import 'package:flutter/material.dart';

/// Global application state provider for theme and language settings.
class AppProvider extends ChangeNotifier {
  AppProvider({this._themeMode = ThemeMode.system, this._languageCode = 'en'})
    : _isInitialized = false;

  ThemeMode _themeMode;
  String _languageCode;
  bool _isInitialized;

  ThemeMode get themeMode => _themeMode;
  String get languageCode => _languageCode;
  bool get isInitialized => _isInitialized;

  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
  }

  void setLanguageCode(String code) {
    final normalized = code.trim().toLowerCase();
    if (normalized.isEmpty || _languageCode == normalized) return;
    _languageCode = normalized;
    notifyListeners();
  }

  void markInitialized() {
    if (_isInitialized) return;
    _isInitialized = true;
    notifyListeners();
  }

  void reset() {
    _themeMode = ThemeMode.system;
    _languageCode = 'en';
    _isInitialized = false;
    notifyListeners();
  }
}
