import 'dart:convert';

import '../../domain/entities/deal_entity.dart';
import '../datasources/deal_remote_datasource.dart';
import '../models/deal_response_model.dart';
import 'deal_repository.dart';

const int _defaultDealCacheEntries = 60;
const int _maximumDealPageSize = 50;
const int _maximumDealLimit = 100;

/// Loads and normalizes deals from the remote data source.
///
/// Results are filtered for validity and availability, de-duplicated,
/// deterministically sorted, and cached using bounded LRU/TTL semantics.
/// In-flight requests with identical parameters are shared to avoid duplicate
/// network work during parallel home-page loading.
class DealRepositoryImpl implements DealRepository {
  DealRepositoryImpl({
    DealRemoteDataSource? remoteDataSource,
    Duration cacheDuration = const Duration(minutes: 3),
    int maximumCacheEntries = _defaultDealCacheEntries,
    DateTime Function()? clock,
  }) : _remoteDataSource = remoteDataSource ?? DealRemoteDataSource(),
       _cacheDuration = cacheDuration.isNegative
           ? Duration.zero
           : cacheDuration,
       _maximumCacheEntries = maximumCacheEntries < 1 ? 1 : maximumCacheEntries,
       _clock = clock ?? DateTime.now;

  final DealRemoteDataSource _remoteDataSource;
  final Duration _cacheDuration;
  final int _maximumCacheEntries;
  final DateTime Function() _clock;
  final Map<String, _DealCacheEntry> _cache = <String, _DealCacheEntry>{};
  final Map<String, Future<Object>> _inFlight = <String, Future<Object>>{};

  @override
  Future<List<DealEntity>> getDeals({
    int page = 1,
    int pageSize = 10,
    bool forceRefresh = false,
    String? locale,
    String? currency,
    String? country,
    String? deviceType,
    bool includeExpired = false,
  }) async {
    final safePage = page < 1 ? 1 : page;
    final safePageSize = pageSize.clamp(1, _maximumDealPageSize);
    final key = _cacheKey(<Object?>[
      'all',
      safePage,
      safePageSize,
      _normalized(locale),
      _normalized(currency),
      _normalized(country),
      _normalized(deviceType),
      includeExpired,
    ]);
    final deals = await _loadList(
      key: key,
      forceRefresh: forceRefresh,
      fetch: () => _remoteDataSource.fetchDeals(
        activeOnly: !includeExpired,
        page: safePage,
        pageSize: safePageSize,
        limit: safePageSize,
        locale: _normalized(locale),
        currency: _normalized(currency),
        country: _normalized(country),
        deviceType: _normalized(deviceType),
      ),
      includeExpired: includeExpired,
    );
    return _toEntities(deals);
  }

  @override
  Future<List<DealEntity>> getFlashDeals({
    int limit = 8,
    String? categoryId,
    bool forceRefresh = false,
  }) async {
    final safeLimit = _safeLimit(limit);
    final category = _normalized(categoryId);
    final key = _cacheKey(<Object?>['flash', category, safeLimit]);
    final deals = await _loadList(
      key: key,
      forceRefresh: forceRefresh,
      fetch: () => _remoteDataSource.fetchFlashDeals(
        limit: safeLimit,
        categoryId: category,
      ),
    );
    return _toEntities(deals.take(safeLimit).toList(growable: false));
  }

  @override
  Future<List<DealEntity>> getFeaturedDeals({
    int limit = 6,
    String? categoryId,
    bool forceRefresh = false,
  }) async {
    final safeLimit = _safeLimit(limit);
    final category = _normalized(categoryId);
    final key = _cacheKey(<Object?>['featured', category, safeLimit]);
    final deals = await _loadList(
      key: key,
      forceRefresh: forceRefresh,
      fetch: () => _remoteDataSource.fetchDeals(
        categoryId: category,
        activeOnly: true,
        limit: _maximumDealLimit,
        sortBy: 'discount',
      ),
    );
    final featured = deals.toList(growable: false)
      ..sort((left, right) {
        final discount = right.discountPercent.compareTo(left.discountPercent);
        return discount != 0 ? discount : left.id.compareTo(right.id);
      });
    return _toEntities(featured.take(safeLimit).toList(growable: false));
  }

