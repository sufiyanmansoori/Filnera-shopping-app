import '../../../../core/network/api_client.dart';
import 'home_remote_datasource.dart';

class HomeRemoteDataSourceImpl extends HomeRemoteDataSource {
  HomeRemoteDataSourceImpl({super.apiClient});

  ApiClient get _apiClient => ApiClient();

  @override
  Future<Map<String, dynamic>> getHomePayload() async {
    final queryParameters = <String, dynamic>{
      'platform': 'flutter',
      'app_version': '1.0.0',
      'country': 'IN',
      'currency': 'INR',
      'locale': 'en_IN',
      'device_type': 'mobile',
    };

    try {
      final response = await _apiClient.get(
        '/home',
        queryParameters: queryParameters,
      );
      return _normalizePayload(response.data);
    } catch (_) {
      return _buildFallbackHomePayload();
    }
  }

  @override
  Future<Map<String, dynamic>> getPersonalizedDealsPayload({
    required String customerId,
  }) async {
    final queryParameters = <String, dynamic>{
      'customer_id': customerId,
      'limit': 8,
      'locale': 'en_IN',
      'currency': 'INR',
    };

    try {
      final response = await _apiClient.get(
        '/home/personalized-deals',
        queryParameters: queryParameters,
      );
      final payload = _normalizePayload(response.data);
      if (payload['items'] is List) {
        return payload;
      }
      return {'items': _buildFallbackDeals(customerId)};
    } catch (_) {
      return {'items': _buildFallbackDeals(customerId)};
    }
  }

  Future<Map<String, dynamic>> getProductSpotlightPayload({
    String? customerId,
    String? category,
  }) async {
    try {
      final response = await _apiClient.get(
        '/home/spotlight',
        queryParameters: {
          if (customerId != null && customerId.isNotEmpty)
            'customer_id': customerId,
          if (category != null && category.isNotEmpty) 'category': category,
        },
      );
      return _normalizePayload(response.data);
    } catch (_) {
      return {
        'items': _buildFallbackFeaturedProducts(),
        'title': 'Trending in $category',
      };
    }
  }

  Future<List<Map<String, dynamic>>> fetchTopCategories() async {
    final payload = await getHomePayload();
    final values = payload['categories'] ?? payload['top_categories'];
    return _coerceList(values)
        .whereType<Map<String, dynamic>>()
        .map((item) => _normalizeMap(item))
        .toList();
  }

  Future<List<Map<String, dynamic>>> fetchFlashSales() async {
    final payload = await getHomePayload();
    return _coerceList(payload['flash_sales'] ?? payload['flashSales'])
        .whereType<Map<String, dynamic>>()
        .map((item) => _normalizeMap(item))
        .toList();
  }

  Future<List<Map<String, dynamic>>> fetchTrendingProducts() async {
    final payload = await getHomePayload();
    return _coerceList(
          payload['trending_products'] ?? payload['trendingProducts'],
        )
        .whereType<Map<String, dynamic>>()
        .map((item) => _normalizeMap(item))
        .toList();
  }

  Map<String, dynamic> _normalizePayload(dynamic data) {
    if (data is Map<String, dynamic>) {
      return _normalizeMap(data);
    }
    if (data is Map) {
      return _normalizeMap(Map<String, dynamic>.from(data));
    }
    if (data == null) {
      return _buildFallbackHomePayload();
    }
    throw const FormatException('Invalid home payload');
  }

  Map<String, dynamic> _normalizeMap(Map<String, dynamic> source) {
    final normalized = <String, dynamic>{};
    for (final entry in source.entries) {
      final key = entry.key.toString();
      final value = entry.value;
      if (value is Map) {
        normalized[key] = Map<String, dynamic>.from(value);
      } else if (value is List) {
        normalized[key] = value
            .map((item) => item is Map ? Map<String, dynamic>.from(item) : item)
            .toList();
      } else {
        normalized[key] = value;
      }
    }
    normalized.putIfAbsent('banners', () => _buildFallbackBanners());
    normalized.putIfAbsent('categories', () => _buildFallbackCategories());
    normalized.putIfAbsent('deals', () => _buildFallbackDeals('home'));
    normalized.putIfAbsent(
      'featured_products',
      () => _buildFallbackFeaturedProducts(),
    );
    normalized.putIfAbsent('flash_sales', () => _buildFallbackFlashSales());
    normalized.putIfAbsent(
      'recommendations',
      () => _buildFallbackRecommendations(),
    );
    normalized.putIfAbsent('sections', () => _buildFallbackSections());
    normalized.putIfAbsent(
      'trending_products',
      () => _buildFallbackFeaturedProducts(),
    );
    normalized.putIfAbsent('personalized_summary', () => 'Top picks for you');
    return normalized;
  }

