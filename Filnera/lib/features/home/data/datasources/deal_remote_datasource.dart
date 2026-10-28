import '../../../../core/network/api_client.dart';
import '../models/deal_response_model.dart';

class DealRemoteDataSource {
  DealRemoteDataSource({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<Map<String, dynamic>>> fetchDeals({
    String? categoryId,
    String? subcategoryId,
    bool activeOnly = true,
    int limit = 12,
    int page = 1,
    int? pageSize,
    String? sortBy,
    String? locale,
    String? currency,
    String? country,
    String? deviceType,
  }) async {
    final safePage = page < 1 ? 1 : page;
    final safeLimit = limit.clamp(1, 100);
    final safePageSize = (pageSize ?? safeLimit).clamp(1, 100);
    final queryParameters = <String, dynamic>{
      'limit': safeLimit,
      'page': safePage,
      'page_size': safePageSize,
      'active_only': activeOnly,
      if (sortBy != null && sortBy.isNotEmpty) 'sort_by': sortBy,
      if (categoryId != null && categoryId.isNotEmpty)
        'category_id': categoryId,
      if (subcategoryId != null && subcategoryId.isNotEmpty)
        'subcategory_id': subcategoryId,
      if (locale != null && locale.isNotEmpty) 'locale': locale,
      if (currency != null && currency.isNotEmpty) 'currency': currency,
      if (country != null && country.isNotEmpty) 'country': country,
      if (deviceType != null && deviceType.isNotEmpty)
        'device_type': deviceType,
    };

    try {
      final response = await _apiClient.get(
        '/home/deals',
        queryParameters: queryParameters,
      );
      final normalized = _normalizeList(response.data);
      if (normalized.isNotEmpty) return normalized;
      return _paginateFallbackDeals(
        _fallbackDeals(),
        page: safePage,
        pageSize: safePageSize,
      );
    } catch (_) {
      try {
        final response = await _apiClient.get(
          '/deals',
          queryParameters: queryParameters,
        );
        final normalized = _normalizeList(response.data);
        if (normalized.isNotEmpty) return normalized;
        return _paginateFallbackDeals(
          _fallbackDeals(),
          page: safePage,
          pageSize: safePageSize,
        );
      } catch (_) {
        return _paginateFallbackDeals(
          _fallbackDeals(),
          page: safePage,
          pageSize: safePageSize,
        );
      }
    }
  }

  Future<List<Map<String, dynamic>>> fetchFlashDeals({
    int limit = 8,
    String? categoryId,
  }) async {
    try {
      final response = await _apiClient.get(
        '/home/flash-deals',
        queryParameters: {
          'limit': limit,
          if (categoryId != null && categoryId.isNotEmpty)
            'category_id': categoryId,
          'active_only': true,
        },
      );
      final normalized = _normalizeList(response.data);
      if (normalized.isNotEmpty) return normalized;
      return _fallbackFlashDeals();
    } catch (_) {
      return _fallbackFlashDeals();
    }
  }

  Future<List<Map<String, dynamic>>> fetchCategoryDeals({
    required String categoryId,
    int limit = 10,
  }) async {
    if (categoryId.trim().isEmpty) {
      return _fallbackDeals();
    }

    try {
      final response = await _apiClient.get(
        '/home/deals',
        queryParameters: {
          'category_id': categoryId,
          'limit': limit,
          'active_only': true,
        },
      );
      final normalized = _normalizeList(response.data);
      if (normalized.isNotEmpty) return normalized;
      return _fallbackCategoryDeals(categoryId);
    } catch (_) {
      return _fallbackCategoryDeals(categoryId);
    }
  }

  Future<Map<String, dynamic>> fetchDealById(String dealId) async {
    if (dealId.trim().isEmpty) {
      throw const FormatException('Deal id cannot be empty');
    }

    try {
      final response = await _apiClient.get('/home/deals/$dealId');
      final normalized = _normalizeMap(response.data);
      if (normalized.isNotEmpty) return normalized;
      return _fallbackDeals().first;
    } catch (_) {
      final fallback = _fallbackDeals().firstWhere(
        (deal) => deal['id'] == dealId,
        orElse: () => _fallbackDeals().first,
      );
      return fallback;
    }
  }

  Future<List<Map<String, dynamic>>> searchDeals({
    required String query,
    int limit = 12,
    String? categoryId,
  }) async {
    final sanitized = query.trim();
    if (sanitized.isEmpty) {
      return _fallbackDeals();
    }

    try {
      final response = await _apiClient.get(
        '/home/deals/search',
        queryParameters: {
          'q': sanitized,
          'limit': limit,
          if (categoryId != null && categoryId.isNotEmpty)
            'category_id': categoryId,
        },
      );
      final normalized = _normalizeList(response.data);
      if (normalized.isNotEmpty) return normalized;
      return _fallbackDeals();
    } catch (_) {
      return _fallbackDeals().where((deal) {
        final title = deal['title']?.toString().toLowerCase() ?? '';
        final productName =
            deal['product_name']?.toString().toLowerCase() ?? '';
        return title.contains(sanitized.toLowerCase()) ||
            productName.contains(sanitized.toLowerCase());
      }).toList();
    }
  }

  List<Map<String, dynamic>> _normalizeList(dynamic data) {
    final response = DealResponseModel.fromValue(data);
    if (!response.isSuccessful) return const <Map<String, dynamic>>[];
    return response.deals.map((deal) => deal.toJson()).toList(growable: false);
  }

  List<Map<String, dynamic>> _paginateFallbackDeals(
    List<Map<String, dynamic>> deals, {
    required int page,
    required int pageSize,
  }) {
    final start = ((page - 1) * pageSize).clamp(0, deals.length);
    final end = (start + pageSize).clamp(start, deals.length);
    return deals.sublist(start, end);
  }

  Map<String, dynamic> _normalizeMap(dynamic data) {
    final response = DealResponseModel.fromValue(data);
    if (!response.isSuccessful || response.deals.isEmpty) {
      return _fallbackDeals().first;
    }
    return response.deals.first.toJson();
  }

  List<Map<String, dynamic>> _fallbackDeals() {
    final now = DateTime.now();
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
        'description': 'Premium wireless sound with all-day battery life.',
        'category_id': 'electronics',
        'start_at': now.toUtc().toIso8601String(),
        'end_at': now.add(const Duration(days: 10)).toUtc().toIso8601String(),
        'is_active': true,
        'stock_progress': 68,
        'sold_count': 1280,
        'remaining_count': 240,
        'cta_label': 'Buy now',
        'campaign_id': 'campaign-electronics',
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
        'description':
            'Fitness tracking, calls, notifications and premium style.',
        'category_id': 'electronics',
        'start_at': now.toUtc().toIso8601String(),
        'end_at': now.add(const Duration(days: 12)).toUtc().toIso8601String(),
        'is_active': true,
        'stock_progress': 52,
        'sold_count': 930,
        'remaining_count': 180,
        'cta_label': 'Shop now',
        'campaign_id': 'campaign-wearables',
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
        'badge': 'Hot',
        'description': 'Soft cotton look for everyday comfort and confidence.',
        'category_id': 'fashion',
        'start_at': now.toUtc().toIso8601String(),
        'end_at': now.add(const Duration(days: 8)).toUtc().toIso8601String(),
        'is_active': true,
        'stock_progress': 60,
        'sold_count': 740,
        'remaining_count': 140,
        'cta_label': 'View deal',
        'campaign_id': 'campaign-fashion',
      },
      {
        'id': 'deal-4',
        'title': 'Portable Blender',
        'slug': 'portable-blender',
        'product_id': 'P-1004',
        'product_name': 'NutriBlend Go',
        'original_price': 3499,
        'current_price': 1999,
        'discount_percent': 43,
        'image_url': 'https://images.unsplash.com/photo-1559056199-641a0ac8b55e?auto=format&fit=crop&w=800&q=80',
        'badge': 'Fresh pick',
        'description':
            'Perfect for smoothies, shakes and daily wellness routines.',
        'category_id': 'home',
        'start_at': now.toUtc().toIso8601String(),
        'end_at': now.add(const Duration(days: 9)).toUtc().toIso8601String(),
        'is_active': true,
        'stock_progress': 47,
        'sold_count': 540,
        'remaining_count': 130,
        'cta_label': 'Grab deal',
        'campaign_id': 'campaign-home',
      },
    ];
  }

