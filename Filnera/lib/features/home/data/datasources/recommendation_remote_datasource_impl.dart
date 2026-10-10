import 'dart:convert';

import '../../domain/entities/recommendation_entity.dart';
import 'recommendation_remote_datasource.dart';

/// Concrete recommendation datasource used by the home feature.
///
/// The parent class owns API parsing and offline fallback behavior. This class
/// adds bounded caching and request coalescing for repeated homepage requests.
class RecommendationRemoteDataSourceImpl
    extends RecommendationRemoteDataSource {
  RecommendationRemoteDataSourceImpl({
    super.apiClient,
    this._cacheDuration = const Duration(minutes: 5),
    int maximumCacheEntries = 40,
  }) : _maximumCacheEntries = maximumCacheEntries < 1 ? 1 : maximumCacheEntries;

  final Duration _cacheDuration;
  final int _maximumCacheEntries;
  final Map<String, _RecommendationCacheEntry> _cache = {};
  final Map<String, Future<List<RecommendationEntity>>> _inFlight = {};

  @override
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
    final normalizedPage = page < 1 ? 1 : page;
    final normalizedPageSize = pageSize.clamp(1, 50);
    final cacheKey = _buildCacheKey(
      page: normalizedPage,
      pageSize: normalizedPageSize,
      locale: locale,
      currency: currency,
      country: country,
      deviceType: deviceType,
      userId: userId,
      recentlyViewed: recentlyViewed,
      favoriteCategories: favoriteCategories,
    );

    if (!forceRefresh) {
      final cached = _readCached(cacheKey);
      if (cached != null) return cached;

      final pending = _inFlight[cacheKey];
      if (pending != null) {
        return List<RecommendationEntity>.of(await pending);
      }
    }

    final request = super.fetchRecommendations(
      page: normalizedPage,
      pageSize: normalizedPageSize,
      forceRefresh: forceRefresh,
      locale: locale,
      currency: currency,
      country: country,
      deviceType: deviceType,
      userId: userId,
      recentlyViewed: recentlyViewed,
      favoriteCategories: favoriteCategories,
    );

    if (!forceRefresh) _inFlight[cacheKey] = request;
    try {
      final recommendations = await request;
      if (!forceRefresh) _writeCached(cacheKey, recommendations);
      return List<RecommendationEntity>.of(recommendations);
    } finally {
      if (!forceRefresh) _inFlight.remove(cacheKey);
    }
  }

  /// Clears cached recommendation pages, for example after sign-out or a
  /// wishlist change that should immediately affect personalized results.
  void clearCache({String? userId}) {
    if (userId == null || userId.trim().isEmpty) {
      _cache.clear();
      return;
    }

    final userMarker = '"${userId.trim()}"';
    _cache.removeWhere((key, _) => key.contains(userMarker));
  }

  List<RecommendationEntity>? _readCached(String key) {
    final entry = _cache[key];
    if (entry == null) return null;
    if (DateTime.now().isAfter(entry.expiresAt)) {
      _cache.remove(key);
      return null;
    }
    return List<RecommendationEntity>.of(entry.items);
  }

  void _writeCached(String key, List<RecommendationEntity> items) {
    _cache.remove(key);
    while (_cache.length >= _maximumCacheEntries) {
      _cache.remove(_cache.keys.first);
    }
    _cache[key] = _RecommendationCacheEntry(
      items: List<RecommendationEntity>.unmodifiable(items),
      expiresAt: DateTime.now().add(_cacheDuration),
    );
  }

  String _buildCacheKey({
    required int page,
    required int pageSize,
    String? locale,
    String? currency,
    String? country,
    String? deviceType,
    String? userId,
    required List<String> recentlyViewed,
    required List<String> favoriteCategories,
  }) {
    return jsonEncode(<Object?>[
      page,
      pageSize,
      locale ?? 'en_IN',
      currency ?? 'INR',
      country ?? 'IN',
      deviceType ?? 'web',
      userId?.trim() ?? '',
      recentlyViewed,
      favoriteCategories,
    ]);
  }
}

class _RecommendationCacheEntry {
  const _RecommendationCacheEntry({
    required this.items,
    required this.expiresAt,
  });

  final List<RecommendationEntity> items;
  final DateTime expiresAt;
}