  @override
  Future<List<DealEntity>> getTrendingDeals({
    int limit = 8,
    String? categoryId,
    bool forceRefresh = false,
  }) async {
    final safeLimit = _safeLimit(limit);
    final category = _normalized(categoryId);
    final key = _cacheKey(<Object?>['trending', category, safeLimit]);
    final deals = await _loadList(
      key: key,
      forceRefresh: forceRefresh,
      fetch: () => _remoteDataSource.fetchDeals(
        categoryId: category,
        activeOnly: true,
        limit: _maximumDealLimit,
        sortBy: 'sales',
      ),
    );
    final trending = deals.toList(growable: false)
      ..sort((left, right) {
        final sold = right.soldCount.compareTo(left.soldCount);
        return sold != 0 ? sold : left.id.compareTo(right.id);
      });
    return _toEntities(trending.take(safeLimit).toList(growable: false));
  }

  @override
  Future<List<DealEntity>> getDealsByCategory({
    required String categoryId,
    int limit = 10,
    bool forceRefresh = false,
  }) async {
    final category = categoryId.trim();
    if (category.isEmpty) {
      throw const FormatException('Category id cannot be empty');
    }
    final safeLimit = _safeLimit(limit);
    final key = _cacheKey(<Object?>['category', category, safeLimit]);
    final deals = await _loadList(
      key: key,
      forceRefresh: forceRefresh,
      fetch: () => _remoteDataSource.fetchCategoryDeals(
        categoryId: category,
        limit: safeLimit,
      ),
    );
    final matching = deals
        .where(
          (deal) =>
              deal.deal.categoryId == null ||
              deal.deal.categoryId!.toLowerCase() == category.toLowerCase(),
        )
        .take(safeLimit)
        .toList(growable: false);
    return _toEntities(matching);
  }

  @override
  Future<List<DealEntity>> searchDeals({
    required String query,
    int limit = 12,
    String? categoryId,
    bool forceRefresh = false,
  }) async {
    final searchText = query.trim();
    if (searchText.isEmpty) {
      throw const FormatException('Deal search query cannot be empty');
    }
    final safeLimit = _safeLimit(limit);
    final category = _normalized(categoryId);
    final key = _cacheKey(<Object?>[
      'search',
      searchText.toLowerCase(),
      category,
      safeLimit,
    ]);
    final deals = await _loadList(
      key: key,
      forceRefresh: forceRefresh,
      fetch: () => _remoteDataSource.searchDeals(
        query: searchText,
        limit: safeLimit,
        categoryId: category,
      ),
    );
    return _toEntities(deals.take(safeLimit).toList(growable: false));
  }

  @override
  Future<DealEntity> getDealById(
    String dealId, {
    bool forceRefresh = false,
  }) async {
    final id = dealId.trim();
    if (id.isEmpty) {
      throw const FormatException('Deal id cannot be empty');
    }
    final key = _cacheKey(<Object?>['detail', id]);
    final model = await _loadSingle(
      key: key,
      forceRefresh: forceRefresh,
      fetch: () async {
        final model = DealItemModel.fromJson(
          await _remoteDataSource.fetchDealById(id),
        );
        if (model.id != id) {
          throw StateError(
            'Deal endpoint returned no matching deal for "$id".',
          );
        }
        return model;
      },
    );
    if (!model.hasContent || model.id != id) {
      throw StateError('Deal endpoint returned no matching deal for "$id".');
    }
    if (!model.isLiveAt(_clock())) {
      throw StateError('Deal "$id" is not active at the current time.');
    }
    return model.deal.toEntity();
  }

  @override
  void clearCache({String? categoryId}) {
    final category = _normalized(categoryId);
    if (category == null) {
      _cache.clear();
      return;
    }
    _cache.removeWhere((key, _) => _decodeCacheKey(key).contains(category));
  }

