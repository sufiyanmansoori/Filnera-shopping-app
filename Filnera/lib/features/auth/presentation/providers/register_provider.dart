import 'package:flutter/foundation.dart';

class RegisterProvider extends ChangeNotifier {
  String fullName = '';
  String email = '';
  String phone = '';
  String password = '';
  bool obscurePassword = true;
  bool acceptedTerms = true;

  void setFullName(String value) {
    fullName = value;
    notifyListeners();
  }

  void setEmail(String value) {
    email = value;
    notifyListeners();
  }

  void setPhone(String value) {
    phone = value;
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

  void toggleTerms() {
    acceptedTerms = !acceptedTerms;
    notifyListeners();
  }
}
