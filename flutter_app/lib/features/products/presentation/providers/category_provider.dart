import 'package:flutter/foundation.dart';

import '../../data/models/category_model.dart';
import '../../data/repositories/product_repository_impl.dart';

class CategoryProvider extends ChangeNotifier {
  CategoryProvider({required this._repository});

  final ProductRepository _repository;

  bool _isLoading = false;
  List<CategoryModel> _categories = const <CategoryModel>[];
  String? _error;

  bool get isLoading => _isLoading;
  List<CategoryModel> get categories => _categories;
  String? get error => _error;

  Future<void> fetchCategories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _categories = await _repository.fetchCategories();
    } catch (e) {
      _error = e.toString();
      _categories = const <CategoryModel>[];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
