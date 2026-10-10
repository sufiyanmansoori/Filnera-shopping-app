import 'package:flutter/foundation.dart';

/// Lightweight connectivity provider that mirrors online/offline state.
class ConnectivityProvider extends ChangeNotifier {
  ConnectivityProvider({this._online = true});

  bool _online;

  bool get isOnline => _online;

  void setOnline(bool value) {
    if (_online == value) return;
    _online = value;
    notifyListeners();
  }

  void markOnline() => setOnline(true);
  void markOffline() => setOnline(false);
}
