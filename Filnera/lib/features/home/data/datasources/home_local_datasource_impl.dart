import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'home_local_datasource.dart';

class HomeLocalDataSourceImpl extends HomeLocalDataSource {
  HomeLocalDataSourceImpl({
    this._sharedPreferences,
    this._cacheKey = _defaultCacheKey,
    Duration? maxAge,
  }) : _maxAge = maxAge ?? const Duration(hours: 12);

  final SharedPreferences? _sharedPreferences;
  final String _cacheKey;
  final Duration _maxAge;

  static const String _defaultCacheKey = 'home_feature_cache_v1';
  static const String _metaKey = 'home_feature_cache_meta_v1';
  static const String _categoriesKey = 'home_categories_cache_v1';
  static const String _bannersKey = 'home_banners_cache_v1';
  static const String _dealsKey = 'home_deals_cache_v1';
  static const String _productsKey = 'home_products_cache_v1';

  Future<SharedPreferences> get _prefs async =>
      _sharedPreferences ?? await SharedPreferences.getInstance();

  @override
  Future<void> saveHomePayload(Map<String, dynamic> payload) async {
    final prefs = await _prefs;
    final normalized = _normalizePayload(payload);
    final snapshot = {
      'version': 1,
      'savedAt': DateTime.now().toUtc().toIso8601String(),
      'data': normalized,
    };

    await prefs.setString(_cacheKey, jsonEncode(snapshot));
    await prefs.setString(
      _metaKey,
      jsonEncode({
        'savedAt': snapshot['savedAt'],
        'version': 1,
        'ttlMinutes': _maxAge.inMinutes,
        'page': 'home',
      }),
    );
  }

