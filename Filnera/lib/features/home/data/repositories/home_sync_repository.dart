import '../../domain/entities/home_data_entity.dart';
import '../../domain/usecases/refresh_home_data_usecase.dart';
import '../datasources/home_cache_datasource.dart';
import '../datasources/home_local_datasource.dart';
import '../datasources/home_remote_datasource.dart';
import '../datasources/home_remote_datasource_impl.dart';
import '../datasources/home_sync_datasource.dart';
import '../models/home_data_model.dart';

/// Synchronizes remote home content with the persistent local snapshot.
///
/// This repository translates transport payloads into domain entities and
/// keeps cache-source metadata available to callers that need to distinguish
/// fresh, stale, and newly fetched content.
class HomeSyncRepositoryImpl implements HomeRefreshRepository {
  HomeSyncRepositoryImpl({
    HomeRemoteDataSource? remoteDataSource,
    HomeLocalDataSource? localDataSource,
    HomeSyncDataSource? syncDataSource,
  }) : _remoteDataSource = remoteDataSource ?? HomeRemoteDataSourceImpl(),
       _localDataSource = localDataSource ?? HomeCacheDataSource(),
       _syncDataSource = syncDataSource ?? HomeSyncDataSource();

  final HomeRemoteDataSource _remoteDataSource;
  final HomeLocalDataSource _localDataSource;
  final HomeSyncDataSource _syncDataSource;

  /// Fetches or reuses the home snapshot and reports how it was obtained.
  Future<HomeSyncRepositoryResult> syncHomeData({
    bool forceRefresh = false,
    bool allowStaleOnError = true,
  }) async {
    final result = await _syncDataSource.syncHomePayload(
      localDataSource: _localDataSource,
      fetchRemote: _remoteDataSource.getHomePayload,
      forceRefresh: forceRefresh,
      allowStaleOnError: allowStaleOnError,
    );
    final parsed = _parseHomePayload(result.payload);

    return HomeSyncRepositoryResult(
      data: parsed.data,
      status: result.status,
      completedAt: result.completedAt,
      requestId: parsed.requestId,
    );
  }

  /// Forces a remote refresh by default, matching [RefreshHomeDataUseCase].
  @override
  Future<HomeDataEntity> refreshHomeData({
    String? userId,
    String? locale,
    String? currency,
    String? country,
    String? deviceType,
    bool forceRefresh = true,
  }) async {
    final result = await syncHomeData(forceRefresh: forceRefresh);
    return result.data;
  }

  /// Removes the persisted snapshot so the next request must synchronize.
  Future<void> clearCache() => _localDataSource.clearHomePayload();

  static _ParsedHomePayload _parseHomePayload(Map<String, dynamic> payload) {
    final statusCode = _asInt(
      payload['status_code'] ?? payload['statusCode'] ?? payload['code'],
    );
    final errors = _errorMessages(payload['errors'] ?? payload['error']);
    final success = _asBool(
      payload['success'] ?? payload['ok'],
      fallback: errors.isEmpty && (statusCode == null || statusCode < 400),
    );
    if (!success || (statusCode != null && statusCode >= 400)) {
      final message = errors.isNotEmpty
          ? errors.join('; ')
          : _asText(payload['message'] ?? payload['detail']) ??
                'Home data synchronization failed';
      throw FormatException(message);
    }

    final rawData = payload['data'];
    final data = rawData is Map ? Map<String, dynamic>.from(rawData) : payload;
    return _ParsedHomePayload(
      data: HomeDataModel.fromJson(data).toEntity(),
      requestId: _asText(
        payload['request_id'] ?? payload['requestId'] ?? payload['trace_id'],
      ),
    );
  }

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  static bool _asBool(dynamic value, {required bool fallback}) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      switch (value.trim().toLowerCase()) {
        case 'true':
        case '1':
        case 'yes':
        case 'success':
          return true;
        case 'false':
        case '0':
        case 'no':
        case 'error':
        case 'failed':
          return false;
      }
    }
    return fallback;
  }

  static String? _asText(dynamic value) {
    if (value == null || value is Map || value is Iterable) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  static List<String> _errorMessages(dynamic value) {
    if (value == null) return const <String>[];
    if (value is String) {
      final message = value.trim();
      return message.isEmpty ? const <String>[] : <String>[message];
    }
    if (value is Iterable) {
      return value.expand(_errorMessages).toList(growable: false);
    }
    if (value is Map) {
      return value.entries
          .expand((entry) {
            final messages = _errorMessages(entry.value);
            if (entry.key == 'message' || entry.key == 'detail') {
              return messages;
            }
            return messages.map((message) => '${entry.key}: $message');
          })
          .toList(growable: false);
    }
    return const <String>[];
  }
}

class _ParsedHomePayload {
  const _ParsedHomePayload({required this.data, this.requestId});

  final HomeDataEntity data;
  final String? requestId;
}

/// Typed result from a home synchronization operation.
class HomeSyncRepositoryResult {
  const HomeSyncRepositoryResult({
    required this.data,
    required this.status,
    required this.completedAt,
    this.requestId,
  });

  final HomeDataEntity data;
  final HomeSyncStatus status;
  final DateTime completedAt;
  final String? requestId;

  bool get isFromCache => status != HomeSyncStatus.synced;
  bool get isStale => status == HomeSyncStatus.staleCache;
  bool get isFresh => status == HomeSyncStatus.freshCache;
}
