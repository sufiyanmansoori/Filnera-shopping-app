import '../../../../core/network/api_client.dart';
import '../models/banner_response_model.dart';

class BannerRemoteDataSource {
  BannerRemoteDataSource({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<Map<String, dynamic>>> fetchBanners({
    int page = 1,
    int? pageSize,
    String? categoryId,
    bool activeOnly = true,
    int limit = 10,
    String? locale,
    String? currency,
    String? country,
    String? deviceType,
  }) async {
    final safePage = page < 1 ? 1 : page;
    final safePageSize = (pageSize ?? limit).clamp(1, 50);
    final queryParameters = <String, dynamic>{
      'page': safePage,
      'page_size': safePageSize,
      'limit': limit.clamp(1, 100),
      'active_only': activeOnly,
      if (categoryId != null && categoryId.isNotEmpty)
        'category_id': categoryId,
      if (locale != null && locale.isNotEmpty) 'locale': locale,
      if (currency != null && currency.isNotEmpty) 'currency': currency,
      if (country != null && country.isNotEmpty) 'country': country,
      if (deviceType != null && deviceType.isNotEmpty)
        'device_type': deviceType,
    };

    try {
      final response = await _apiClient.get(
        '/home/banners',
        queryParameters: queryParameters,
      );
      return _normalizeBannerList(response.data);
    } catch (_) {
      try {
        final response = await _apiClient.get(
          '/banners',
          queryParameters: queryParameters,
        );
        return _normalizeBannerList(response.data);
      } catch (_) {
        return _fallbackBanners();
      }
    }
  }

  Future<List<Map<String, dynamic>>> fetchHeroBanners({
    String? categoryId,
    int limit = 5,
    String? locale,
    String? country,
  }) async {
    final banners = await fetchBanners(
      categoryId: categoryId,
      activeOnly: true,
      limit: limit,
      locale: locale,
      country: country,
    );
    return banners
            .where(
              (banner) =>
                  banner['priority'] == 'hero' || banner['position'] == 'hero',
            )
            .toList()
            .isEmpty
        ? banners.take(limit).toList()
        : banners
              .where(
                (banner) =>
                    banner['priority'] == 'hero' ||
                    banner['position'] == 'hero',
              )
              .take(limit)
              .toList();
  }

  Future<List<Map<String, dynamic>>> fetchPromotionalBanners({
    String? categoryId,
    int limit = 6,
  }) async {
    final banners = await fetchBanners(
      categoryId: categoryId,
      activeOnly: true,
      limit: limit,
    );
    return banners
            .where(
              (banner) =>
                  banner['type'] == 'promo' || banner['campaign'] != null,
            )
            .toList()
            .isEmpty
        ? banners.take(limit).toList()
        : banners
              .where(
                (banner) =>
                    banner['type'] == 'promo' || banner['campaign'] != null,
              )
              .take(limit)
              .toList();
  }

  Future<Map<String, dynamic>> fetchBannerById(String bannerId) async {
    if (bannerId.trim().isEmpty) {
      throw const FormatException('Banner id cannot be empty');
    }

    try {
      final response = await _apiClient.get('/home/banners/$bannerId');
      final normalized = _normalizeBannerMap(response.data);
      return normalized;
    } catch (_) {
      final fallback = _fallbackBanners().firstWhere(
        (banner) => banner['id'] == bannerId,
        orElse: () => _fallbackBanners().first,
      );
      return fallback;
    }
  }

  Future<List<Map<String, dynamic>>> fetchByCategory(String categoryId) async {
    if (categoryId.trim().isEmpty) {
      return _fallbackBanners();
    }

    final banners = await fetchBanners(categoryId: categoryId, limit: 8);
    if (banners.isEmpty) {
      return _fallbackBanners()
          .where((banner) => banner['category_id'] == categoryId)
          .toList();
    }
    return banners;
  }

  List<Map<String, dynamic>> _normalizeBannerList(dynamic data) {
    final list = _extractList(data);
    if (list.isEmpty) {
      return _fallbackBanners();
    }

    final normalized = <Map<String, dynamic>>[];
    for (final item in list) {
      if (item is Map) {
        normalized.add(_normalizeBannerMap(item));
      }
    }

    if (normalized.isEmpty) {
      return _fallbackBanners();
    }

    return normalized;
  }

  Map<String, dynamic> _normalizeBannerMap(dynamic data) {
    if (data is! Map) {
      return _fallbackBanners().first;
    }

    final map = _normalizeMap(Map<String, dynamic>.from(data));

    final normalized = <String, dynamic>{
      'id':
          map['id'] ??
          map['banner_id'] ??
          map['bannerId'] ??
          'banner-${DateTime.now().millisecondsSinceEpoch}',
      'title': map['title'] ?? map['name'] ?? 'Trending offer',
      'subtitle': map['subtitle'] ?? map['description'] ?? '',
      'description': map['description'] ?? map['subtitle'] ?? '',
      'image_url': map['image_url'] ?? map['imageUrl'] ?? map['image'] ?? 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?auto=format&fit=crop&w=1200&q=80',
      'deep_link':
          map['deep_link'] ??
          map['deepLink'] ??
          map['target_url'] ??
          map['targetUrl'] ??
          '/products',
      'target_url':
          map['target_url'] ??
          map['targetUrl'] ??
          map['deep_link'] ??
          map['deepLink'] ??
          '/products',
      'type': map['type'] ?? map['banner_type'] ?? map['bannerType'] ?? 'promo',
      'priority': map['priority'] ?? map['position'] ?? 'regular',
      'position': map['position'] ?? map['priority'] ?? 'regular',
      'is_active': map['is_active'] ?? map['isActive'] ?? true,
      'active': map['active'] ?? map['is_active'] ?? map['isActive'] ?? true,
      'cta_label': map['cta_label'] ?? map['ctaLabel'] ?? 'Shop now',
      'category_id': map['category_id'] ?? map['categoryId'] ?? '',
      'campaign_id': map['campaign_id'] ?? map['campaignId'] ?? '',
      'start_at': map['start_at'] ?? map['startAt'],
      'end_at': map['end_at'] ?? map['endAt'],
      'order_index': map['order_index'] ?? map['orderIndex'] ?? 0,
      'alt_text':
          map['alt_text'] ?? map['altText'] ?? map['title'] ?? 'Offer banner',
      'background_color':
          map['background_color'] ?? map['backgroundColor'] ?? '#F5F5F7',
      'metadata': map['metadata'] ?? <String, dynamic>{},
      'isFeatured': map['isFeatured'] ?? false,
    };

    return BannerItemModel.fromJson(normalized).toJson();
  }

  List<dynamic> _extractList(dynamic data) {
    final response = BannerResponseModel.fromValue(data);
    if (!response.isSuccessful) return const <dynamic>[];
    return response.banners
        .map((banner) => banner.toJson())
        .toList(growable: false);
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
    return normalized;
  }

  List<Map<String, dynamic>> _fallbackBanners() {
    final now = DateTime.now();
    return [
      {
        'id': 'banner-flipkart-hero-1',
        'title': 'Big Billion Days',
        'subtitle': 'Save up to 80% on essentials',
        'description':
            'Shop the biggest discounts across electronics, fashion and home',
        'image_url': 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?auto=format&fit=crop&w=1200&q=80',
        'deep_link': '/deals',
        'target_url': '/deals',
        'type': 'hero',
        'priority': 'hero',
        'position': 'hero',
        'cta_label': 'Shop now',
        'is_active': true,
        'active': true,
        'category_id': 'all',
        'campaign_id': 'campaign-bbd',
        'start_at': now.toUtc().toIso8601String(),
        'end_at': now.add(const Duration(days: 14)).toUtc().toIso8601String(),
        'order_index': 1,
        'alt_text': 'Big billion days sale banner',
        'background_color': '#FFE6DA',
        'metadata': {'tag': 'featured'},
      },
      {
        'id': 'banner-flipkart-hero-2',
        'title': 'Smartphone blitz',
        'subtitle': 'Phones under ₹15,999',
        'description': 'Exclusive launch deals and cashback offers',
        'image_url': 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?auto=format&fit=crop&w=1200&q=80',
        'deep_link': '/products?category=mobiles',
        'target_url': '/products?category=mobiles',
        'type': 'promo',
        'priority': 'hero',
        'position': 'hero',
        'cta_label': 'Explore deals',
        'is_active': true,
        'active': true,
        'category_id': 'mobiles',
        'campaign_id': 'campaign-mobile',
        'start_at': now.toUtc().toIso8601String(),
        'end_at': now.add(const Duration(days: 10)).toUtc().toIso8601String(),
        'order_index': 2,
        'alt_text': 'Smartphone sale banner',
        'background_color': '#E8F1FF',
        'metadata': {'tag': 'phones'},
      },
      {
        'id': 'banner-fashion-1',
        'title': 'Fashion flash',
        'subtitle': 'Up to 70% off on styles',
        'description':
            'Discover tops, shoes and lifestyle picks curated for the season',
        'image_url': 'https://images.unsplash.com/photo-1521572267360-ee0c2909d518?auto=format&fit=crop&w=900&q=80',
        'deep_link': '/search?q=fashion',
        'target_url': '/search?q=fashion',
        'type': 'promo',
        'priority': 'regular',
        'position': 'middle',
        'cta_label': 'Shop fashion',
        'is_active': true,
        'active': true,
        'category_id': 'fashion',
        'campaign_id': 'campaign-fashion',
        'start_at': now.toUtc().toIso8601String(),
        'end_at': now.add(const Duration(days: 12)).toUtc().toIso8601String(),
        'order_index': 3,
        'alt_text': 'Fashion flash sale banner',
        'background_color': '#FFF1F0',
        'metadata': {'tag': 'fashion'},
      },
      {
        'id': 'banner-home-1',
        'title': 'Home makeover',
        'subtitle': 'Furniture and decor deals',
        'description': 'Refresh your living space with premium essentials and smart organization',
        'image_url': 'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?auto=format&fit=crop&w=900&q=80',
        'deep_link': '/products?category=home',
        'target_url': '/products?category=home',
        'type': 'promo',
        'priority': 'regular',
        'position': 'lower',
        'cta_label': 'Decor now',
        'is_active': true,
        'active': true,
        'category_id': 'home',
        'campaign_id': 'campaign-home',
        'start_at': now.toUtc().toIso8601String(),
        'end_at': now.add(const Duration(days: 15)).toUtc().toIso8601String(),
        'order_index': 4,
        'alt_text': 'Home decor promo banner',
        'background_color': '#EEF7ED',
        'metadata': {'tag': 'home'},
      },
      {
        'id': 'banner-electronics-1',
        'title': 'Electronics under ₹999',
        'subtitle': 'Accessories and gadgets',
        'description': 'Smart accessories, audio gear and travel tech at unbelievable prices',
        'image_url': 'https://images.unsplash.com/photo-1518770660439-4636190af475?auto=format&fit=crop&w=900&q=80',
        'deep_link': '/products?category=electronics',
        'target_url': '/products?category=electronics',
        'type': 'promo',
        'priority': 'regular',
        'position': 'lower',
        'cta_label': 'View gadgets',
        'is_active': true,
        'active': true,
        'category_id': 'electronics',
        'campaign_id': 'campaign-electronics',
        'start_at': now.toUtc().toIso8601String(),
        'end_at': now.add(const Duration(days: 11)).toUtc().toIso8601String(),
        'order_index': 5,
        'alt_text': 'Electronics accessories promo banner',
        'background_color': '#F0F3FF',
        'metadata': {'tag': 'tech'},
      },
      {
        'id': 'banner-beauty-1',
        'title': 'Beauty essentials',
        'subtitle': 'Glow, wellness and daily care',
        'description':
            'Daily essentials crafted to elevate your beauty routine',
        'image_url': 'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?auto=format&fit=crop&w=900&q=80',
        'deep_link': '/search?q=beauty',
        'target_url': '/search?q=beauty',
        'type': 'promo',
        'priority': 'regular',
        'position': 'middle',
        'cta_label': 'See offers',
        'is_active': true,
        'active': true,
        'category_id': 'beauty',
        'campaign_id': 'campaign-beauty',
        'start_at': now.toUtc().toIso8601String(),
        'end_at': now.add(const Duration(days: 13)).toUtc().toIso8601String(),
        'order_index': 6,
        'alt_text': 'Beauty essentials campaign banner',
        'background_color': '#FFE9F4',
        'metadata': {'tag': 'wellness'},
      },
    ];
  }
}
