import 'package:flutter/foundation.dart';

import '../../domain/entities/home_entity.dart';

class HomeStateProvider extends ChangeNotifier {
  HomeStateProvider();

  bool _isLoading = false;
  String? _error;
  HomePageEntity? _homePage;

  bool get isLoading => _isLoading;
  String? get error => _error;
  HomePageEntity? get homePage => _homePage;

  void startLoading() {
    _isLoading = true;
    _error = null;
    notifyListeners();
  }

  void finishLoading(HomePageEntity page) {
    _homePage = page;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  void failLoading(Object error) {
    _isLoading = false;
    _error = error.toString();
    notifyListeners();
  }
}
