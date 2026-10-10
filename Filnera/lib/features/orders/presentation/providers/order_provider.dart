import 'package:flutter/foundation.dart';

import '../../data/models/order_model.dart';
import '../../data/models/tracking_model.dart';
import '../../data/models/return_model.dart';
import '../../data/repositories/order_repository_impl.dart';

class OrderProvider extends ChangeNotifier {
  OrderProvider({required this._repository});

  final OrderRepository _repository;

  bool _isLoading = false;
  String? _error;
  List<OrderModel> _orders = const <OrderModel>[];
  OrderModel? _selectedOrder;
  TrackingModel? _tracking;
  ReturnModel? _returnModel;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<OrderModel> get orders => _orders;
  OrderModel? get selectedOrder => _selectedOrder;
  TrackingModel? get tracking => _tracking;
  ReturnModel? get returnModel => _returnModel;

  Future<void> fetchOrders({String status = 'all'}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _orders = await _repository.fetchOrders(status: status);
    } catch (e) {
      _error = e.toString();
      _orders = const <OrderModel>[];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchOrderById(String orderId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedOrder = await _repository.fetchOrderById(orderId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchTracking(String orderId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _tracking = await _repository.fetchTracking(orderId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> submitReturn(String orderId, String reason) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _returnModel = await _repository.submitReturn(orderId, reason);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
