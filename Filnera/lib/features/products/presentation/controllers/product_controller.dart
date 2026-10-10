import 'package:flutter/foundation.dart';

import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository_impl.dart';

class ProductController extends ChangeNotifier {
  ProductController({required this._repository});

  final ProductRepository _repository;

  bool _isLoading = false;
  bool _isLoadingDetails = false;
  String? _error;
  List<ProductModel> _products = const <ProductModel>[];
  ProductModel? _selectedProduct;

  bool get isLoading => _isLoading;
  bool get isLoadingDetails => _isLoadingDetails;
  String? get error => _error;
  List<ProductModel> get products => _products;
  ProductModel? get selectedProduct => _selectedProduct;

  Future<void> fetchProducts({
    String category = 'all',
    int page = 1,
    int pageSize = 20,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _products = await _repository.fetchProducts(
        category: category,
        page: page,
        pageSize: pageSize,
      );
    } catch (e) {
      _error = e.toString();
      _products = const <ProductModel>[];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchProductById(String id) async {
    _isLoadingDetails = true;
    _error = null;
    notifyListeners();

    try {
      _selectedProduct = await _repository.fetchProductById(id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingDetails = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
