import 'package:filnera/features/home/data/datasources/banner_remote_datasource.dart';
import 'package:filnera/features/home/data/repositories/banner_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BannerRepositoryImpl', () {
    test(
      'filters inactive banners, deduplicates, and sorts deterministically',
      () async {
        final source = _FakeBannerDataSource(
          banners: [
            _banner('second', order: 2),
            _banner('first-z', order: 1),
            _banner('first-a', order: 1),
            _banner('second', title: 'duplicate', order: 0),
            _banner('disabled', active: false),
            _banner('not-started', startAt: '2099-01-01T00:00:00Z'),
          ],
        );
        final repository = BannerRepositoryImpl(remoteDataSource: source);

        final result = await repository.getBanners();

        expect(result.map((banner) => banner.id), [
          'first-a',
          'first-z',
          'second',
        ]);
        expect(result.last.title, 'second');
        expect(result, hasLength(3));
      },
    );

    test(
      'caches identical requests and force refresh bypasses the cache',
      () async {
        final source = _FakeBannerDataSource(banners: [_banner('banner-1')]);
        final repository = BannerRepositoryImpl(
          remoteDataSource: source,
          cacheDuration: const Duration(minutes: 1),
        );

        await repository.getBanners();
        await repository.getBanners();
        await repository.getBanners(forceRefresh: true);

        expect(source.fetchCount, 2);
      },
    );

    test(
      'coalesces simultaneous requests and scopes cache by locale',
      () async {
        final source = _FakeBannerDataSource(banners: [_banner('banner-1')]);
        final repository = BannerRepositoryImpl(remoteDataSource: source);

        await Future.wait([
          repository.getBanners(locale: 'en-IN'),
          repository.getBanners(locale: 'en-IN'),
        ]);
        await repository.getBanners(locale: 'hi-IN');

        expect(source.fetchCount, 2);
      },
    );

    test(
      'limits category requests and rejects blank category identifiers',
      () async {
        final source = _FakeBannerDataSource(
          banners: [_banner('one'), _banner('two'), _banner('three')],
        );
        final repository = BannerRepositoryImpl(remoteDataSource: source);

        final result = await repository.getBannersByCategory(
          categoryId: 'electronics',
          limit: 2,
        );

        expect(result.map((banner) => banner.id), ['one', 'two']);
        expect(source.categoryCalls, ['electronics']);
        await expectLater(
          repository.getBannersByCategory(categoryId: '  '),
          throwsFormatException,
        );
      },
    );

    test(
      'evicts matching category caches while retaining unrelated caches',
      () async {
        final source = _FakeBannerDataSource(banners: [_banner('banner-1')]);
        final repository = BannerRepositoryImpl(remoteDataSource: source);

        await repository.getBannersByCategory(categoryId: 'electronics');
        await repository.getBannersByCategory(categoryId: 'fashion');
        repository.clearCache(categoryId: 'electronics');
        await repository.getBannersByCategory(categoryId: 'fashion');
        await repository.getBannersByCategory(categoryId: 'electronics');

        expect(source.categoryCalls, ['electronics', 'fashion', 'electronics']);
      },
    );

    test('validates banner detail IDs and maps detail payloads', () async {
      final source = _FakeBannerDataSource(banners: [_banner('banner-9')]);
      final repository = BannerRepositoryImpl(remoteDataSource: source);

      final detail = await repository.getBannerById('banner-9');
      expect(detail.id, 'banner-9');
      expect(detail.title, 'banner-9');
      await expectLater(repository.getBannerById(' '), throwsFormatException);
    });
  });
}

class _FakeBannerDataSource extends BannerRemoteDataSource {
  _FakeBannerDataSource({required this.banners});

  final List<Map<String, dynamic>> banners;
  int fetchCount = 0;
  final List<String> categoryCalls = [];

  @override
  Future<List<Map<String, dynamic>>> fetchBanners({
    int page = 1,
    int? pageSize,
    String? categoryId,
    bool activeOnly = true,
    int limit = 10,
    String? locale,
    String? currency,
    String? country,
    String? deviceType,
  }) async {
    fetchCount++;
    return banners;
  }

  @override
  Future<List<Map<String, dynamic>>> fetchHeroBanners({
    String? categoryId,
    int limit = 5,
    String? locale,
    String? country,
  }) async => banners;

  @override
  Future<List<Map<String, dynamic>>> fetchPromotionalBanners({
    String? categoryId,
    int limit = 6,
  }) async => banners;

  @override
  Future<List<Map<String, dynamic>>> fetchByCategory(String categoryId) async {
    categoryCalls.add(categoryId);
    return banners;
  }

  @override
  Future<Map<String, dynamic>> fetchBannerById(String bannerId) async =>
      _banner(bannerId);
}

Map<String, dynamic> _banner(
  String id, {
  String? title,
  int order = 0,
  bool active = true,
  String? startAt,
}) => <String, dynamic>{
  'id': id,
  'title': title ?? id,
  'image_url': 'https://example.com/$id.png',
  'is_active': active,
  'order_index': order,
  ...?startAt == null ? null : <String, String>{'start_at': startAt},
};
