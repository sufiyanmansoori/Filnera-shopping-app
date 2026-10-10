import 'home_cache_datasource.dart';
import 'home_local_datasource.dart';

/// Synchronizes the remote home payload with the local persistent cache.
class HomeSyncDataSource {
  Future<HomeSyncResult> syncHomePayload({
    required HomeLocalDataSource localDataSource,
    required Future<Map<String, dynamic>> Function() fetchRemote,
    bool forceRefresh = false,
    bool allowStaleOnError = true,
  }) async {
    if (localDataSource is HomeCacheDataSource) {
      final cacheResult = await localDataSource.getOrFetchHomePayload(
        fetchRemote: fetchRemote,
        forceRefresh: forceRefresh,
        allowStaleOnError: allowStaleOnError,
      );
      return HomeSyncResult(
        payload: cacheResult.payload,
        status: switch (cacheResult.source) {
          HomeCacheSource.remote => HomeSyncStatus.synced,
          HomeCacheSource.freshCache => HomeSyncStatus.freshCache,
          HomeCacheSource.staleCache => HomeSyncStatus.staleCache,
        },
        completedAt: DateTime.now().toUtc(),
      );
    }

    final cachedPayload = await localDataSource.loadHomePayload();
    if (!forceRefresh && cachedPayload != null) {
      return HomeSyncResult(
        payload: cachedPayload,
        status: HomeSyncStatus.freshCache,
        completedAt: DateTime.now().toUtc(),
      );
    }

    if (!forceRefresh) {
      final pending = _inFlightSync;
      if (pending != null) return pending;
      _inFlightSync = _fetchAndSave(
        localDataSource: localDataSource,
        fetchRemote: fetchRemote,
      );
    }

    try {
      return forceRefresh
          ? await _fetchAndSave(
              localDataSource: localDataSource,
              fetchRemote: fetchRemote,
            )
          : await _inFlightSync!;
    } catch (_) {
      if (allowStaleOnError && cachedPayload != null) {
        return HomeSyncResult(
          payload: cachedPayload,
          status: HomeSyncStatus.staleCache,
          completedAt: DateTime.now().toUtc(),
        );
      }
      rethrow;
    } finally {
      if (!forceRefresh) _inFlightSync = null;
    }
  }

  Future<HomeSyncResult>? _inFlightSync;

  Future<HomeSyncResult> _fetchAndSave({
    required HomeLocalDataSource localDataSource,
    required Future<Map<String, dynamic>> Function() fetchRemote,
  }) async {
    final payload = await fetchRemote();
    await localDataSource.saveHomePayload(payload);
    return HomeSyncResult(
      payload: payload,
      status: HomeSyncStatus.synced,
      completedAt: DateTime.now().toUtc(),
    );
  }
}

enum HomeSyncStatus { synced, freshCache, staleCache }

class HomeSyncResult {
  const HomeSyncResult({
    required this.payload,
    required this.status,
    required this.completedAt,
  });

  final Map<String, dynamic> payload;
  final HomeSyncStatus status;
  final DateTime completedAt;

  bool get isFromCache => status != HomeSyncStatus.synced;
  bool get isStale => status == HomeSyncStatus.staleCache;
}
