import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../../data/models/cart_item_model.dart';
import '../../data/models/cart_model.dart';
import '../../data/models/coupon_model.dart';
import '../../data/repositories/cart_repository_impl.dart';

class CartProvider extends ChangeNotifier {
  CartProvider({CartRepository? repository})
    : _repository = repository ?? CartRepositoryImpl();

  final CartRepository _repository;

  bool _isLoading = false;
  String? _error;
  CartModel _cart = CartModel.empty();
  List<CouponModel> _availableCoupons = const <CouponModel>[];
  int _cartRevision = 0;

  bool get isLoading => _isLoading;
  String? get error => _error;
  CartModel get cart => _cart;
  List<CouponModel> get availableCoupons => _availableCoupons;

  double get subtotal => _cart.subtotal;
  double get deliveryFee => _cart.deliveryFee;
  double get discount => _cart.discount;
  double get total => _cart.total;

  Future<void> fetchCart(String userId) async {
    final revision = _cartRevision;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final fetchedCart = await _repository.fetchCart(userId);
      if (revision == _cartRevision) _cart = fetchedCart;
      _availableCoupons = await _repository.fetchCoupons();
    } catch (e) {
      _error = e.toString();
      _cart = CartModel.empty();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addItem(CartItemModel item) async {
    final currentItems = List<CartItemModel>.from(_cart.items);
    final index = currentItems.indexWhere(
      (entry) =>
          entry.productId == item.productId && entry.variant == item.variant,
    );

    if (index >= 0) {
      final existing = currentItems[index];
      currentItems[index] = existing.copyWith(
        quantity: existing.quantity + item.quantity,
      );
    } else {
      currentItems.add(item);
    }

    _cart = _cart.copyWith(items: currentItems);
    notifyListeners();

    await updateCart(_cart);
  }

  Future<void> updateQuantity(String productId, {required int quantity}) async {
    if (quantity <= 0) {
      await removeItem(productId);
      return;
    }

    final currentItems = List<CartItemModel>.from(_cart.items);
    final index = currentItems.indexWhere(
      (item) => item.productId == productId,
    );
    if (index == -1) return;

    currentItems[index] = currentItems[index].copyWith(quantity: quantity);
    _cart = _cart.copyWith(items: currentItems);
    notifyListeners();

    await updateCart(_cart);
  }

  Future<void> removeItem(String productId) async {
    final currentItems = _cart.items
        .where((item) => item.productId != productId)
        .toList();
    _cart = _cart.copyWith(items: currentItems);
    notifyListeners();

    await updateCart(_cart);
  }

  Future<void> clearCart() async {
    _cart = CartModel.empty();
    _error = null;
    notifyListeners();
    await updateCart(_cart);
  }

  Future<void> applyCoupon(String code) async {
    final normalized = code.trim().toUpperCase();
    if (normalized.isEmpty) {
      _error = 'Enter a coupon code';
      notifyListeners();
      return;
    }

    final match = _availableCoupons.firstWhere(
      (coupon) => coupon.code == normalized,
      orElse: () => CouponModel.empty(),
    );

    if (match.code.isEmpty) {
      _error = 'Invalid or expired coupon';
      notifyListeners();
      return;
    }

    final newDiscount = match.type == 'percent'
        ? math.min(
            _cart.subtotal * (match.discount / 100),
            _cart.subtotal * 0.5,
          )
        : match.discount.toDouble();

    _cart = _cart.copyWith(couponCode: normalized, discount: newDiscount);
    _error = null;
    notifyListeners();

    await updateCart(_cart);
  }

  Future<void> removeCoupon() async {
    _cart = _cart.copyWith(couponCode: '', discount: 0);
    notifyListeners();
    await updateCart(_cart);
  }

  Future<void> updateCart(CartModel cart) async {
    final revision = ++_cartRevision;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedCart = await _repository.updateCart(cart);
      if (revision == _cartRevision) _cart = updatedCart;
    } catch (e) {
      if (revision == _cartRevision) _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
