import 'package:flutter/foundation.dart';

import '../../data/models/category_model.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository_impl.dart';

class ProductProvider extends ChangeNotifier {
  ProductProvider({ProductRepository? repository})
    : _repository = repository ?? ProductRepositoryImpl();

  final ProductRepository _repository;

  bool _isLoading = false;
  String? _error;
  List<ProductModel> _products = const <ProductModel>[];
  List<ProductModel> _similarProducts = const <ProductModel>[];
  List<CategoryModel> _categories = const <CategoryModel>[];
  ProductModel? _selectedProduct;
  String _selectedCategory = 'all';
  String _searchQuery = '';
  String _sortBy = 'featured';
  bool _inStockOnly = false;
  double _minPrice = 0;
  double _maxPrice = 50000;
  bool _hasMore = true;
  int _page = 1;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<ProductModel> get products => _products;
  List<ProductModel> get similarProducts => _similarProducts;
  List<CategoryModel> get categories => _categories;
  ProductModel? get selectedProduct => _selectedProduct;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  String get sortBy => _sortBy;
  bool get inStockOnly => _inStockOnly;
  double get minPrice => _minPrice;
  double get maxPrice => _maxPrice;
  bool get hasMore => _hasMore;

  Future<void> fetchCategories() async {
    try {
      _categories = await _repository.fetchCategories();
      if (_categories.isEmpty) {
        _categories = const <CategoryModel>[];
      }
    } catch (e) {
      _categories = const <CategoryModel>[];
      _error = e.toString();
    }
    notifyListeners();
  }

  Future<void> fetchProducts({
    String category = 'all',
    int page = 1,
    int pageSize = 20,
    bool refresh = false,
    String? query,
  }) async {
    if (refresh) {
      _page = 1;
      _hasMore = true;
    } else {
      _page = page;
    }

    if (category != 'all' || _selectedCategory != 'all') {
      _selectedCategory = category;
    }
    if (query != null) {
      _searchQuery = query.trim();
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final remoteProducts = await _repository.fetchProducts(
        category: _selectedCategory,
        page: _page,
        pageSize: pageSize,
      );
      final filteredProducts = _applyFilters(remoteProducts);

      if (_page == 1 || refresh) {
        _products = filteredProducts;
      } else {
        _products = <ProductModel>[..._products, ...filteredProducts];
      }

      _hasMore = filteredProducts.length >= pageSize;
      if (filteredProducts.length < pageSize && _page == 1) {
        _hasMore = false;
      }
    } catch (e) {
      _error = e.toString();
      if (_page == 1 || refresh) {
        _products = const <ProductModel>[];
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchProductById(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedProduct = await _repository.fetchProductById(id);
      await loadSimilarProducts(id);
    } catch (e) {
      _error = e.toString();
      _selectedProduct = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSimilarProducts(String productId) async {
    try {
      _similarProducts = await _repository.fetchSimilarProducts(productId);
    } catch (_) {
      _similarProducts = const <ProductModel>[];
    }
    notifyListeners();
  }

  void updateFilters({
    String? category,
    String? search,
    String? sortBy,
    bool? inStockOnly,
    double? minPrice,
    double? maxPrice,
  }) {
    if (category != null) {
      _selectedCategory = category;
    }
    if (search != null) {
      _searchQuery = search.trim();
    }
    if (sortBy != null) {
      _sortBy = sortBy;
    }
    if (inStockOnly != null) {
      _inStockOnly = inStockOnly;
    }
    if (minPrice != null) {
      _minPrice = minPrice;
    }
    if (maxPrice != null) {
      _maxPrice = maxPrice;
    }
    notifyListeners();
  }

  void clearFilters() {
    _selectedCategory = 'all';
    _searchQuery = '';
    _sortBy = 'featured';
    _inStockOnly = false;
    _minPrice = 0;
    _maxPrice = 50000;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  List<ProductModel> _applyFilters(List<ProductModel> items) {
    final query = _searchQuery.toLowerCase();
    final filtered = items.where((product) {
      final categoryMatch =
          _selectedCategory == 'all' ||
          product.category.toLowerCase() == _selectedCategory.toLowerCase();
      final matchesQuery =
          query.isEmpty ||
          product.name.toLowerCase().contains(query) ||
          product.description.toLowerCase().contains(query) ||
          product.brand.toLowerCase().contains(query);
      final withinPriceRange =
          product.price >= _minPrice && product.price <= _maxPrice;
      final stockMatch = !_inStockOnly || product.stock > 0;

      return categoryMatch && matchesQuery && withinPriceRange && stockMatch;
    }).toList();

    switch (_sortBy) {
      case 'price_low_high':
        filtered.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_high_low':
        filtered.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'customer_rating':
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