  List<Map<String, dynamic>> _fallbackFlashDeals() {
    final now = DateTime.now();
    return [
      {
        'id': 'flash-deal-1',
        'title': 'Weekend flash sale',
        'slug': 'weekend-flash-sale',
        'product_id': 'P-2001',
        'product_name': 'Smart earbuds',
        'original_price': 5999,
        'current_price': 3499,
        'discount_percent': 41,
        'image_url': 'https://images.unsplash.com/photo-1546435770-a3e426bf472b?auto=format&fit=crop&w=800&q=80',
        'badge': 'Flash',
        'description': 'Limited-time discount on must-have audio gear.',
        'category_id': 'electronics',
        'start_at': now.toUtc().toIso8601String(),
        'end_at': now.add(const Duration(hours: 12)).toUtc().toIso8601String(),
        'is_active': true,
        'stock_progress': 72,
        'sold_count': 1420,
        'remaining_count': 96,
        'cta_label': 'Hurry up',
        'campaign_id': 'campaign-flash',
      },
      {
        'id': 'flash-deal-2',
        'title': 'Fashion rush',
        'slug': 'fashion-rush',
        'product_id': 'P-2002',
        'product_name': 'Trail running sneakers',
        'original_price': 6999,
        'current_price': 3899,
        'discount_percent': 44,
        'image_url': 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=800&q=80',
        'badge': 'Rush',
        'description': 'Best value on sneakers and activewear.',
        'category_id': 'fashion',
        'start_at': now.toUtc().toIso8601String(),
        'end_at': now.add(const Duration(hours: 9)).toUtc().toIso8601String(),
        'is_active': true,
        'stock_progress': 63,
        'sold_count': 980,
        'remaining_count': 132,
        'cta_label': 'Buy now',
        'campaign_id': 'campaign-flash-fashion',
      },
    ];
  }

  List<Map<String, dynamic>> _fallbackCategoryDeals(String categoryId) {
    final base = _fallbackDeals();
    if (categoryId.isEmpty) return base;
    return base
        .where((deal) => (deal['category_id'] ?? '').toString() == categoryId)
        .toList();
  }
}