  @override
  Future<Map<String, dynamic>?> loadHomePayload() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_cacheKey);
    if (raw == null || raw.trim().isEmpty) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;

      final map = Map<String, dynamic>.from(decoded);
      final payload = map['data'];
      if (payload is! Map) return null;
      return _normalizePayload(Map<String, dynamic>.from(payload));
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> clearHomePayload() async {
    final prefs = await _prefs;
    await prefs.remove(_cacheKey);
    await prefs.remove(_metaKey);
    await prefs.remove(_bannersKey);
    await prefs.remove(_categoriesKey);
    await prefs.remove(_dealsKey);
    await prefs.remove(_productsKey);
  }

  Future<bool> hasFreshHomeCache() async {
    final prefs = await _prefs;
    final rawMeta = prefs.getString(_metaKey);
    if (rawMeta == null || rawMeta.isEmpty) return false;

    try {
      final meta = Map<String, dynamic>.from(jsonDecode(rawMeta));
      final savedAt = meta['savedAt']?.toString();
      if (savedAt == null || savedAt.isEmpty) return false;

      final savedDate = DateTime.tryParse(savedAt)?.toUtc();
      if (savedDate == null) return false;

      final staleAt = savedDate.add(_maxAge);
      return DateTime.now().toUtc().isBefore(staleAt);
    } catch (_) {
      return false;
    }
  }

  Future<void> saveBanners(List<Map<String, dynamic>> banners) async {
    final prefs = await _prefs;
    await prefs.setString(_bannersKey, jsonEncode(banners));
  }

  Future<List<Map<String, dynamic>>> loadBanners() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_bannersKey);
    if (raw == null || raw.isEmpty) return const <Map<String, dynamic>>[];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const <Map<String, dynamic>>[];
      return decoded
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    } catch (_) {
      return const <Map<String, dynamic>>[];
    }
  }

  Future<void> saveCategories(List<Map<String, dynamic>> categories) async {
    final prefs = await _prefs;
    await prefs.setString(_categoriesKey, jsonEncode(categories));
  }

  Future<List<Map<String, dynamic>>> loadCategories() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_categoriesKey);
    if (raw == null || raw.isEmpty) return const <Map<String, dynamic>>[];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const <Map<String, dynamic>>[];
      return decoded
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    } catch (_) {
      return const <Map<String, dynamic>>[];
    }
  }

  Future<void> saveDeals(List<Map<String, dynamic>> deals) async {
    final prefs = await _prefs;
    await prefs.setString(_dealsKey, jsonEncode(deals));
  }

  Future<List<Map<String, dynamic>>> loadDeals() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_dealsKey);
    if (raw == null || raw.isEmpty) return const <Map<String, dynamic>>[];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const <Map<String, dynamic>>[];
      return decoded
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    } catch (_) {
      return const <Map<String, dynamic>>[];
    }
  }

  Future<void> saveProducts(List<Map<String, dynamic>> products) async {
    final prefs = await _prefs;
    await prefs.setString(_productsKey, jsonEncode(products));
  }

  Future<List<Map<String, dynamic>>> loadProducts() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_productsKey);
    if (raw == null || raw.isEmpty) return const <Map<String, dynamic>>[];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const <Map<String, dynamic>>[];
      return decoded
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    } catch (_) {
      return const <Map<String, dynamic>>[];
    }
  }

  Future<void> saveHomeSections(List<Map<String, dynamic>> sections) async {
    final payload = await loadHomePayload() ?? <String, dynamic>{};
    final newPayload = Map<String, dynamic>.from(payload);
    newPayload['sections'] = sections;
    await saveHomePayload(newPayload);
  }

  Future<List<Map<String, dynamic>>> loadHomeSections() async {
    final payload = await loadHomePayload();
    if (payload == null) return const <Map<String, dynamic>>[];
    final sections = payload['sections'];
    if (sections is! List) return const <Map<String, dynamic>>[];
    return sections
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  Future<void> savePersonalizedSummary(String summary) async {
    final payload = await loadHomePayload() ?? <String, dynamic>{};
    final newPayload = Map<String, dynamic>.from(payload);
    newPayload['personalized_summary'] = summary;
    await saveHomePayload(newPayload);
  }

  Future<String> loadPersonalizedSummary() async {
    final payload = await loadHomePayload();
    if (payload == null) return 'Top picks for you';
    final value =
        payload['personalized_summary'] ?? payload['personalizedSummary'];
    return value?.toString() ?? 'Top picks for you';
  }

  Map<String, dynamic> _normalizePayload(Map<String, dynamic> payload) {
    final normalized = <String, dynamic>{};

    for (final entry in payload.entries) {
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
    normalized.putIfAbsent('deals', () => _buildFallbackDeals());
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
    normalized.putIfAbsent('personalized_summary', () => 'Top picks for you');
    normalized.putIfAbsent(
      'last_updated',
      () => DateTime.now().toUtc().toIso8601String(),
    );

    return normalized;
  }

  List<Map<String, dynamic>> _buildFallbackBanners() {
    return [
      {
        'id': 'banner-1',
        'title': 'Flipkart-style Festive Sale',
        'image_url': 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?auto=format&fit=crop&w=1200&q=80',
        'deep_link': '/deals',
        'is_active': true,
      },
      {
        'id': 'banner-2',
        'title': 'Best Phones Under ₹20,000',
        'image_url': 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?auto=format&fit=crop&w=1200&q=80',
        'deep_link': '/products',
        'is_active': true,
      },
      {
        'id': 'banner-3',
        'title': 'New Fashion Must-Haves',
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
        'subcategory_count': 18,
      },
      {
        'id': 'cat-2',
        'name': 'Fashion',
        'slug': 'fashion',
        'image_url': 'https://images.unsplash.com/photo-1521572267360-ee0c2909d518?auto=format&fit=crop&w=800&q=80',
        'is_active': true,
        'subcategory_count': 14,
      },
      {
        'id': 'cat-3',
        'name': 'Electronics',
        'slug': 'electronics',
        'image_url': 'https://images.unsplash.com/photo-1518770660439-4636190af475?auto=format&fit=crop&w=800&q=80',
        'is_active': true,
        'subcategory_count': 22,
      },
      {
        'id': 'cat-4',
        'name': 'Home',
        'slug': 'home',
        'image_url': 'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?auto=format&fit=crop&w=800&q=80',
        'is_active': true,
        'subcategory_count': 17,
      },
      {
        'id': 'cat-5',
        'name': 'Beauty',
        'slug': 'beauty',
        'image_url': 'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?auto=format&fit=crop&w=800&q=80',
        'is_active': true,
        'subcategory_count': 10,
      },
    ];
  }

  List<Map<String, dynamic>> _buildFallbackDeals() {
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
        'description': 'High-quality audio with long battery life.',
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
        'badge': 'Trending',
        'description': 'Track fitness, calls and notifications.',
        'is_active': true,
      },
      {
        'id': 'deal-3',
        'title': 'Casual Shirt Combo',
        'slug': 'casual-shirt-combo',
        'product_id': 'P-1003',
        'product_name': 'Cotton Shirt Combo',
        'original_price': 2499,
        'current_price': 1299,
        'discount_percent': 48,
        'image_url': 'https://images.unsplash.com/photo-1521572267360-ee0c2909d518?auto=format&fit=crop&w=800&q=80',
        'badge': 'New',
        'description': 'Premium everyday wear for office and travel.',
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
      },
      {
        'id': 'prod-2',
        'title': 'Nike Air Max',
        'name': 'Nike Air Max',
        'slug': 'nike-air-max',
        'price': 6999,
        'image_url': 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=800&q=80',
        'rating': 4.6,
      },
      {
        'id': 'prod-3',
        'title': '4K Smart TV',
        'name': '4K Smart TV',
        'slug': '4k-smart-tv',
        'price': 32999,
        'image_url': 'https://images.unsplash.com/photo-1593359677879-a4bb92f829d1?auto=format&fit=crop&w=800&q=80',
        'rating': 4.5,
      },
      {
        'id': 'prod-4',
        'title': 'Wooden Study Table',
        'name': 'Wooden Study Table',
        'slug': 'wooden-study-table',
        'price': 18999,
        'image_url': 'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?auto=format&fit=crop&w=800&q=80',
        'rating': 4.4,
      },
    ];
  }

  List<Map<String, dynamic>> _buildFallbackFlashSales() {
    return [
      {
        'id': 'sale-1',
        'title': 'Weekend Mega Sale',
        'product_id': 'P-2001',
        'product_name': 'Noise Headphones',
        'original_price': 5999,
        'current_price': 3499,
        'discount_percent': 41,
        'end_at': DateTime.now()
            .add(const Duration(hours: 12))
            .toUtc()
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
            .toUtc()
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
        'title': 'Home upgrades',
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
        'layout': 'grid',
        'items': _buildFallbackFeaturedProducts(),
      },
      {
        'id': 'section-fresh-arrivals',
        'title': 'Fresh arrivals',
        'subtitle': 'New this week',
        'layout': 'carousel',
        'items': _buildFallbackDeals(),
      },
    ];
  }
}
