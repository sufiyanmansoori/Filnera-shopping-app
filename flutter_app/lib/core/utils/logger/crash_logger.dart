import 'package:flutter/foundation.dart';

class CrashLogger {
  static void report(Object error, StackTrace stack) {
    debugPrint('Crash: $error\n$stack');
  }
}
