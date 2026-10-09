// lib/core/constants/app_constants.dart

class AppConstants {
  // ⚠️ IMPORTANT: Web ke liye localhost use mat karein
  // Chrome mein localhost kaam nahi karta, 127.0.0.1 use karein

  static const String baseUrl = 'http://127.0.0.1:5000/api';

  // Ya phir environment ke hisaab se:
  static String getBaseUrl() {
    // Web platform check
    return 'http://127.0.0.1:5000/api';
  }

  static const Duration connectionTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