  List<Map<String, dynamic>> _buildFallbackBanners() {
    return [
      {
        'id': 'banner-1',
        'title': 'Big Billion Days',
        'image_url': 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?auto=format&fit=crop&w=1200&q=80',
        'deep_link': '/deals',
        'is_active': true,
      },
      {
        'id': 'banner-2',
        'title': 'Top Smartphone Offers',
        'image_url': 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?auto=format&fit=crop&w=1200&q=80',
        'deep_link': '/products',
        'is_active': true,
      },
      {
        'id': 'banner-3',
        'title': 'Fashion Week Sale',
        'image_url': 'https://images.unsplash.com/photo-1521572267360-ee0c2909d518?auto=format&fit=crop&w=1200&q=80',
        'deep_link': '/search?q=fashion',
        'is_active': true,
      },
    ];
  }

  List<Map<String, dynamic>> _buildFallbackCategories() {
    return [
      {
        'id': 'cat-1',
        'name': 'Mobiles',
        'slug': 'mobiles',
        'image_url': 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?auto=format&fit=crop&w=800&q=80',
        'is_active': true,
        'subcategory_count': 14,
      },
      {
        'id': 'cat-2',
        'name': 'Fashion',
        'slug': 'fashion',
        'image_url': 'https://images.unsplash.com/photo-1521572267360-ee0c2909d518?auto=format&fit=crop&w=800&q=80',
        'is_active': true,
        'subcategory_count': 21,
      },
      {
        'id': 'cat-3',
        'name': 'Home',
        'slug': 'home',
        'image_url': 'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?auto=format&fit=crop&w=800&q=80',
        'is_active': true,
        'subcategory_count': 18,
      },
      {
        'id': 'cat-4',
        'name': 'Electronics',
        'slug': 'electronics',
        'image_url': 'https://images.unsplash.com/photo-1518770660439-4636190af475?auto=format&fit=crop&w=800&q=80',
        'is_active': true,
        'subcategory_count': 26,
      },
      {
        'id': 'cat-5',
        'name': 'Beauty',
        'slug': 'beauty',
        'image_url': 'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?auto=format&fit=crop&w=800&q=80',
        'is_active': true,
        'subcategory_count': 12,
      },
    ];
  }

  List<Map<String, dynamic>> _buildFallbackDeals(String customerId) {
    return [
      {
        'id': 'deal-1',
        'title': 'Premium Earbuds',
        'slug': 'premium-earbuds',
        'product_id': 'P-1001',
        'product_name': 'Noise Buds X',
        'original_price': 3999,
        'current_price': 2199,
        'discount_percent': 45,
        'image_url': 'https://images.unsplash.com/photo-1546435770-a3e426bf472b?auto=format&fit=crop&w=800&q=80',
        'badge': 'Top Deal',
        'description': 'For $customerId personalized offer',
        'is_active': true,
      },
      {
        'id': 'deal-2',
        'title': 'Smart Watch',
        'slug': 'smart-watch',
        'product_id': 'P-1002',
        'product_name': 'Amazfit Active',
        'original_price': 7999,
        'current_price': 4999,
        'discount_percent': 37,
        'image_url': 'https://images.unsplash.com/photo-1546868871-7041f2a55e12?auto=format&fit=crop&w=800&q=80',
        'badge': 'Seller Pick',
        'description': 'Popular choice for fitness lovers',
        'is_active': true,
      },
      {
        'id': 'deal-3',
        'title': 'Men’s Casual Shirt',
        'slug': 'mens-casual-shirt',
        'product_id': 'P-1003',
        'product_name': 'Cotton Crew Shirt',
        'original_price': 2499,
        'current_price': 1299,
        'discount_percent': 48,
        'image_url': 'https://images.unsplash.com/photo-1521572267360-ee0c2909d518?auto=format&fit=crop&w=800&q=80',
        'badge': 'New',
        'description': 'Everyday wear with premium finish',
        'is_active': true,
      },
    ];
  }

