import 'package:flutter/foundation.dart';

class PaymentController extends ChangeNotifier {
  PaymentController();

  bool _isLoading = false;
  String? _error;
  String _selectedMethod = 'card';

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedMethod => _selectedMethod;

  void selectMethod(String method) {
    _selectedMethod = method;
    notifyListeners();
  }

  Future<void> pay({required double amount}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future<void>.delayed(const Duration(milliseconds: 350));
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
