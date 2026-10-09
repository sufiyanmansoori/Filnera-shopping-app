import 'package:flutter/foundation.dart';

/// Basic analytics provider for global event emission.
class AnalyticsProvider extends ChangeNotifier {
  final List<String> _events = <String>[];

  List<String> get events => List<String>.unmodifiable(_events);

  void track(String eventName, {Map<String, Object?>? payload}) {
    final safePayload = payload == null
        ? ''
        : ' ${payload.entries.map((entry) => '${entry.key}=${entry.value}').join(',')}';
    _events.add('$eventName$safePayload');
    notifyListeners();
  }

  void clear() {
    _events.clear();
    notifyListeners();
  }
}
