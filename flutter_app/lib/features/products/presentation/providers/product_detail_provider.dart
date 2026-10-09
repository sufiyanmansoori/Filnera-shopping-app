import 'package:flutter/foundation.dart';

import '../../data/models/product_detail_model.dart';
import '../../data/repositories/product_repository_impl.dart';

class ProductDetailProvider extends ChangeNotifier {
  ProductDetailProvider({ProductRepository? repository})
    : _repository = repository ?? ProductRepositoryImpl();

  final ProductRepository _repository;

  ProductDetailModel? _product;
  bool _isLoading = false;
  String? _errorMessage;

  ProductDetailModel? get product => _product;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadProduct(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _product = await _repository.fetchProductDetails(id);
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
