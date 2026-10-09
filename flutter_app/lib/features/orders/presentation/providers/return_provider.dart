import 'package:flutter/foundation.dart';

import '../../data/models/return_model.dart';
import '../../data/repositories/order_repository_impl.dart';

class ReturnProvider extends ChangeNotifier {
  ReturnProvider({OrderRepository? repository})
    : _repository = repository ?? OrderRepositoryImpl();

  final OrderRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;
  ReturnModel? _returnRequest;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ReturnModel? get returnRequest => _returnRequest;

  Future<void> submitReturn(String orderId, String reason) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _returnRequest = await _repository.submitReturn(orderId, reason);
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
