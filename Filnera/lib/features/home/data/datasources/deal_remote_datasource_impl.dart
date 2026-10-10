import '../../../../core/network/api_client.dart';
import '../models/deal_response_model.dart';
import 'deal_remote_datasource.dart';

class DealRemoteDataSourceImpl extends DealRemoteDataSource {
  DealRemoteDataSourceImpl({super.apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<Map<String, dynamic>>> fetchHomeDeals({
    String? categoryId,
    String? subcategoryId,
    bool activeOnly = true,
    int limit = 12,
    String? sortBy,
    String? locale,
    String? country,
    String? customerId,
  }) async {
    final queryParameters = <String, dynamic>{
      'limit': limit,
      'active_only': activeOnly,
      if (sortBy != null && sortBy.isNotEmpty) 'sort_by': sortBy,
      if (categoryId != null && categoryId.isNotEmpty)
        'category_id': categoryId,
      if (subcategoryId != null && subcategoryId.isNotEmpty)
        'subcategory_id': subcategoryId,
      if (locale != null && locale.isNotEmpty) 'locale': locale,
      if (country != null && country.isNotEmpty) 'country': country,
      if (customerId != null && customerId.isNotEmpty)
        'customer_id': customerId,
    };

    try {
      final response = await _apiClient.get(
        '/home/deals',
        queryParameters: queryParameters,
      );
      final normalized = _normalizeList(response.data);
      if (normalized.isNotEmpty) {
        return normalized;
      }
      return _fallbackDeals(categoryId: categoryId);
    } catch (_) {
      return _fallbackDeals(categoryId: categoryId);
    }
  }

  Future<List<Map<String, dynamic>>> fetchFeaturedDeals({
    String? categoryId,
    int limit = 6,
  }) async {
    final deals = await fetchHomeDeals(
      categoryId: categoryId,
      limit: limit,
      sortBy: 'discount',
    );
    if (deals.isEmpty) {
      return _fallbackDeals(categoryId: categoryId).take(limit).toList();
    }

    final sorted = [...deals]
      ..sort((a, b) {
        final aDiscount = _asDouble(a['discount_percent'] ?? 0);
        final bDiscount = _asDouble(b['discount_percent'] ?? 0);
        return bDiscount.compareTo(aDiscount);
      });

    return sorted.take(limit).toList();
  }

  Future<List<Map<String, dynamic>>> fetchTrendingDeals({
    String? categoryId,
    int limit = 8,
  }) async {
    final deals = await fetchHomeDeals(
      categoryId: categoryId,
      limit: limit,
      sortBy: 'sales',
    );

    if (deals.isEmpty) {
      return _fallbackDeals(categoryId: categoryId).take(limit).toList();
    }

    final sorted = [...deals]
      ..sort((a, b) {
        final aSold = _asInt(a['sold_count'] ?? 0);
        final bSold = _asInt(b['sold_count'] ?? 0);
        return bSold.compareTo(aSold);
      });

    return sorted.take(limit).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> fetchFlashDeals({
    int limit = 8,
    String? categoryId,
  }) async {
    try {
      final response = await _apiClient.get(
        '/home/flash-deals',
        queryParameters: {
          'limit': limit,
          'active_only': true,
          if (categoryId != null && categoryId.isNotEmpty)
            'category_id': categoryId,
        },
      );
      final normalized = _normalizeList(response.data);
      if (normalized.isNotEmpty) {
        return normalized;
      }
      return _fallbackFlashDeals(categoryId: categoryId);
    } catch (_) {
      return _fallbackFlashDeals(categoryId: categoryId);
    }
  }

  @override
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
      if (normalized.isNotEmpty) {
        return normalized;
      }
      return _fallbackDeals(categoryId: categoryId);
    } catch (_) {
      return _fallbackDeals(categoryId: categoryId);
    }
  }

  @override
  Future<Map<String, dynamic>> fetchDealById(String dealId) async {
    if (dealId.trim().isEmpty) {
      throw const FormatException('Deal id cannot be empty');
    }

    try {
      final response = await _apiClient.get('/home/deals/$dealId');
      final normalized = _normalizeMap(response.data);
      if (normalized.isNotEmpty) {
        return normalized;
      }
      return _fallbackDeals().first;
    } catch (_) {
      final fallback = _fallbackDeals().firstWhere(
        (deal) => deal['id'] == dealId,
        orElse: () => _fallbackDeals().first,
      );
      return fallback;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> searchDeals({
    required String query,
    int limit = 12,
    String? categoryId,
  }) async {
    final sanitized = query.trim();
    if (sanitized.isEmpty) {
      return _fallbackDeals(categoryId: categoryId);
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
      if (normalized.isNotEmpty) {
        return normalized;
      }

      return _fallbackDeals(categoryId: categoryId)
          .where((deal) {
            final title = deal['title']?.toString().toLowerCase() ?? '';
            final productName =
                deal['product_name']?.toString().toLowerCase() ?? '';
            final queryLower = sanitized.toLowerCase();
            return title.contains(queryLower) ||
                productName.contains(queryLower);
          })
          .take(limit)
          .toList();
    } catch (_) {
      return _fallbackDeals(categoryId: categoryId)
          .where((deal) {
            final title = deal['title']?.toString().toLowerCase() ?? '';
            final productName =
                deal['product_name']?.toString().toLowerCase() ?? '';
            final queryLower = sanitized.toLowerCase();
            return title.contains(queryLower) ||
                productName.contains(queryLower);
          })
          .take(limit)
          .toList();
    }
  }

  Future<void> trackDealClick({
    required String dealId,
    String? productId,
    String? source,
    String? campaignId,
    String? customerId,
  }) async {
    try {
      await _apiClient.post(
        '/analytics/deal-click',
        data: {
          'deal_id': dealId,
          if (productId != null && productId.isNotEmpty)
            'product_id': productId,
          if (source != null && source.isNotEmpty) 'source': source,
          if (campaignId != null && campaignId.isNotEmpty)
            'campaign_id': campaignId,
          if (customerId != null && customerId.isNotEmpty)
            'customer_id': customerId,
          'clicked_at': DateTime.now().toUtc().toIso8601String(),
        },
      );
    } catch (_) {
      // Intentionally swallow analytics failures so storefront remains usable.
    }
  }

  Future<List<Map<String, dynamic>>> fetchCampaignDeals({
    required String campaignId,
    int limit = 8,
  }) async {
    try {
      final response = await _apiClient.get(
        '/home/campaigns/$campaignId/deals',
        queryParameters: {'limit': limit, 'active_only': true},
      );
      final normalized = _normalizeList(response.data);
      if (normalized.isNotEmpty) {
        return normalized;
      }
      return _fallbackDeals()
          .where((deal) => (deal['campaign_id'] ?? '') == campaignId)
          .take(limit)
          .toList();
    } catch (_) {
      return _fallbackDeals()
          .where((deal) => (deal['campaign_id'] ?? '') == campaignId)
          .take(limit)
          .toList();
    }
  }

  Future<Map<String, dynamic>> getDealsSummary() async {
    try {
      final response = await _apiClient.get(
        '/home/deals/summary',
        queryParameters: {'locale': 'en_IN', 'currency': 'INR'},
      );

      if (response.data is Map) {
        final map = Map<String, dynamic>.from(response.data as Map);
        return map;
      }

      return {
        'total_deals': 24,
        'active_campaigns': 6,
        'top_category': 'electronics',
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      };
    } catch (_) {
      return {
        'total_deals': 24,
        'active_campaigns': 6,
        'top_category': 'electronics',
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      };
    }
  }

  List<Map<String, dynamic>> _normalizeList(dynamic data) {
    final response = DealResponseModel.fromValue(data);
    if (!response.isSuccessful) return const <Map<String, dynamic>>[];
    return response.deals
        .map(
          (item) => <String, dynamic>{
            ...item.toJson(),
            'seller': item.seller ?? 'Flipkart assured',
            'rating': item.rating > 0 ? item.rating : 4.3,
          },
        )
        .toList(growable: false);
  }

  Map<String, dynamic> _normalizeMap(dynamic data) {
    final response = DealResponseModel.fromValue(data);
    if (!response.isSuccessful || response.deals.isEmpty) {
      return _fallbackDeals().first;
    }
    final item = response.deals.first;
    return <String, dynamic>{
      ...item.toJson(),
      'seller': item.seller ?? 'Flipkart assured',
      'rating': item.rating > 0 ? item.rating : 4.3,
    };
  }

  List<Map<String, dynamic>> _fallbackDeals({String? categoryId}) {
    final now = DateTime.now();
    final deals = [
      {
        'id': 'deal-101',
        'title': 'Noise Buds X',
        'slug': 'noise-buds-x',
        'product_id': 'P-101',
        'product_name': 'Noise Buds X',
        'original_price': 3999,
        'current_price': 2199,
        'discount_percent': 45,
        'image_url': 'https://images.unsplash.com/photo-1546435770-a3e426bf472b?auto=format&fit=crop&w=800&q=80',
        'badge': 'Top Deal',
        'description': 'Premium wireless sound with 45 hours battery backup.',
        'category_id': 'electronics',
        'start_at': now.toUtc().toIso8601String(),
        'end_at': now.add(const Duration(days: 8)).toUtc().toIso8601String(),
        'is_active': true,
        'stock_progress': 68,
        'sold_count': 1280,
        'remaining_count': 240,
        'cta_label': 'Buy now',
        'campaign_id': 'campaign-electronics',
        'seller': 'Noise official',
        'rating': 4.5,
        'reviews_count': 2910,
      },
      {
        'id': 'deal-102',
        'title': 'Amazfit Active',
        'slug': 'amazfit-active',
        'product_id': 'P-102',
        'product_name': 'Amazfit Active',
        'original_price': 7999,
        'current_price': 4999,
        'discount_percent': 37,
        'image_url': 'https://images.unsplash.com/photo-1546868871-7041f2a55e12?auto=format&fit=crop&w=800&q=80',
        'badge': 'Trending',
        'description': 'Smart fitness tracking with AMOLED display and GPS.',
        'category_id': 'electronics',
        'start_at': now.toUtc().toIso8601String(),
        'end_at': now.add(const Duration(days: 12)).toUtc().toIso8601String(),
        'is_active': true,
        'stock_progress': 52,
        'sold_count': 930,
        'remaining_count': 180,
        'cta_label': 'Explore',
        'campaign_id': 'campaign-wearables',
        'seller': 'Amazfit store',
        'rating': 4.4,
        'reviews_count': 1670,
      },
      {
        'id': 'deal-103',
        'title': 'Cotton Combo Shirt',
        'slug': 'cotton-combo-shirt',
        'product_id': 'P-103',
        'product_name': 'Cotton Combo Shirt',
        'original_price': 2499,
        'current_price': 1299,
        'discount_percent': 48,
        'image_url': 'https://images.unsplash.com/photo-1521572267360-ee0c2909d518?auto=format&fit=crop&w=800&q=80',
        'badge': 'Hot',
        'description': 'Lightweight comfort for daily casual wear.',
        'category_id': 'fashion',
        'start_at': now.toUtc().toIso8601String(),
        'end_at': now.add(const Duration(days: 7)).toUtc().toIso8601String(),
        'is_active': true,
        'stock_progress': 60,
        'sold_count': 740,
        'remaining_count': 140,
        'cta_label': 'View deal',
        'campaign_id': 'campaign-fashion',
        'seller': 'Urban thread',
        'rating': 4.2,
        'reviews_count': 982,
      },
      {
        'id': 'deal-104',
        'title': 'NutriBlend Go',
        'slug': 'nutriblend-go',
        'product_id': 'P-104',
        'product_name': 'NutriBlend Go',
        'original_price': 3499,
        'current_price': 1999,
        'discount_percent': 43,
        'image_url': 'https://images.unsplash.com/photo-1559056199-641a0ac8b55e?auto=format&fit=crop&w=800&q=80',
        'badge': 'Fresh Pick',
        'description':
            'Portable blender ideal for smoothies, shakes and workouts.',
        'category_id': 'home',
        'start_at': now.toUtc().toIso8601String(),
        'end_at': now.add(const Duration(days: 9)).toUtc().toIso8601String(),
        'is_active': true,
        'stock_progress': 47,
        'sold_count': 540,
        'remaining_count': 130,
        'cta_label': 'Grab deal',
        'campaign_id': 'campaign-home',
        'seller': 'Kitchen essentials',
        'rating': 4.1,
        'reviews_count': 641,
      },
      {
        'id': 'deal-105',
        'title': 'Premium Kitchen Set',
        'slug': 'premium-kitchen-set',
        'product_id': 'P-105',
        'product_name': 'Premium Kitchen Set',
        'original_price': 5999,
        'current_price': 3499,
        'discount_percent': 42,
        'image_url': 'https://images.unsplash.com/photo-1585518419759-7fe2e0fbf8a6?auto=format&fit=crop&w=800&q=80',
        'badge': 'Save more',
        'description':
            'Complete kitchen upgrade for everyday cooking convenience.',
        'category_id': 'home',
        'start_at': now.toUtc().toIso8601String(),
        'end_at': now.add(const Duration(days: 10)).toUtc().toIso8601String(),
        'is_active': true,
        'stock_progress': 55,
        'sold_count': 680,
        'remaining_count': 150,
        'cta_label': 'Shop now',
        'campaign_id': 'campaign-home',
        'seller': 'Home lane',
        'rating': 4.3,
        'reviews_count': 880,
      },
      {
        'id': 'deal-106',
        'title': 'Women’s Run Sneakers',
        'slug': 'womens-run-sneakers',
        'product_id': 'P-106',
        'product_name': 'Women’s Run Sneakers',
        'original_price': 6999,
        'current_price': 3899,
        'discount_percent': 44,
        'image_url': 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=800&q=80',
        'badge': 'Rush',
        'description': 'Lightweight running shoes with all-day cushioning.',
        'category_id': 'fashion',
        'start_at': now.toUtc().toIso8601String(),
        'end_at': now.add(const Duration(hours: 12)).toUtc().toIso8601String(),
        'is_active': true,
        'stock_progress': 63,
        'sold_count': 980,
        'remaining_count': 132,
        'cta_label': 'Buy now',
        'campaign_id': 'campaign-fashion',
        'seller': 'Sportizon',
        'rating': 4.4,
        'reviews_count': 1170,
      },
    ];

    if (categoryId == null || categoryId.isEmpty) {
      return deals;
    }

    return deals
        .where((deal) => (deal['category_id'] ?? '').toString() == categoryId)
        .toList();
  }

  List<Map<String, dynamic>> _fallbackFlashDeals({String? categoryId}) {
    final now = DateTime.now();
    final deals = [
      {
        'id': 'flash-deal-1',
        'title': 'Weekend Flash Sale',
        'slug': 'weekend-flash-sale',
        'product_id': 'P-201',
        'product_name': 'Smart Earbuds',
        'original_price': 5999,
        'current_price': 3499,
        'discount_percent': 42,
        'image_url': 'https://images.unsplash.com/photo-1546435770-a3e426bf472b?auto=format&fit=crop&w=800&q=80',
        'badge': 'Flash',
        'description': 'Limited-time offer on audio accessories.',
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
        'title': 'Fashion Rush',
        'slug': 'fashion-rush',
        'product_id': 'P-202',
        'product_name': 'Trail Running Sneakers',
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

    if (categoryId == null || categoryId.isEmpty) {
      return deals;
    }

    return deals
        .where((deal) => (deal['category_id'] ?? '').toString() == categoryId)
        .toList();
  }

  double _asDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? 0;
    }
    return 0;
  }

  int _asInt(dynamic value) {
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }
}
