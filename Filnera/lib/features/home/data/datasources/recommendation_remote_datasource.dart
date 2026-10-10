import '../../../../core/network/api_client.dart';
import '../../domain/entities/recommendation_entity.dart';
import '../models/recommendation_model.dart';

/// Loads personalized product recommendations from the storefront API.
///
/// Recommendations remain usable when the API is unavailable: callers receive
/// a deterministic local catalog that can be rendered by the same product cards.
class RecommendationRemoteDataSource {
  RecommendationRemoteDataSource({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<RecommendationEntity>> fetchRecommendations({
    int page = 1,
    int pageSize = 10,
    bool forceRefresh = false,
    String? locale,
    String? currency,
    String? country,
    String? deviceType,
    String? userId,
    List<String> recentlyViewed = const <String>[],
    List<String> favoriteCategories = const <String>[],
  }) async {
    final safePage = page < 1 ? 1 : page;
    final safePageSize = pageSize.clamp(1, 50);
    final queryParameters = <String, dynamic>{
      'page': safePage,
      'page_size': safePageSize,
      'limit': safePageSize,
      'locale': locale ?? 'en_IN',
      'currency': currency ?? 'INR',
      'country': country ?? 'IN',
      'device_type': deviceType ?? 'web',
      'force_refresh': forceRefresh,
      if (userId != null && userId.trim().isNotEmpty) 'user_id': userId.trim(),
      if (recentlyViewed.isNotEmpty)
        'recently_viewed': recentlyViewed.take(20).join(','),
      if (favoriteCategories.isNotEmpty)
        'favorite_categories': favoriteCategories.take(20).join(','),
    };

    try {
      final response = await _apiClient.get(
        '/home/recommendations',
        queryParameters: queryParameters,
      );
      final recommendations = _parseRecommendations(response.data);
      if (recommendations.isNotEmpty) {
        return recommendations;
      }
    } catch (_) {
      // Try the shared recommendations API before switching to offline data.
    }

    try {
      final response = await _apiClient.get(
        '/recommendations',
        queryParameters: queryParameters,
      );
      final recommendations = _parseRecommendations(response.data);
      if (recommendations.isNotEmpty) {
        return recommendations;
      }
    } catch (_) {
      // The local catalog below keeps the homepage usable while offline.
    }

    return _fallbackRecommendations(
      page: safePage,
      pageSize: safePageSize,
      recentlyViewed: recentlyViewed,
      favoriteCategories: favoriteCategories,
    );
  }

  Future<List<RecommendationEntity>> fetchSimilarProducts({
    required String productId,
    int limit = 10,
    String? userId,
    String? locale,
    String? currency,
  }) async {
    final id = productId.trim();
    if (id.isEmpty) {
      throw const FormatException('Product id cannot be empty');
    }

    final queryParameters = <String, dynamic>{
      'product_id': id,
      'limit': limit.clamp(1, 50),
      'locale': locale ?? 'en_IN',
      'currency': currency ?? 'INR',
      if (userId != null && userId.trim().isNotEmpty) 'user_id': userId.trim(),
    };

    try {
      final response = await _apiClient.get(
        '/products/$id/similar',
        queryParameters: queryParameters,
      );
      final recommendations = _parseRecommendations(response.data);
      if (recommendations.isNotEmpty) {
        return recommendations.take(limit).toList();
      }
    } catch (_) {
      // Fall through to recommendations relevant to the selected product.
    }

    return _fallbackRecommendations(
      page: 1,
      pageSize: limit,
    ).where((item) => item.productId != id).take(limit).toList();
  }

  Future<List<RecommendationEntity>> fetchCategoryRecommendations({
    required String categoryId,
    int page = 1,
    int pageSize = 10,
    String? userId,
    String? locale,
    String? currency,
  }) async {
    final id = categoryId.trim();
    if (id.isEmpty) {
      throw const FormatException('Category id cannot be empty');
    }

    final queryParameters = <String, dynamic>{
      'category_id': id,
      'page': page < 1 ? 1 : page,
      'page_size': pageSize.clamp(1, 50),
      'locale': locale ?? 'en_IN',
      'currency': currency ?? 'INR',
      if (userId != null && userId.trim().isNotEmpty) 'user_id': userId.trim(),
    };

    try {
      final response = await _apiClient.get(
        '/categories/$id/recommendations',
        queryParameters: queryParameters,
      );
      final recommendations = _parseRecommendations(response.data);
      if (recommendations.isNotEmpty) {
        return recommendations;
      }
    } catch (_) {
      // Use the category-filtered offline catalog if the endpoint is unavailable.
    }

    return _fallbackRecommendations(
      page: page,
      pageSize: pageSize,
      favoriteCategories: <String>[id],
    );
  }

  Future<void> trackRecommendationInteraction({
    required String recommendationId,
    required String productId,
    required String action,
    String? userId,
    String? source,
    int? position,
  }) async {
    final normalizedAction = action.trim().toLowerCase();
    if (recommendationId.trim().isEmpty || productId.trim().isEmpty) {
      throw const FormatException(
        'Recommendation and product ids are required',
      );
    }
    if (!const <String>{
      'impression',
      'click',
      'add_to_cart',
      'purchase',
      'dismiss',
    }.contains(normalizedAction)) {
      throw const FormatException('Unsupported recommendation action');
    }

    try {
      await _apiClient.post(
        '/analytics/recommendations/interactions',
        data: {
          'recommendation_id': recommendationId.trim(),
          'product_id': productId.trim(),
          'action': normalizedAction,
          if (userId != null && userId.trim().isNotEmpty)
            'user_id': userId.trim(),
          if (source != null && source.trim().isNotEmpty)
            'source': source.trim(),
          if (position != null && position >= 0) 'position': position,
          'occurred_at': DateTime.now().toUtc().toIso8601String(),
        },
      );
    } catch (_) {
      // Analytics must never block navigation, cart actions, or checkout.
    }
  }

  List<RecommendationEntity> _parseRecommendations(dynamic payload) {
    final values = _extractItems(payload);
    final recommendations = <RecommendationEntity>[];
    for (final value in values) {
      if (value is! Map) continue;
      final recommendation = _toEntity(Map<String, dynamic>.from(value));
      if (recommendation != null) {
        recommendations.add(recommendation);
      }
    }
    return recommendations;
  }

  List<dynamic> _extractItems(dynamic payload) {
    if (payload is List) return payload;
    if (payload is! Map) return const <dynamic>[];

    final map = Map<String, dynamic>.from(payload);
    for (final key in const <String>[
      'items',
      'recommendations',
      'products',
      'results',
      'data',
      'content',
    ]) {
      final value = map[key];
      if (value is List) return value;
      if (value is Map) {
        final nested = _extractItems(value);
        if (nested.isNotEmpty) return nested;
      }
    }
    return const <dynamic>[];
  }

  RecommendationEntity? _toEntity(Map<String, dynamic> json) {
    final recommendation = RecommendationModel.fromJson(json);
    return recommendation.hasIdentity ? recommendation.toEntity() : null;
  }

  List<RecommendationEntity> _fallbackRecommendations({
    required int page,
    required int pageSize,
    List<String> recentlyViewed = const <String>[],
    List<String> favoriteCategories = const <String>[],
  }) {
    final recentIds = recentlyViewed.toSet();
    final preferredCategories = favoriteCategories
        .map((category) => category.toLowerCase())
        .toSet();
    final catalog = <RecommendationEntity>[
      const RecommendationEntity(
        id: 'rec-earbuds-001',
        productId: 'P-101',
        title: 'Noise Buds X Wireless Earbuds',
        imageUrl: 'https://images.unsplash.com/photo-1546435770-a3e426bf472b?auto=format&fit=crop&w=800&q=80',
        price: 2199,
        compareAtPrice: 3999,
        reason: 'Popular in electronics',
        score: 0.96,
        brand: 'Noise',
        categoryId: 'electronics',
      ),
      const RecommendationEntity(
        id: 'rec-watch-002',
        productId: 'P-102',
        title: 'Amazfit Active Smart Watch',
        imageUrl: 'https://images.unsplash.com/photo-1546868871-7041f2a55e12?auto=format&fit=crop&w=800&q=80',
        price: 4999,
        compareAtPrice: 7999,
        reason: 'Trending this week',
        score: 0.93,
        brand: 'Amazfit',
        categoryId: 'electronics',
      ),
      const RecommendationEntity(
        id: 'rec-shirt-003',
        productId: 'P-103',
        title: 'Classic Cotton Casual Shirt',
        imageUrl: 'https://images.unsplash.com/photo-1521572267360-ee0c2909d518?auto=format&fit=crop&w=800&q=80',
        price: 1299,
        compareAtPrice: 2499,
        reason: 'Picked for everyday style',
        score: 0.91,
        brand: 'Urban Thread',
        categoryId: 'fashion',
      ),
      const RecommendationEntity(
        id: 'rec-blender-004',
        productId: 'P-104',
        title: 'NutriBlend Go Portable Blender',
        imageUrl: 'https://images.unsplash.com/photo-1559056199-641a0ac8b55e?auto=format&fit=crop&w=800&q=80',
        price: 1999,
        compareAtPrice: 3499,
        reason: 'A great fit for your home',
        score: 0.89,
        brand: 'NutriBlend',
        categoryId: 'home',
      ),
      const RecommendationEntity(
        id: 'rec-sneakers-005',
        productId: 'P-106',
        title: 'Lightweight Running Sneakers',
        imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=800&q=80',
        price: 3899,
        compareAtPrice: 6999,
        reason: 'Highly rated by shoppers',
        score: 0.88,
        brand: 'Sportizon',
        categoryId: 'fashion',
      ),
      const RecommendationEntity(
        id: 'rec-phone-006',
        productId: 'P-107',
        title: 'Everyday Android Smartphone',
        imageUrl: 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?auto=format&fit=crop&w=800&q=80',
        price: 14999,
        compareAtPrice: 18999,
        reason: 'Best value in mobiles',
        score: 0.86,
        brand: 'MobiOne',
        categoryId: 'mobiles',
      ),
      const RecommendationEntity(
        id: 'rec-chair-007',
        productId: 'P-108',
        title: 'Ergonomic Work From Home Chair',
        imageUrl: 'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?auto=format&fit=crop&w=800&q=80',
        price: 6499,
        compareAtPrice: 9999,
        reason: 'Upgrade your workspace',
        score: 0.84,
        brand: 'Home Lane',
        categoryId: 'home',
      ),
      const RecommendationEntity(
        id: 'rec-skin-008',
        productId: 'P-109',
        title: 'Daily Hydration Skincare Set',
        imageUrl: 'https://images.unsplash.com/photo-1608248543803-ba4f8c70ae0b?auto=format&fit=crop&w=800&q=80',
        price: 899,
        compareAtPrice: 1499,
        reason: 'Loved by beauty shoppers',
        score: 0.82,
        brand: 'Glow Daily',
        categoryId: 'beauty',
      ),
    ];

    catalog.sort((a, b) {
      final aRecent = recentIds.contains(a.productId) ? 1 : 0;
      final bRecent = recentIds.contains(b.productId) ? 1 : 0;
      if (aRecent != bRecent) return bRecent.compareTo(aRecent);
      final aPreferred =
          preferredCategories.contains(a.categoryId?.toLowerCase()) ? 1 : 0;
      final bPreferred =
          preferredCategories.contains(b.categoryId?.toLowerCase()) ? 1 : 0;
      if (aPreferred != bPreferred) return bPreferred.compareTo(aPreferred);
      return b.score.compareTo(a.score);
    });

    final start = ((page < 1 ? 1 : page) - 1) * pageSize;
    if (start >= catalog.length) return const <RecommendationEntity>[];
    final end = (start + pageSize).clamp(0, catalog.length);
    return catalog.sublist(start, end);
  }
}
