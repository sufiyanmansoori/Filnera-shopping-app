import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashProvider extends ChangeNotifier {
  SplashProvider() {
    initialize();
  }

  bool _isLoading = true;
  bool _hasSeenOnboarding = false;
  bool _isLoggedIn = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  bool get hasSeenOnboarding => _hasSeenOnboarding;
  bool get isLoggedIn => _isLoggedIn;
  String? get errorMessage => _errorMessage;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      _hasSeenOnboarding = prefs.getBool('seen_onboarding') ?? false;
      _isLoggedIn = prefs.getBool('is_logged_in') ?? false;
      _errorMessage = null;
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seen_onboarding', true);
    _hasSeenOnboarding = true;
    notifyListeners();
  }

  Future<void> markLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', value);
    _isLoggedIn = value;
    notifyListeners();
  }
}
