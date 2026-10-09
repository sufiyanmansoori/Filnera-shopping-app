import 'package:flutter/foundation.dart';

import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository_impl.dart';

class ProductListProvider extends ChangeNotifier {
  ProductListProvider({ProductRepository? repository})
    : _repository = repository ?? ProductRepositoryImpl();

  final ProductRepository _repository;

  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;
  List<ProductModel> _products = const <ProductModel>[];
  int _page = 1;
  final int _pageSize = 12;
  String _category = 'all';
  String _searchQuery = '';
  String _sortBy = 'featured';
  bool _hasMore = true;

  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;
  List<ProductModel> get products => _products;
  int get page => _page;
  String get category => _category;
  String get searchQuery => _searchQuery;
  String get sortBy => _sortBy;
  bool get hasMore => _hasMore;

  Future<void> loadProducts({
    bool refresh = false,
    String? category,
    String? search,
    String? sort,
  }) async {
    if (refresh) {
      _page = 1;
      _hasMore = true;
    }

    if (category != null) {
      _category = category;
    }
    if (search != null) {
      _searchQuery = search;
    }
    if (sort != null) {
      _sortBy = sort;
    }

    if (_page == 1) {
      _isLoading = true;
    } else {
      _isLoadingMore = true;
    }

    _errorMessage = null;
    notifyListeners();

    try {
      final items = await _repository.fetchProducts(
        category: _category,
        page: _page,
        pageSize: _pageSize,
      );

      final filteredItems = _applyFilters(items);

      if (_page == 1) {
        _products = filteredItems;
      } else {
        _products = <ProductModel>[..._products, ...filteredItems];
      }

      _hasMore = filteredItems.length >= _pageSize;
      if (_page == 1 && filteredItems.length < _pageSize) {
        _hasMore = false;
      }
    } catch (error) {
      _errorMessage = error.toString();
      if (_page == 1) {
        _products = const <ProductModel>[];
      }
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> loadNextPage() async {
    if (_isLoading || _isLoadingMore || !_hasMore) {
      return;
    }
    _page += 1;
    await loadProducts();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  List<ProductModel> _applyFilters(List<ProductModel> items) {
    final query = _searchQuery.trim().toLowerCase();
    final filtered = items.where((product) {
      final matchesCategory =
          _category == 'all' ||
          product.category.toLowerCase() == _category.toLowerCase();
      final matchesSearch =
          query.isEmpty ||
          product.name.toLowerCase().contains(query) ||
          product.description.toLowerCase().contains(query) ||
          product.brand.toLowerCase().contains(query);
      return matchesCategory && matchesSearch;
    }).toList();

    switch (_sortBy) {
      case 'price_low_high':
        filtered.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_high_low':
        filtered.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'rating':
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      default:
        filtered.sort(
          (a, b) => (b.isFeatured ? 1 : 0).compareTo(a.isFeatured ? 1 : 0),
        );
    }

    return filtered;
  }
}
