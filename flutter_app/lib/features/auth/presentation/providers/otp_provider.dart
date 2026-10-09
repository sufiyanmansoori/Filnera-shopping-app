import 'package:flutter/foundation.dart';

class OtpProvider extends ChangeNotifier {
  String otp = '';
  bool isResending = false;

  void updateOtp(String value) {
    otp = value;
    notifyListeners();
  }

  void setResending(bool value) {
    isResending = value;
    notifyListeners();
  }
}
