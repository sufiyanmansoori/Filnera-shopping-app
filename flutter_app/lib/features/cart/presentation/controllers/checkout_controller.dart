import 'package:flutter/foundation.dart';

import '../../data/models/cart_model.dart';

class CheckoutController extends ChangeNotifier {
  CheckoutController();

  bool _isLoading = false;
  String? _error;
  CartModel _cart = CartModel.empty();

  bool get isLoading => _isLoading;
  String? get error => _error;
  CartModel get cart => _cart;

  void setCart(CartModel cart) {
    _cart = cart;
    notifyListeners();
  }

  Future<void> placeOrder({required CartModel cart}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _cart = cart;
      await Future<void>.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
