import 'package:flutter/foundation.dart';

class PasswordResetProvider extends ChangeNotifier {
  String email = '';
  String otp = '';
  String newPassword = '';
  bool obscurePassword = true;

  void setEmail(String value) {
    email = value;
    notifyListeners();
  }

  void setOtp(String value) {
    otp = value;
    notifyListeners();
  }

  void setNewPassword(String value) {
    newPassword = value;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }
}
