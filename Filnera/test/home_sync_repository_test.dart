import 'package:filnera/features/home/data/datasources/home_local_datasource.dart';
import 'package:filnera/features/home/data/datasources/home_remote_datasource.dart';
import 'package:filnera/features/home/data/repositories/home_sync_repository.dart';
import 'package:filnera/features/home/data/datasources/home_sync_datasource.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HomeSyncRepositoryImpl', () {
    test(
      'fetches remote content, parses it, and persists the snapshot',
      () async {
        final local = _MemoryHomeLocalDataSource();
        final remote = _FakeHomeRemoteDataSource(_payload('Remote content'));
        final repository = HomeSyncRepositoryImpl(
          localDataSource: local,
          remoteDataSource: remote,
        );

        final result = await repository.syncHomeData();

        expect(result.data.personalizedSummary, 'Remote content');
        expect(result.status, HomeSyncStatus.synced);
        expect(result.isFromCache, isFalse);
        expect(result.completedAt.isUtc, isTrue);
        expect(remote.fetchCount, 1);
        expect(local.payload, isNotNull);
      },
    );

    test(
      'serves an existing local snapshot without a remote request',
      () async {
        final local = _MemoryHomeLocalDataSource()
          ..payload = _payload('Cached content');
        final remote = _FakeHomeRemoteDataSource(_payload('Remote content'));
        final repository = HomeSyncRepositoryImpl(
          localDataSource: local,
          remoteDataSource: remote,
        );

        final result = await repository.syncHomeData();

        expect(result.data.personalizedSummary, 'Cached content');
        expect(result.status, HomeSyncStatus.freshCache);
        expect(result.isFresh, isTrue);
        expect(remote.fetchCount, 0);
      },
    );

    test(
      'uses stale local content after remote failure when allowed',
      () async {
        final local = _MemoryHomeLocalDataSource()
          ..payload = _payload('Offline content');
        final repository = HomeSyncRepositoryImpl(
          localDataSource: local,
          remoteDataSource: _FakeHomeRemoteDataSource(
            _payload('Unused'),
            error: StateError('Offline'),
          ),
        );

        final result = await repository.syncHomeData(forceRefresh: true);

        expect(result.data.personalizedSummary, 'Offline content');
        expect(result.status, HomeSyncStatus.staleCache);
        expect(result.isStale, isTrue);
      },
    );

    test('propagates remote error when stale fallback is disabled', () async {
      final local = _MemoryHomeLocalDataSource()
        ..payload = _payload('Old content');
      final repository = HomeSyncRepositoryImpl(
        localDataSource: local,
        remoteDataSource: _FakeHomeRemoteDataSource(
          _payload('Unused'),
          error: StateError('Offline'),
        ),
      );

      await expectLater(
        repository.syncHomeData(forceRefresh: true, allowStaleOnError: false),
        throwsStateError,
      );
    });

    test('rejects an unsuccessful home response', () async {
      final repository = HomeSyncRepositoryImpl(
        localDataSource: _MemoryHomeLocalDataSource(),
        remoteDataSource: _FakeHomeRemoteDataSource({
          'success': false,
          'message': 'Maintenance',
          'data': <String, dynamic>{},
        }),
      );

      await expectLater(
        repository.syncHomeData(forceRefresh: true),
        throwsFormatException,
      );
    });

    test(
      'refresh use-case contract forces a remote request by default',
      () async {
        final local = _MemoryHomeLocalDataSource()
          ..payload = _payload('Cached');
        final remote = _FakeHomeRemoteDataSource(_payload('Fresh'));
        final repository = HomeSyncRepositoryImpl(
          localDataSource: local,
          remoteDataSource: remote,
        );

        final result = await repository.refreshHomeData();

        expect(result.personalizedSummary, 'Fresh');
        expect(remote.fetchCount, 1);
      },
    );

    test('clears the persistent snapshot', () async {
      final local = _MemoryHomeLocalDataSource()..payload = _payload('Cached');
      final repository = HomeSyncRepositoryImpl(localDataSource: local);

      await repository.clearCache();

      expect(local.payload, isNull);
    });
  });
}

Map<String, dynamic> _payload(String summary) => <String, dynamic>{
  'success': true,
  'request_id': 'request-1',
  'data': <String, dynamic>{
    'banners': <dynamic>[],
    'categories': <dynamic>[],
    'deals': <dynamic>[],
    'featured_products': <dynamic>[],
    'flash_sales': <dynamic>[],
    'recommendations': <dynamic>[],
    'trending_products': <dynamic>[],
    'sections': <dynamic>[],
    'personalized_summary': summary,
  },
};

class _MemoryHomeLocalDataSource extends HomeLocalDataSource {
  Map<String, dynamic>? payload;

  @override
  Future<void> saveHomePayload(Map<String, dynamic> value) async {
    payload = Map<String, dynamic>.from(value);
  }

  @override
  Future<Map<String, dynamic>?> loadHomePayload() async =>
      payload == null ? null : Map<String, dynamic>.from(payload!);

  @override
  Future<void> clearHomePayload() async {
    payload = null;
  }
}

class _FakeHomeRemoteDataSource extends HomeRemoteDataSource {
  _FakeHomeRemoteDataSource(this.payload, {this.error});

  final Map<String, dynamic> payload;
  final Object? error;
  int fetchCount = 0;

  @override
  Future<Map<String, dynamic>> getHomePayload() async {
    fetchCount++;
    final failure = error;
    if (failure != null) throw failure;
    return payload;
  }
}
