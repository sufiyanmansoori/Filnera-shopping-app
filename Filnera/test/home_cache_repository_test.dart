import 'package:filnera/features/home/data/datasources/home_cache_datasource.dart';
import 'package:filnera/features/home/data/repositories/home_cache_repository.dart';
import 'package:filnera/features/home/domain/entities/home_data_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HomeCacheRepositoryImpl', () {
    test('round trips home data and records the cache context', () async {
      final source = _MemoryHomeCacheDataSource();
      final repository = HomeCacheRepositoryImpl(cacheDataSource: source);

      await repository.cacheHomeData(
        data: _homeData('Cached home'),
        userId: ' user-1 ',
        locale: 'en_IN',
        currency: 'INR',
      );
      final cached = await repository.getCachedHomeData(
        userId: 'user-1',
        locale: 'en_IN',
        currency: 'INR',
      );

      expect(cached?.personalizedSummary, 'Cached home');
      expect(source.payload?['cache_context'], {
        'user_id': 'user-1',
        'locale': 'en_IN',
        'currency': 'INR',
      });
    });

    test(
      'does not expose a different user cache or mismatched market data',
      () async {
        final source = _MemoryHomeCacheDataSource();
        final repository = HomeCacheRepositoryImpl(cacheDataSource: source);
        await repository.cacheHomeData(
          data: _homeData('Private'),
          userId: 'user-a',
          locale: 'en_IN',
        );

        expect(await repository.getCachedHomeData(userId: 'user-b'), isNull);
        expect(
          await repository.getCachedHomeData(userId: 'user-a', locale: 'hi_IN'),
          isNull,
        );
        expect(await repository.getCachedHomeData(), isNull);
      },
    );

    test('returns only fresh cached data when freshness is required', () async {
      final source = _MemoryHomeCacheDataSource()
        ..isFresh = false
        ..payload = {'personalized_summary': 'Stale'};
      final repository = HomeCacheRepositoryImpl(cacheDataSource: source);

      expect(await repository.getCachedHomeData(requireFresh: true), isNull);
      source.isFresh = true;
      expect(
        (await repository.getCachedHomeData(requireFresh: true))
            ?.personalizedSummary,
        'Stale',
      );
    });

    test('fetches and caches remote data when no fresh cache exists', () async {
      final source = _MemoryHomeCacheDataSource()..isFresh = false;
      final repository = HomeCacheRepositoryImpl(cacheDataSource: source);
      var fetchCount = 0;

      final result = await repository.getOrFetchHomeData(
        fetchRemote: () async {
          fetchCount++;
          return _homeData('Remote home');
        },
        userId: 'user-1',
      );

      expect(fetchCount, 1);
      expect(result.source, HomeCacheRepositorySource.remote);
      expect(result.data.personalizedSummary, 'Remote home');
      expect(source.payload?['cache_context'], {'user_id': 'user-1'});
    });

    test('serves stale data after a remote failure when allowed', () async {
      final source = _MemoryHomeCacheDataSource()
        ..isFresh = false
        ..payload = {
          'personalized_summary': 'Offline snapshot',
          'cache_context': <String, String>{'user_id': 'user-1'},
        };
      final repository = HomeCacheRepositoryImpl(cacheDataSource: source);

      final result = await repository.getOrFetchHomeData(
        fetchRemote: () async => throw StateError('Network unavailable'),
        userId: 'user-1',
      );

      expect(result.source, HomeCacheRepositorySource.staleCache);
      expect(result.isFromCache, isTrue);
      expect(result.isStale, isTrue);
      expect(result.data.personalizedSummary, 'Offline snapshot');
    });

    test(
      'propagates remote failures when stale fallback is disabled',
      () async {
        final source = _MemoryHomeCacheDataSource()
          ..isFresh = false
          ..payload = {'personalized_summary': 'Old snapshot'};
        final repository = HomeCacheRepositoryImpl(cacheDataSource: source);

        await expectLater(
          repository.getOrFetchHomeData(
            fetchRemote: () async => throw StateError('Network unavailable'),
            allowStaleOnError: false,
          ),
          throwsStateError,
        );
      },
    );

    test('clears cached home payload', () async {
      final source = _MemoryHomeCacheDataSource()
        ..payload = {'personalized_summary': 'Cached'};
      final repository = HomeCacheRepositoryImpl(cacheDataSource: source);

      await repository.clearCache();

      expect(source.payload, isNull);
      expect(await repository.getCachedHomeData(), isNull);
    });
  });
}

HomeDataEntity _homeData(String summary) => HomeDataEntity(
  banners: const [],
  categories: const [],
  deals: const [],
  featuredProducts: const [],
  flashSales: const [],
  recommendations: const [],
  trendingProducts: const [],
  sections: const [],
  personalizedSummary: summary,
  lastUpdated: DateTime.utc(2026, 10, 16),
);

class _MemoryHomeCacheDataSource extends HomeCacheDataSource {
  Map<String, dynamic>? payload;
  bool isFresh = true;

  @override
  Future<void> saveHomePayload(Map<String, dynamic> value) async {
    payload = Map<String, dynamic>.from(value);
    isFresh = true;
  }

  @override
  Future<Map<String, dynamic>?> loadHomePayload() async =>
      payload == null ? null : Map<String, dynamic>.from(payload!);

  @override
  Future<void> clearHomePayload() async {
    payload = null;
    isFresh = false;
  }

  @override
  Future<bool> hasFreshHomeCache() async => isFresh;
}
