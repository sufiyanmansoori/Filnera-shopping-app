import 'package:flutter/foundation.dart';

class ProductFilterProvider extends ChangeNotifier {
  ProductFilterProvider();

  String _category = 'all';
  String _sortBy = 'featured';
  double _minPrice = 0;
  double _maxPrice = 50000;
  bool _inStockOnly = false;

  String get category => _category;
  String get sortBy => _sortBy;
  double get minPrice => _minPrice;
  double get maxPrice => _maxPrice;
  bool get inStockOnly => _inStockOnly;

  void setCategory(String category) {
    _category = category;
    notifyListeners();
  }

  void setSort(String sortBy) {
    _sortBy = sortBy;
    notifyListeners();
  }

  void setPriceRange({required double minPrice, required double maxPrice}) {
    _minPrice = minPrice;
    _maxPrice = maxPrice;
    notifyListeners();
  }

  void setInStockOnly(bool value) {
    _inStockOnly = value;
    notifyListeners();
  }
}
