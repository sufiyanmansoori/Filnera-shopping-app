import 'dart:convert';

import '../../domain/entities/banner_entity.dart';
import '../datasources/banner_remote_datasource.dart';
import '../datasources/banner_remote_datasource_impl.dart';
import '../models/banner_response_model.dart';
import 'banner_repository.dart';

const int _defaultBannerCacheEntries = 40;
const int _maximumBannerPageSize = 50;

/// Repository for loading, normalizing, filtering, and caching storefront
/// banners.
///
/// The repository keeps API concerns behind [BannerRemoteDataSource], returns
/// immutable domain results, coalesces identical requests, and uses a bounded
/// time-to-live cache. Inject a datasource in tests or when configuring custom
/// networking; the default constructor uses the production remote datasource.
class BannerRepositoryImpl implements BannerRepository {
  BannerRepositoryImpl({
    BannerRemoteDataSource? remoteDataSource,
    Duration cacheDuration = const Duration(minutes: 5),
    int maximumCacheEntries = _defaultBannerCacheEntries,
    DateTime Function()? clock,
  }) : _remoteDataSource = remoteDataSource ?? BannerRemoteDataSourceImpl(),
       _cacheDuration = cacheDuration.isNegative
           ? Duration.zero
           : cacheDuration,
       _maximumCacheEntries = maximumCacheEntries < 1 ? 1 : maximumCacheEntries,
       _clock = clock ?? DateTime.now;

  final BannerRemoteDataSource _remoteDataSource;
  final Duration _cacheDuration;
  final int _maximumCacheEntries;
  final DateTime Function() _clock;
  final Map<String, _BannerCacheEntry> _cache = <String, _BannerCacheEntry>{};
  final Map<String, Future<Object>> _inFlight = <String, Future<Object>>{};

  @override
  Future<List<BannerEntity>> getBanners({
    int page = 1,
    int pageSize = 10,
    bool forceRefresh = false,
    String? locale,
    String? currency,
    String? country,
    String? deviceType,
  }) async {
    final safePage = page < 1 ? 1 : page;
    final safePageSize = pageSize.clamp(1, _maximumBannerPageSize);
    final key = _cacheKey(<Object?>[
      'list',
      safePage,
      safePageSize,
      _normalized(locale),
      _normalized(currency),
      _normalized(country),
      _normalized(deviceType),
    ]);

    final models = await _loadList(
      key: key,
      forceRefresh: forceRefresh,
      fetch: () => _remoteDataSource.fetchBanners(
        page: safePage,
        pageSize: safePageSize,
        activeOnly: true,
        limit: safePageSize,
        locale: _normalized(locale),
        currency: _normalized(currency),
        country: _normalized(country),
        deviceType: _normalized(deviceType),
      ),
    );
    return _toEntities(models);
  }

  @override
  Future<List<BannerEntity>> getHeroBanners({
    String? categoryId,
    int limit = 5,
    String? locale,
    String? country,
    bool forceRefresh = false,
  }) async {
    final safeLimit = _safeLimit(limit);
    final category = _normalized(categoryId);
    final key = _cacheKey(<Object?>[
      'hero',
      category,
      safeLimit,
      _normalized(locale),
      _normalized(country),
    ]);

    final models = await _loadList(
      key: key,
      forceRefresh: forceRefresh,
      fetch: () => _remoteDataSource.fetchHeroBanners(
        categoryId: category,
        limit: safeLimit,
        locale: _normalized(locale),
        country: _normalized(country),
      ),
    );
    return _toEntities(models);
  }

  @override
  Future<List<BannerEntity>> getPromotionalBanners({
    String? categoryId,
    int limit = 6,
    bool forceRefresh = false,
  }) async {
    final safeLimit = _safeLimit(limit);
    final category = _normalized(categoryId);
    final key = _cacheKey(<Object?>['promotions', category, safeLimit]);

    final models = await _loadList(
      key: key,
      forceRefresh: forceRefresh,
      fetch: () => _remoteDataSource.fetchPromotionalBanners(
        categoryId: category,
        limit: safeLimit,
      ),
    );
    return _toEntities(models);
  }

  @override
  Future<List<BannerEntity>> getBannersByCategory({
    required String categoryId,
    int limit = 8,
    bool forceRefresh = false,
  }) async {
    final category = categoryId.trim();
    if (category.isEmpty) {
      throw const FormatException('Category id cannot be empty');
    }
    final safeLimit = _safeLimit(limit);
    final key = _cacheKey(<Object?>['category', category, safeLimit]);

    final models = await _loadList(
      key: key,
      forceRefresh: forceRefresh,
      fetch: () => _remoteDataSource
          .fetchByCategory(category)
          .then((banners) => banners.take(safeLimit).toList(growable: false)),
    );
    return _toEntities(models);
  }

