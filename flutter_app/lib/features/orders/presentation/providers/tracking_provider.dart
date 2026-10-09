import 'package:flutter/foundation.dart';

import '../../data/models/tracking_model.dart';
import '../../data/repositories/order_repository_impl.dart';

class TrackingProvider extends ChangeNotifier {
  TrackingProvider({OrderRepository? repository})
    : _repository = repository ?? OrderRepositoryImpl();

  final OrderRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;
  TrackingModel? _tracking;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  TrackingModel? get tracking => _tracking;

  Future<void> fetchTracking(String orderId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _tracking = await _repository.fetchTracking(orderId);
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
