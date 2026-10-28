import '../../domain/entities/home_data_entity.dart';
import '../../domain/usecases/cache_home_data_usecase.dart';
import '../datasources/home_cache_datasource.dart';
import '../models/home_data_model.dart';

/// Repository for serializing and retrieving the persistent home-page cache.
///
/// The datasource owns storage and cache expiration. This repository converts
/// between the cache payload and domain entities and exposes cache freshness
/// without leaking storage details to presentation code.
class HomeCacheRepositoryImpl implements HomeCacheRepository {
  HomeCacheRepositoryImpl({HomeCacheDataSource? cacheDataSource})
    : _cacheDataSource = cacheDataSource ?? HomeCacheDataSource();

  final HomeCacheDataSource _cacheDataSource;

  @override
  Future<void> cacheHomeData({
    required HomeDataEntity data,
    String? userId,
    String? locale,
    String? currency,
    String? country,
    String? deviceType,
  }) async {
    final payload = HomeDataModel.fromEntity(data).toJson();
    payload['cache_context'] = _buildContext(
      userId: userId,
      locale: locale,
      currency: currency,
      country: country,
      deviceType: deviceType,
    );
    await _cacheDataSource.saveHomePayload(payload);
  }

  /// Returns cached home content, or `null` when there is no valid payload.
  ///
  /// When a request context is provided, data cached for a different
  /// personalized user or market is not exposed.
  Future<HomeDataEntity?> getCachedHomeData({
    String? userId,
    String? locale,
    String? currency,
    String? country,
    String? deviceType,
    bool requireFresh = false,
  }) async {
    if (requireFresh && !await _cacheDataSource.hasFreshHomeCache()) {
      return null;
    }

    final payload = await _cacheDataSource.loadHomePayload();
    if (payload == null ||
        !_matchesContext(
          payload,
          _buildContext(
            userId: userId,
            locale: locale,
            currency: currency,
            country: country,
            deviceType: deviceType,
          ),
        )) {
      return null;
    }

    return HomeDataModel.fromJson(payload).toEntity();
  }

  /// Serves fresh cached data when available, otherwise fetches and stores it.
  ///
  /// On a remote failure, the datasource can return a stale cached snapshot
  /// when [allowStaleOnError] is enabled; failures are otherwise propagated.
  Future<HomeCacheRepositoryResult> getOrFetchHomeData({
    required Future<HomeDataEntity> Function() fetchRemote,
    bool forceRefresh = false,
    bool allowStaleOnError = true,
    String? userId,
    String? locale,
    String? currency,
    String? country,
    String? deviceType,
  }) async {
    final result = await _cacheDataSource.getOrFetchHomePayload(
      forceRefresh: forceRefresh,
      allowStaleOnError: allowStaleOnError,
      fetchRemote: () async {
        final data = await fetchRemote();
        final payload = HomeDataModel.fromEntity(data).toJson();
        payload['cache_context'] = _buildContext(
          userId: userId,
          locale: locale,
          currency: currency,
          country: country,
          deviceType: deviceType,
        );
        return payload;
      },
    );
    final payloadContext = _contextMap(result.payload['cache_context']);
    if (!_matchesContext(
      result.payload,
      _buildContext(
        userId: userId,
        locale: locale,
        currency: currency,
        country: country,
        deviceType: deviceType,
      ),
    )) {
      if (result.source != HomeCacheSource.remote) {
        return getOrFetchHomeData(
          fetchRemote: fetchRemote,
          forceRefresh: true,
          allowStaleOnError: false,
          userId: userId,
          locale: locale,
          currency: currency,
          country: country,
          deviceType: deviceType,
        );
      }
    }

    return HomeCacheRepositoryResult(
      data: HomeDataModel.fromJson(result.payload).toEntity(),
      source: result.source,
      context: payloadContext,
    );
  }

  /// Clears the persisted home payload and all related cached sections.
  Future<void> clearCache() => _cacheDataSource.clearHomePayload();

  Future<bool> hasFreshCache() => _cacheDataSource.hasFreshHomeCache();

  static Map<String, String> _buildContext({
    String? userId,
    String? locale,
    String? currency,
    String? country,
    String? deviceType,
  }) => <String, String>{
    ...?_contextEntry('user_id', userId),
    ...?_contextEntry('locale', locale),
    ...?_contextEntry('currency', currency),
    ...?_contextEntry('country', country),
    ...?_contextEntry('device_type', deviceType),
  };

  static Map<String, String>? _contextEntry(String key, String? value) {
    final normalized = _normalize(value);
    return normalized == null ? null : <String, String>{key: normalized};
  }

  static bool _matchesContext(
    Map<String, dynamic> payload,
    Map<String, String> requestedContext,
  ) {
    final cachedContext = _asMap(payload['cache_context']);
    final cachedUserId = cachedContext['user_id']?.toString();
    if (cachedUserId != requestedContext['user_id']) return false;

    for (final entry in requestedContext.entries) {
      final cachedValue = cachedContext[entry.key]?.toString();
      if (cachedValue != null && cachedValue != entry.value) return false;
    }
    return true;
  }

  static Map<String, String> _contextMap(dynamic value) {
    final map = _asMap(value);
    return Map<String, String>.unmodifiable(
      map.map((key, value) => MapEntry(key, value.toString())),
    );
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is! Map) return const <String, dynamic>{};
    return value.map((key, value) => MapEntry(key.toString(), value));
  }

  static String? _normalize(String? value) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }
}

enum HomeCacheRepositorySource { freshCache, remote, staleCache }

/// A home snapshot and the source from which the repository served it.
class HomeCacheRepositoryResult {
  HomeCacheRepositoryResult({
    required this.data,
    required HomeCacheSource source,
    Map<String, String> context = const <String, String>{},
  }) : source = switch (source) {
         HomeCacheSource.freshCache => HomeCacheRepositorySource.freshCache,
         HomeCacheSource.remote => HomeCacheRepositorySource.remote,
         HomeCacheSource.staleCache => HomeCacheRepositorySource.staleCache,
       },
       context = Map<String, String>.unmodifiable(context);

  final HomeDataEntity data;
  final HomeCacheRepositorySource source;
  final Map<String, String> context;

  bool get isFromCache => source != HomeCacheRepositorySource.remote;
  bool get isStale => source == HomeCacheRepositorySource.staleCache;
}