  @override
  Future<BannerItemModel> getBannerById(
    String bannerId, {
    bool forceRefresh = false,
  }) async {
    final id = bannerId.trim();
    if (id.isEmpty) {
      throw const FormatException('Banner id cannot be empty');
    }

    final key = _cacheKey(<Object?>['detail', id]);
    final model = await _loadSingle(
      key: key,
      forceRefresh: forceRefresh,
      fetch: () async =>
          BannerItemModel.fromJson(await _remoteDataSource.fetchBannerById(id)),
    );
    if (!model.hasContent || model.id.isEmpty) {
      throw StateError('Banner endpoint returned no usable banner for "$id".');
    }
    return model;
  }

  @override
  void clearCache({String? categoryId}) {
    final category = _normalized(categoryId);
    if (category == null) {
      _cache.clear();
      return;
    }

    _cache.removeWhere((key, _) {
      final components = _decodeCacheKey(key);
      return components.contains(category);
    });
  }

  Future<List<BannerItemModel>> _loadList({
    required String key,
    required bool forceRefresh,
    required Future<List<Map<String, dynamic>>> Function() fetch,
  }) async {
    if (!forceRefresh) {
      final cached = _readCached<List<BannerItemModel>>(key);
      if (cached != null) return List<BannerItemModel>.of(cached);

      final pending = _inFlight[key];
      if (pending != null) {
        final result = await pending;
        if (result is List<BannerItemModel>) {
          return List<BannerItemModel>.of(result);
        }
      }
    }

    final request = _fetchAndNormalize(fetch);
    if (!forceRefresh) _inFlight[key] = request;
    try {
      final result = await request;
      if (!forceRefresh) _writeCache(key, result);
      return List<BannerItemModel>.of(result);
    } finally {
      if (!forceRefresh) _inFlight.remove(key);
    }
  }

  Future<List<BannerItemModel>> _fetchAndNormalize(
    Future<List<Map<String, dynamic>>> Function() fetch,
  ) async {
    final response = await fetch();
    final now = _clock();
    final unique = <String, BannerItemModel>{};

    for (final json in response) {
      final banner = BannerItemModel.fromJson(json);
      if (banner.id.isEmpty || !banner.hasContent || !banner.isVisibleAt(now)) {
        continue;
      }
      unique.putIfAbsent(banner.id, () => banner);
    }

    final banners = unique.values.toList(growable: false)
      ..sort(_compareBanners);
    return List<BannerItemModel>.unmodifiable(banners);
  }

  Future<BannerItemModel> _loadSingle({
    required String key,
    required bool forceRefresh,
    required Future<BannerItemModel> Function() fetch,
  }) async {
    if (!forceRefresh) {
      final cached = _readCached<BannerItemModel>(key);
      if (cached != null) return cached;

      final pending = _inFlight[key];
      if (pending != null) {
        final result = await pending;
        if (result is BannerItemModel) return result;
      }
    }

    final request = fetch();
    if (!forceRefresh) _inFlight[key] = request;
    try {
      final result = await request;
      if (!result.isVisibleAt(_clock())) {
        throw StateError('Banner "$key" is not active at the current time.');
      }
      if (!forceRefresh) _writeCache(key, result);
      return result;
    } finally {
      if (!forceRefresh) _inFlight.remove(key);
    }
  }

  T? _readCached<T>(String key) {
    final entry = _cache.remove(key);
    if (entry == null) return null;
    if (!_clock().isBefore(entry.expiresAt)) return null;

    // Remove/reinsert implements LRU ordering with a small bounded map.
    _cache[key] = entry;
    final value = entry.value;
    if (value is T) return value as T;
    return null;
  }

  void _writeCache(String key, Object value) {
    _cache.remove(key);
    while (_cache.length >= _maximumCacheEntries) {
      _cache.remove(_cache.keys.first);
    }
    _cache[key] = _BannerCacheEntry(
      value: value,
      expiresAt: _clock().add(_cacheDuration),
    );
  }

  List<BannerEntity> _toEntities(List<BannerItemModel> models) =>
      List<BannerEntity>.unmodifiable(models.map((model) => model.toEntity()));

  static int _compareBanners(BannerItemModel left, BannerItemModel right) {
    final order = left.orderIndex.compareTo(right.orderIndex);
    if (order != 0) return order;
    final featured = (right.isFeatured ? 1 : 0).compareTo(
      left.isFeatured ? 1 : 0,
    );
    if (featured != 0) return featured;
    return left.id.compareTo(right.id);
  }

  static int _safeLimit(int limit) => limit.clamp(1, 100);

  static String? _normalized(String? value) {
    final text = value?.trim();
    return text == null || text.isEmpty ? null : text;
  }

  static String _cacheKey(List<Object?> parts) => jsonEncode(parts);

  static List<String> _decodeCacheKey(String key) {
    final decoded = jsonDecode(key);
    if (decoded is! List) return const <String>[];
    return decoded.map((part) => part?.toString() ?? '').toList();
  }
}

class _BannerCacheEntry {
  const _BannerCacheEntry({required this.value, required this.expiresAt});

  final Object value;
  final DateTime expiresAt;
}
