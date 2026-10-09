import 'package:flutter/foundation.dart';

class LoginProvider extends ChangeNotifier {
  String email = '';
  String password = '';
  bool obscurePassword = true;
  bool rememberMe = true;

  void setEmail(String value) {
    email = value;
    notifyListeners();
  }

  void setPassword(String value) {
    password = value;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  void toggleRememberMe() {
    rememberMe = !rememberMe;
    notifyListeners();
  }
}
