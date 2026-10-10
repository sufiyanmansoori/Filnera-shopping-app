import 'package:flutter/foundation.dart';

import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository_impl.dart';

class SimilarProductsProvider extends ChangeNotifier {
  SimilarProductsProvider({ProductRepository? repository})
    : _repository = repository ?? ProductRepositoryImpl();

  final ProductRepository _repository;

  List<ProductModel> _items = const <ProductModel>[];
  bool _isLoading = false;
  String? _errorMessage;

  List<ProductModel> get items => _items;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadSimilarProducts(String productId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _items = await _repository.fetchSimilarProducts(productId);
    } catch (error) {
      _errorMessage = error.toString();
      _items = const <ProductModel>[];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
