import '../../../../core/network/api_client.dart';
import '../../domain/entities/featured_product_entity.dart';
import '../models/featured_product_model.dart';

/// Fetches the featured product rail from the marketplace home endpoint.
class FeaturedProductsDataSource {
  FeaturedProductsDataSource({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<FeaturedProductEntity>> fetchFeaturedProducts({
    int page = 1,
    int pageSize = 12,
    bool forceRefresh = false,
    String? locale,
    String? currency,
    String? country,
    String? deviceType,
    String? categoryId,
  }) async {
    final safePage = page < 1 ? 1 : page;
    final safePageSize = pageSize.clamp(1, 50);

    try {
      final response = await _apiClient.get(
        '/home',
        queryParameters: {
          'page': safePage,
          'page_size': safePageSize,
          'locale': locale ?? 'en_IN',
          'currency': currency ?? 'INR',
          'country': country ?? 'IN',
          'device_type': deviceType ?? 'web',
          'force_refresh': forceRefresh,
          if (categoryId != null && categoryId.trim().isNotEmpty)
            'category_id': categoryId.trim(),
        },
      );

      final products = _extractFeaturedProducts(response.data)
          .map(
            (item) =>
                item is Map ? _toEntity(Map<String, dynamic>.from(item)) : null,
          )
          .whereType<FeaturedProductEntity>()
          .where(_isAvailable)
          .toList();
      if (products.isNotEmpty) {
        return _paginate(
          _filterByCategory(products, categoryId),
          safePage,
          safePageSize,
        );
      }
    } catch (_) {
      // The storefront can still render useful product cards offline.
    }

    final fallback = _filterByCategory(_fallbackProducts(), categoryId);
    return _paginate(fallback, safePage, safePageSize);
  }

  Future<List<FeaturedProductEntity>> fetchByCategory({
    required String categoryId,
    int page = 1,
    int pageSize = 12,
    bool forceRefresh = false,
    String? locale,
    String? currency,
  }) {
    if (categoryId.trim().isEmpty) {
      throw const FormatException('Category id cannot be empty');
    }
    return fetchFeaturedProducts(
      page: page,
      pageSize: pageSize,
      forceRefresh: forceRefresh,
      locale: locale,
      currency: currency,
      categoryId: categoryId,
    );
  }

  Future<FeaturedProductEntity?> fetchProductById(String productId) async {
    final id = productId.trim();
    if (id.isEmpty) {
      throw const FormatException('Product id cannot be empty');
    }

    try {
      final response = await _apiClient.get('/products/$id');
      final payload = _unwrap(response.data);
      if (payload is Map) {
        final product = _toEntity(Map<String, dynamic>.from(payload));
        if (product != null) return product;
      }
    } catch (_) {
      // Search the home payload before returning no product.
    }

    final products = await fetchFeaturedProducts(pageSize: 50);
    for (final product in products) {
      if (product.id == id) return product;
    }
    return null;
  }

  List<dynamic> _extractFeaturedProducts(dynamic payload) {
    final unwrapped = _unwrap(payload);
    if (unwrapped is! Map) return const <dynamic>[];

    final home = Map<String, dynamic>.from(unwrapped);
    final values =
        home['featured_products'] ??
        home['featuredProducts'] ??
        home['featured'] ??
        home['products'];
    if (values is List) return values;
    if (values is Map) {
      final map = Map<String, dynamic>.from(values);
      final nested = map['items'] ?? map['results'] ?? map['data'];
      if (nested is List) return nested;
    }
    return const <dynamic>[];
  }

  dynamic _unwrap(dynamic payload) {
    var value = payload;
    for (var depth = 0; depth < 3; depth++) {
      if (value is! Map) return value;
      final map = Map<String, dynamic>.from(value);
      if (map.containsKey('data')) {
        value = map['data'];
      } else {
        return value;
      }
    }
    return value;
  }

  FeaturedProductEntity? _toEntity(Map<String, dynamic> json) {
    final model = FeaturedProductModel.fromJson(json);
    return model.hasIdentity ? model.toEntity() : null;
  }

  List<FeaturedProductEntity> _filterByCategory(
    List<FeaturedProductEntity> products,
    String? categoryId,
  ) {
    final requestedCategory = categoryId?.trim().toLowerCase();
    if (requestedCategory == null || requestedCategory.isEmpty) return products;
    return products
        .where(
          (product) =>
              product.categoryId?.trim().toLowerCase() == requestedCategory,
        )
        .toList();
  }

  bool _isAvailable(FeaturedProductEntity product) =>
      product.stockStatus != StockStatus.outOfStock;

  List<FeaturedProductEntity> _paginate(
    List<FeaturedProductEntity> products,
    int page,
    int pageSize,
  ) {
    final start = (page - 1) * pageSize;
    if (start >= products.length) return const <FeaturedProductEntity>[];
    final end = (start + pageSize).clamp(0, products.length);
    return products.sublist(start, end);
  }

  List<FeaturedProductEntity> _fallbackProducts() => const [
    FeaturedProductEntity(
      id: 'p-1',
      title: 'AeroFlex Smartwatch',
      slug: 'aeroflex-smartwatch',
      imageUrl: 'https://images.unsplash.com/photo-1546868871-7041f2a55e12?auto=format&fit=crop&w=900&q=80',
      price: 249,
      compareAtPrice: 299,
      rating: 4.8,
      reviewCount: 481,
      badge: 'Bestseller',
      brand: 'AeroFlex',
      seller: 'Official store',
      stockStatus: StockStatus.inStock,
      categoryId: 'Wearables',
    ),
    FeaturedProductEntity(
      id: 'p-2',
      title: 'Nova Wireless Headphones',
      slug: 'nova-wireless-headphones',
      imageUrl: 'https://images.unsplash.com/photo-1546435770-a3e426bf472b?auto=format&fit=crop&w=900&q=80',
      price: 189,
      compareAtPrice: 239,
      rating: 4.7,
      reviewCount: 312,
      badge: 'Top rated',
      brand: 'Nova Audio',
      seller: 'Official store',
      stockStatus: StockStatus.inStock,
      categoryId: 'Audio',
    ),
    FeaturedProductEntity(
      id: 'p-4',
      title: 'TerraCarry Backpack',
      slug: 'terracarry-backpack',
      imageUrl: 'https://images.unsplash.com/photo-1491637639811-60e2756cc1c7?auto=format&fit=crop&w=900&q=80',
      price: 149,
      compareAtPrice: 199,
      rating: 4.9,
      reviewCount: 219,
      badge: 'Great value',
      brand: 'TerraCarry',
      seller: 'Official store',
      stockStatus: StockStatus.inStock,
      categoryId: 'Travel',
    ),
  ];
}
