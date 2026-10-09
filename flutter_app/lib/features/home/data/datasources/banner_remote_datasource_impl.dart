import '../../../../core/network/api_client.dart';
import '../models/banner_response_model.dart';
import 'banner_remote_datasource.dart';

class BannerRemoteDataSourceImpl extends BannerRemoteDataSource {
  BannerRemoteDataSourceImpl({super.apiClient});

  Future<List<Map<String, dynamic>>> fetchFeaturedBanners({
    String? categoryId,
    int limit = 5,
    String? locale,
    String? country,
    bool activeOnly = true,
  }) async {
    try {
      final response = await ApiClient().get(
        '/home/banners',
        queryParameters: {
          'type': 'hero',
          'limit': limit,
          'active_only': activeOnly,
          if (categoryId != null && categoryId.isNotEmpty)
            'category_id': categoryId,
          if (locale != null && locale.isNotEmpty) 'locale': locale,
          if (country != null && country.isNotEmpty) 'country': country,
        },
      );
      final normalized = _normalizeList(response.data);
      if (normalized.isNotEmpty) return normalized;
      return _fallbackHeroBanners();
    } catch (_) {
      return _fallbackHeroBanners();
    }
  }

  Future<List<Map<String, dynamic>>> fetchCarouselBanners({
    String? categoryId,
    int limit = 8,
    bool activeOnly = true,
  }) async {
    try {
      final response = await ApiClient().get(
        '/home/banners',
        queryParameters: {
          'limit': limit,
          'active_only': activeOnly,
          if (categoryId != null && categoryId.isNotEmpty)
            'category_id': categoryId,
        },
      );
      final normalized = _normalizeList(response.data);
      if (normalized.isNotEmpty) return normalized;
      return _fallbackCarouselBanners();
    } catch (_) {
      return _fallbackCarouselBanners();
    }
  }

  Future<List<Map<String, dynamic>>> fetchCategoryBanners({
    required String categoryId,
    int limit = 6,
  }) async {
    if (categoryId.trim().isEmpty) {
      return _fallbackCategoryBanners();
    }

    try {
      final response = await ApiClient().get(
        '/home/banners',
        queryParameters: {
          'category_id': categoryId,
          'limit': limit,
          'active_only': true,
        },
      );
      final normalized = _normalizeList(response.data);
      if (normalized.isNotEmpty) return normalized;
      return _fallbackCategoryBanners();
    } catch (_) {
      return _fallbackCategoryBanners();
    }
  }

  Future<Map<String, dynamic>> fetchBannerDetail(String bannerId) async {
    if (bannerId.trim().isEmpty) {
      throw const FormatException('Banner id cannot be empty');
    }

    try {
      final response = await ApiClient().get('/home/banners/$bannerId');
      final normalized = _normalizeMap(response.data);
      if (normalized.isNotEmpty) return normalized;
      return _fallbackHeroBanners().first;
    } catch (_) {
      final fallback = _fallbackHeroBanners().firstWhere(
        (banner) => banner['id'] == bannerId,
        orElse: () => _fallbackHeroBanners().first,
      );
      return fallback;
    }
  }

  Future<void> trackBannerClick({
    required String bannerId,
    String? campaignId,
    String? channel,
    String? customerId,
  }) async {
    try {
      await ApiClient().post(
        '/analytics/banner-click',
        data: {
          'banner_id': bannerId,
          if (campaignId != null && campaignId.isNotEmpty)
            'campaign_id': campaignId,
          if (channel != null && channel.isNotEmpty) 'channel': channel,
          if (customerId != null && customerId.isNotEmpty)
            'customer_id': customerId,
          'clicked_at': DateTime.now().toUtc().toIso8601String(),
        },
      );
    } catch (_) {
      // Ignore analytics failures in production and keep storefront usable.
    }
  }