  List<Map<String, dynamic>> _buildFallbackFeaturedProducts() {
    return [
      {
        'id': 'prod-1',
        'title': 'iPhone 15 Pro',
        'name': 'iPhone 15 Pro',
        'slug': 'iphone-15-pro',
        'price': 124999,
        'image_url': 'https://images.unsplash.com/photo-1592750475338-74b7b21085ab?auto=format&fit=crop&w=800&q=80',
        'rating': 4.7,
        'category': 'Mobiles',
      },
      {
        'id': 'prod-2',
        'title': 'Nike Air Max',
        'name': 'Nike Air Max',
        'slug': 'nike-air-max',
        'price': 6999,
        'image_url': 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=800&q=80',
        'rating': 4.6,
        'category': 'Fashion',
      },
      {
        'id': 'prod-3',
        'title': '4K Smart TV',
        'name': '4K Smart TV',
        'slug': '4k-smart-tv',
        'price': 32999,
        'image_url': 'https://images.unsplash.com/photo-1593359677879-a4bb92f829d1?auto=format&fit=crop&w=800&q=80',
        'rating': 4.5,
        'category': 'Electronics',
      },
      {
        'id': 'prod-4',
        'title': 'Wooden Study Table',
        'name': 'Wooden Study Table',
        'slug': 'wooden-study-table',
        'price': 18999,
        'image_url': 'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?auto=format&fit=crop&w=800&q=80',
        'rating': 4.4,
        'category': 'Home',
      },
    ];
  }

  List<Map<String, dynamic>> _buildFallbackFlashSales() {
    return [
      {
        'id': 'sale-1',
        'title': 'Weekend Sale',
        'product_id': 'P-2001',
        'product_name': 'Noise Headphones',
        'original_price': 5999,
        'current_price': 3499,
        'discount_percent': 41,
        'end_at': DateTime.now()
            .add(const Duration(hours: 12))
            .toIso8601String(),
        'image_url': 'https://images.unsplash.com/photo-1546435770-a3e426bf472b?auto=format&fit=crop&w=800&q=80',
        'sold_count': 1420,
        'remaining_count': 96,
      },
      {
        'id': 'sale-2',
        'title': 'Fashion Rush',
        'product_id': 'P-2002',
        'product_name': 'Trail Running Sneakers',
        'original_price': 6999,
        'current_price': 3899,
        'discount_percent': 44,
        'end_at': DateTime.now()
            .add(const Duration(hours: 9))
            .toIso8601String(),
        'image_url': 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=800&q=80',
        'sold_count': 980,
        'remaining_count': 132,
      },
    ];
  }

  List<Map<String, dynamic>> _buildFallbackRecommendations() {
    return [
      {
        'id': 'rec-1',
        'title': 'Since you liked smartphones',
        'product_id': 'P-3001',
        'product_name': 'Samsung Galaxy A55',
        'price': 32999,
        'image_url': 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?auto=format&fit=crop&w=800&q=80',
        'rating': 4.8,
      },
      {
        'id': 'rec-2',
        'title': 'Home upgrade picks',
        'product_id': 'P-3002',
        'product_name': 'Air Fryer XL',
        'price': 11999,
        'image_url': 'https://images.unsplash.com/photo-1559056199-641a0ac8b55e?auto=format&fit=crop&w=800&q=80',
        'rating': 4.7,
      },
    ];
  }

  List<Map<String, dynamic>> _buildFallbackSections() {
    return [
      {
        'id': 'section-top-offers',
        'title': 'Top offers',
        'subtitle': 'Curated just for you',
        'items': _buildFallbackFeaturedProducts(),
        'layout': 'grid',
      },
      {
        'id': 'section-fresh-arrivals',
        'title': 'Fresh arrivals',
        'subtitle': 'New this week',
        'items': _buildFallbackDeals('home'),
        'layout': 'carousel',
      },
    ];
  }

  Map<String, dynamic> _buildFallbackHomePayload() {
    return {
      'banners': _buildFallbackBanners(),
      'categories': _buildFallbackCategories(),
      'deals': _buildFallbackDeals('demo'),
      'featured_products': _buildFallbackFeaturedProducts(),
      'flash_sales': _buildFallbackFlashSales(),
      'recommendations': _buildFallbackRecommendations(),
      'trending_products': _buildFallbackFeaturedProducts(),
      'sections': _buildFallbackSections(),
      'personalized_summary': 'Recommended for your lifestyle',
      'last_updated': DateTime.now().toIso8601String(),
    };
  }

  List<Map<String, dynamic>> _coerceList(dynamic value) {
    if (value is List) {
      return value
          .map(
            (item) => item is Map
                ? Map<String, dynamic>.from(item)
                : <String, dynamic>{},
          )
          .toList();
    }
    return const <Map<String, dynamic>>[];
  }
}
