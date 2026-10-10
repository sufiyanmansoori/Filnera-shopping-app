import 'home_local_datasource_impl.dart';

/// Coordinates persistent home caching, revalidation, and offline fallback.
class HomeCacheDataSource extends HomeLocalDataSourceImpl {
  HomeCacheDataSource({super.sharedPreferences, super.cacheKey, super.maxAge});

  Future<HomeCacheResult> getOrFetchHomePayload({
    required Future<Map<String, dynamic>> Function() fetchRemote,
    bool forceRefresh = false,
    bool allowStaleOnError = true,
  }) async {
    final cachedPayload = await loadHomePayload();

    if (!forceRefresh && cachedPayload != null && await hasFreshHomeCache()) {
      return HomeCacheResult(
        payload: cachedPayload,
        source: HomeCacheSource.freshCache,
      );
    }

    if (!forceRefresh) {
      final pending = _inFlightRefresh;
      if (pending != null) return pending;
    }

    final request = fetchRemote();
    if (!forceRefresh) _inFlightRefresh = _saveRemotePayload(request);

    try {
      final result = forceRefresh
          ? await _saveRemotePayload(request)
          : await _inFlightRefresh!;
      return result;
    } catch (_) {
      if (allowStaleOnError && cachedPayload != null) {
        return HomeCacheResult(
          payload: cachedPayload,
          source: HomeCacheSource.staleCache,
        );
      }
      rethrow;
    } finally {
      if (!forceRefresh) _inFlightRefresh = null;
    }
  }

  Future<HomeCacheResult>? _inFlightRefresh;

  Future<HomeCacheResult> _saveRemotePayload(
    Future<Map<String, dynamic>> request,
  ) async {
    final payload = await request;
    await saveHomePayload(payload);
    return HomeCacheResult(payload: payload, source: HomeCacheSource.remote);
  }
}

enum HomeCacheSource { freshCache, remote, staleCache }

class HomeCacheResult {
  const HomeCacheResult({required this.payload, required this.source});

  final Map<String, dynamic> payload;
  final HomeCacheSource source;

  bool get isFromCache => source != HomeCacheSource.remote;
  bool get isStale => source == HomeCacheSource.staleCache;
}
