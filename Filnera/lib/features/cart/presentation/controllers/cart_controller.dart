import 'package:flutter/foundation.dart';

import '../../data/models/cart_model.dart';
import '../../data/repositories/cart_repository_impl.dart';

class CartController extends ChangeNotifier {
  CartController({required this._repository});

  final CartRepository _repository;

  bool _isLoading = false;
  String? _error;
  CartModel _cart = CartModel.empty();

  bool get isLoading => _isLoading;
  String? get error => _error;
  CartModel get cart => _cart;

  Future<void> fetchCart(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _cart = await _repository.fetchCart(userId);
    } catch (e) {
      _error = e.toString();
      _cart = CartModel.empty();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateCart(CartModel cart) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _cart = await _repository.updateCart(cart);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
