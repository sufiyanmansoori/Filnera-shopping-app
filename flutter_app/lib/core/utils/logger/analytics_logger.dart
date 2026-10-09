import 'package:flutter/foundation.dart';

class AnalyticsLogger {
  static void track(String event) => debugPrint('track:$event');
}