  Future<List<DealItemModel>> _loadList({
    required String key,
    required bool forceRefresh,
    required Future<List<Map<String, dynamic>>> Function() fetch,
    bool includeExpired = false,
  }) async {
    if (!forceRefresh) {
      final cached = _readCached<List<DealItemModel>>(key);
      if (cached != null) return List<DealItemModel>.of(cached);

      final pending = _inFlight[key];
      if (pending != null) {
        final result = await pending;
        if (result is List<DealItemModel>) {
          return List<DealItemModel>.of(result);
        }
      }
    }

    final request = _fetchAndNormalize(fetch, includeExpired: includeExpired);
    if (!forceRefresh) _inFlight[key] = request;
    try {
      final result = await request;
      if (!forceRefresh) _writeCache(key, result);
      return List<DealItemModel>.of(result);
    } finally {
      if (!forceRefresh) _inFlight.remove(key);
    }
  }

  Future<List<DealItemModel>> _fetchAndNormalize(
    Future<List<Map<String, dynamic>>> Function() fetch, {
    bool includeExpired = false,
  }) async {
    final response = await fetch();
    final now = _clock();
    final unique = <String, DealItemModel>{};

    for (final json in response) {
      final deal = DealItemModel.fromJson(json);
      if (!deal.hasContent || (!includeExpired && !deal.isLiveAt(now))) {
        continue;
      }
      unique.putIfAbsent(deal.id, () => deal);
    }

    final normalized = unique.values.toList(growable: false)
      ..sort(_compareModels);
    return List<DealItemModel>.unmodifiable(normalized);
  }

  Future<DealItemModel> _loadSingle({
    required String key,
    required bool forceRefresh,
    required Future<DealItemModel> Function() fetch,
  }) async {
    if (!forceRefresh) {
      final cached = _readCached<DealItemModel>(key);
      if (cached != null) return cached;

      final pending = _inFlight[key];
      if (pending != null) {
        final result = await pending;
        if (result is DealItemModel) return result;
      }
    }

    final request = fetch();
    if (!forceRefresh) _inFlight[key] = request;
    try {
      final result = await request;
      if (!result.hasContent) {
        throw StateError(
          'Deal endpoint returned an empty response for "$key".',
        );
      }
      if (!forceRefresh) _writeCache(key, result);
      return result;
    } finally {
      if (!forceRefresh) _inFlight.remove(key);
    }
  }

  T? _readCached<T>(String key) {
    final entry = _cache.remove(key);
    if (entry == null || !_clock().isBefore(entry.expiresAt)) return null;
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
    _cache[key] = _DealCacheEntry(
      value: value,
      expiresAt: _clock().add(_cacheDuration),
    );
  }

  List<DealEntity> _toEntities(Iterable<DealItemModel> deals) =>
      List<DealEntity>.unmodifiable(deals.map((deal) => deal.deal.toEntity()));

  static int _compareModels(DealItemModel left, DealItemModel right) {
    final endTime = _compareDates(left.deal.endAt, right.deal.endAt);
    if (endTime != 0) return endTime;
    return left.id.compareTo(right.id);
  }

  static int _compareDates(DateTime? left, DateTime? right) {
    if (left == null && right == null) return 0;
    if (left == null) return 1;
    if (right == null) return -1;
    return left.compareTo(right);
  }

  static int _safeLimit(int limit) => limit.clamp(1, _maximumDealLimit);

  static String? _normalized(String? value) {
    final text = value?.trim();
    return text == null || text.isEmpty ? null : text;
  }

  static String _cacheKey(List<Object?> parts) => jsonEncode(parts);

  static List<String> _decodeCacheKey(String key) {
    final decoded = jsonDecode(key);
    if (decoded is! List) return const <String>[];
    return decoded.map((value) => value?.toString() ?? '').toList();
  }
}

class _DealCacheEntry {
  const _DealCacheEntry({required this.value, required this.expiresAt});

  final Object value;
  final DateTime expiresAt;
}