  List<Map<String, dynamic>> _normalizeList(dynamic data) {
    if (data is! List) {
      if (data is Map) {
        final map = Map<String, dynamic>.from(data);
        final listCandidate =
            map['data'] ?? map['items'] ?? map['banners'] ?? map['results'];
        if (listCandidate is List) {
          return _normalizeList(listCandidate);
        }
      }
      return const <Map<String, dynamic>>[];
    }

    final normalized = <Map<String, dynamic>>[];
    for (final item in data) {
      if (item is Map) {
        normalized.add(_normalizeMap(Map<String, dynamic>.from(item)));
      }
    }
    return normalized;
  }

  Map<String, dynamic> _normalizeMap(dynamic data) {
    if (data is! Map) {
      return _fallbackHeroBanners().first;
    }

    final source = Map<String, dynamic>.from(data);
    final target = <String, dynamic>{};

    for (final entry in source.entries) {
      final key = entry.key.toString();
      final value = entry.value;
      if (value is Map) {
        target[key] = Map<String, dynamic>.from(value);
      } else if (value is List) {
        target[key] = value
            .map((item) => item is Map ? Map<String, dynamic>.from(item) : item)
            .toList();
      } else {
        target[key] = value;
      }
    }

    final normalized = {
      'id':
          target['id'] ??
          target['banner_id'] ??
          target['bannerId'] ??
          'banner-${DateTime.now().millisecondsSinceEpoch}',
      'title': target['title'] ?? target['name'] ?? 'Trending offer',
      'subtitle': target['subtitle'] ?? target['description'] ?? '',
      'description': target['description'] ?? target['subtitle'] ?? '',
      'image_url':
          target['image_url'] ?? target['imageUrl'] ?? target['image'] ?? 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?auto=format&fit=crop&w=1200&q=80',
      'deep_link':
          target['deep_link'] ??
          target['deepLink'] ??
          target['target_url'] ??
          target['targetUrl'] ??
          '/products',
      'target_url':
          target['target_url'] ??
          target['targetUrl'] ??
          target['deep_link'] ??
          target['deepLink'] ??
          '/products',
      'type':
          target['type'] ??
          target['banner_type'] ??
          target['bannerType'] ??
          'promo',
      'priority': target['priority'] ?? target['position'] ?? 'regular',
      'position': target['position'] ?? target['priority'] ?? 'regular',
      'cta_label': target['cta_label'] ?? target['ctaLabel'] ?? 'Shop now',
      'is_active': target['is_active'] ?? target['isActive'] ?? true,
      'active':
          target['active'] ?? target['is_active'] ?? target['isActive'] ?? true,
      'category_id': target['category_id'] ?? target['categoryId'] ?? 'all',
      'campaign_id':
          target['campaign_id'] ?? target['campaignId'] ?? 'campaign-general',
      'start_at': target['start_at'] ?? target['startAt'],
      'end_at': target['end_at'] ?? target['endAt'],
      'order_index': target['order_index'] ?? target['orderIndex'] ?? 0,
      'alt_text':
          target['alt_text'] ??
          target['altText'] ??
          target['title'] ??
          'Offer banner',
      'metadata': target['metadata'] ?? <String, dynamic>{},
      'background_color':
          target['background_color'] ?? target['backgroundColor'] ?? '#F5F5F7',
    };
    return BannerItemModel.fromJson(normalized).toJson();
  }

  List<Map<String, dynamic>> _fallbackHeroBanners() {
    final now = DateTime.now();
    return [
      {
        'id': 'hero-banner-1',
        'title': 'Big Billion Days',
        'subtitle': 'Save up to 80% on top picks',
        'description':
            'Electronics, fashion and home upgrades with massive discounts.',
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
        'alt_text': 'Big Billion Days banner',
        'background_color': '#FFE7DA',
        'metadata': {'tag': 'featured'},
      },
      {
        'id': 'hero-banner-2',
        'title': 'Mobiles on fire',
        'subtitle': 'Phones under ₹15,999',
        'description':
            'Cashback, exchange offers and quick delivery across India.',
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
        'alt_text': 'Mobile banner',
        'background_color': '#EAF1FF',
        'metadata': {'tag': 'phones'},
      },
      {
        'id': 'hero-banner-3',
        'title': 'Style alert',
        'subtitle': 'Fashion up to 70% off',
        'description':
            'Fresh picks for workwear, streetwear and occasion dressing.',
        'image_url': 'https://images.unsplash.com/photo-1521572267360-ee0c2909d518?auto=format&fit=crop&w=1200&q=80',
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
        'alt_text': 'Fashion banner',
        'background_color': '#FFF0F5',
        'metadata': {'tag': 'fashion'},
      },
    ];
  }

