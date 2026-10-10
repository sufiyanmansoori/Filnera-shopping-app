import 'package:flutter/foundation.dart';

import '../../data/models/search_filter_model.dart';

class FilterProvider extends ChangeNotifier {
  FilterProvider({SearchFilterModel initial = const SearchFilterModel()})
    : _filter = initial;

  SearchFilterModel _filter;

  SearchFilterModel get filter => _filter;

  void updateCategory(String category) {
    _filter = _filter.copyWith(category: category);
    notifyListeners();
  }

  void updatePriceRange(double min, double max) {
    _filter = _filter.copyWith(minPrice: min, maxPrice: max);
    notifyListeners();
  }

  void updateRating(double rating) {
    _filter = _filter.copyWith(rating: rating);
    notifyListeners();
  }

  void updateSort(String sortBy) {
    _filter = _filter.copyWith(sortBy: sortBy);
    notifyListeners();
  }

  void toggleInStockOnly(bool value) {
    _filter = _filter.copyWith(inStockOnly: value);
    notifyListeners();
  }

  void reset() {
    _filter = const SearchFilterModel();
    notifyListeners();
  }
}