  List<Map<String, dynamic>> _fallbackCarouselBanners() {
    return _fallbackHeroBanners() +
        [
          {
            'id': 'carousel-banner-4',
            'title': 'Home refresh',
            'subtitle': 'Furniture, decor and more',
            'description': 'Upgrade your home with premium picks and smart storage solutions.',
            'image_url': 'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?auto=format&fit=crop&w=900&q=80',
            'deep_link': '/products?category=home',
            'target_url': '/products?category=home',
            'type': 'promo',
            'priority': 'regular',
            'position': 'lower',
            'cta_label': 'Explore home',
            'is_active': true,
            'active': true,
            'category_id': 'home',
            'campaign_id': 'campaign-home',
            'start_at': DateTime.now().toUtc().toIso8601String(),
            'end_at': DateTime.now()
                .add(const Duration(days: 15))
                .toUtc()
                .toIso8601String(),
            'order_index': 4,
            'alt_text': 'Home banner',
            'background_color': '#EDF8EE',
            'metadata': {'tag': 'home'},
          },
          {
            'id': 'carousel-banner-5',
            'title': 'Tech essentials',
            'subtitle': 'Access and audio deals',
            'description':
                'Smart accessories, chargers and travel gear at low prices.',
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
            'start_at': DateTime.now().toUtc().toIso8601String(),
            'end_at': DateTime.now()
                .add(const Duration(days: 20))
                .toUtc()
                .toIso8601String(),
            'order_index': 5,
            'alt_text': 'Electronics banner',
            'background_color': '#EEF3FF',
            'metadata': {'tag': 'tech'},
          },
        ];
  }

  List<Map<String, dynamic>> _fallbackCategoryBanners() {
    return [
      {
        'id': 'cat-banner-1',
        'title': 'Mobiles',
        'subtitle': 'Best sellers under ₹20k',
        'description': 'Top rated smartphones and accessories',
        'image_url': 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?auto=format&fit=crop&w=900&q=80',
        'deep_link': '/products?category=mobiles',
        'target_url': '/products?category=mobiles',
        'type': 'category',
        'priority': 'regular',
        'position': 'category',
        'cta_label': 'Shop mobiles',
        'is_active': true,
        'active': true,
        'category_id': 'mobiles',
        'campaign_id': 'campaign-mobiles',
        'start_at': DateTime.now().toUtc().toIso8601String(),
        'end_at': DateTime.now()
            .add(const Duration(days: 30))
            .toUtc()
            .toIso8601String(),
        'order_index': 1,
        'alt_text': 'Mobiles category banner',
        'background_color': '#EEF3FF',
      },
      {
        'id': 'cat-banner-2',
        'title': 'Fashion',
        'subtitle': 'Fashion picks for every mood',
        'description':
            'Explore everyday style, occasion looks and footwear deals.',
        'image_url': 'https://images.unsplash.com/photo-1521572267360-ee0c2909d518?auto=format&fit=crop&w=900&q=80',
        'deep_link': '/search?q=fashion',
        'target_url': '/search?q=fashion',
        'type': 'category',
        'priority': 'regular',
        'position': 'category',
        'cta_label': 'See fashion',
        'is_active': true,
        'active': true,
        'category_id': 'fashion',
        'campaign_id': 'campaign-fashion',
        'start_at': DateTime.now().toUtc().toIso8601String(),
        'end_at': DateTime.now()
            .add(const Duration(days: 25))
            .toUtc()
            .toIso8601String(),
        'order_index': 2,
        'alt_text': 'Fashion category banner',
        'background_color': '#FFF0F4',
      },
    ];
  }
}
