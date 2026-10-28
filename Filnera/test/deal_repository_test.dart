import 'package:filnera/features/home/data/datasources/deal_remote_datasource.dart';
import 'package:filnera/features/home/data/repositories/deal_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DealRepositoryImpl', () {
    test(
      'filters expired and inactive deals and removes duplicate IDs',
      () async {
        final repository = DealRepositoryImpl(
          remoteDataSource: _FakeDealDataSource([
            _deal('second', endAt: '2026-10-18T00:00:00Z'),
            _deal('first', endAt: '2026-10-17T00:00:00Z'),
            _deal('second', title: 'Duplicate'),
            _deal('inactive', active: false),
            _deal('expired', endAt: '2026-10-14T00:00:00Z'),
          ]),
          clock: () => DateTime.utc(2026, 10, 16),
        );

        final deals = await repository.getDeals();

        expect(deals.map((deal) => deal.id), ['first', 'second']);
        expect(deals.last.title, 'second');
      },
    );

    test(
      'normalizes page arguments and forwards localization options',
      () async {
        final source = _FakeDealDataSource([_deal('page-result')]);
        final repository = DealRepositoryImpl(remoteDataSource: source);

        await repository.getDeals(
          page: 2,
          pageSize: 12,
          locale: ' hi_IN ',
          currency: 'INR',
          country: 'IN',
          deviceType: 'web',
        );

        expect(source.lastPage, 2);
        expect(source.lastPageSize, 12);
        expect(source.lastLimit, 12);
        expect(source.lastLocale, 'hi_IN');
        expect(source.lastCurrency, 'INR');
        expect(source.lastCountry, 'IN');
        expect(source.lastDeviceType, 'web');
      },
    );

    test(
      'caches, coalesces concurrent requests, and force-refreshes',
      () async {
        final source = _FakeDealDataSource([_deal('cached')]);
        final repository = DealRepositoryImpl(
          remoteDataSource: source,
          cacheDuration: const Duration(minutes: 1),
        );

        await Future.wait([repository.getDeals(), repository.getDeals()]);
        await repository.getDeals();
        await repository.getDeals(forceRefresh: true);

        expect(source.fetchCount, 2);
      },
    );

    test('returns featured and trending deals in expected order', () async {
      final repository = DealRepositoryImpl(
        remoteDataSource: _FakeDealDataSource([
          _deal('low', discount: 10, sold: 100),
          _deal('top-discount', discount: 70, sold: 50),
          _deal('top-seller', discount: 20, sold: 900),
        ]),
      );

      final featured = await repository.getFeaturedDeals(limit: 2);
      final trending = await repository.getTrendingDeals(limit: 2);

      expect(featured.map((deal) => deal.id), ['top-discount', 'top-seller']);
      expect(trending.map((deal) => deal.id), ['top-seller', 'low']);
    });

    test(
      'validates category and search input and delegates category filters',
      () async {
        final source = _FakeDealDataSource([
          _deal('electronics', category: 'electronics'),
          _deal('fashion', category: 'fashion'),
        ]);
        final repository = DealRepositoryImpl(remoteDataSource: source);

        final categoryDeals = await repository.getDealsByCategory(
          categoryId: 'electronics',
        );
        final results = await repository.searchDeals(query: 'earbuds');

        expect(categoryDeals.map((deal) => deal.id), ['electronics']);
        expect(results.map((deal) => deal.id), ['electronics', 'fashion']);
        expect(source.lastCategory, 'electronics');
        expect(source.lastQuery, 'earbuds');
        await expectLater(
          repository.getDealsByCategory(categoryId: ' '),
          throwsFormatException,
        );
        await expectLater(
          repository.searchDeals(query: ' '),
          throwsFormatException,
        );
      },
    );

    test('loads flash deals and validates deal detail identity', () async {
      final repository = DealRepositoryImpl(
        remoteDataSource: _FakeDealDataSource([_deal('deal-42')]),
      );

      final flashDeals = await repository.getFlashDeals(limit: 1);
      final detail = await repository.getDealById('deal-42');

      expect(flashDeals.single.id, 'deal-42');
      expect(detail.id, 'deal-42');
      await expectLater(repository.getDealById(' '), throwsFormatException);
      await expectLater(repository.getDealById('missing'), throwsStateError);
    });

    test('clears only category-scoped cached results', () async {
      final source = _FakeDealDataSource([_deal('deal-1')]);
      final repository = DealRepositoryImpl(remoteDataSource: source);

      await repository.getDealsByCategory(categoryId: 'electronics');
      await repository.getDealsByCategory(categoryId: 'fashion');
      repository.clearCache(categoryId: 'electronics');
      await repository.getDealsByCategory(categoryId: 'fashion');
      await repository.getDealsByCategory(categoryId: 'electronics');

      expect(source.categoryFetchCount, 3);
    });
  });
}

class _FakeDealDataSource extends DealRemoteDataSource {
  _FakeDealDataSource(this.deals);

  final List<Map<String, dynamic>> deals;
  int fetchCount = 0;
  int categoryFetchCount = 0;
  int lastPage = 0;
  int lastPageSize = 0;
  int lastLimit = 0;
  String? lastLocale;
  String? lastCurrency;
  String? lastCountry;
  String? lastDeviceType;
  String? lastCategory;
  String? lastQuery;

  @override
  Future<List<Map<String, dynamic>>> fetchDeals({
    String? categoryId,
    String? subcategoryId,
    bool activeOnly = true,
    int limit = 12,
    int page = 1,
    int? pageSize,
    String? sortBy,
    String? locale,
    String? currency,
    String? country,
    String? deviceType,
  }) async {
    fetchCount++;
    lastPage = page;
    lastPageSize = pageSize ?? 0;
    lastLimit = limit;
    lastLocale = locale;
    lastCurrency = currency;
    lastCountry = country;
    lastDeviceType = deviceType;
    return deals;
  }

  @override
  Future<List<Map<String, dynamic>>> fetchFlashDeals({
    int limit = 8,
    String? categoryId,
  }) async => deals;

  @override
  Future<List<Map<String, dynamic>>> fetchCategoryDeals({
    required String categoryId,
    int limit = 10,
  }) async {
    categoryFetchCount++;
    lastCategory = categoryId;
    return deals;
  }

  @override
  Future<List<Map<String, dynamic>>> searchDeals({
    required String query,
    int limit = 12,
    String? categoryId,
  }) async {
    lastQuery = query;
    return deals;
  }

  @override
  Future<Map<String, dynamic>> fetchDealById(String dealId) async {
    return deals.firstWhere(
      (deal) => deal['id'] == dealId,
      orElse: () => <String, dynamic>{},
    );
  }
}

Map<String, dynamic> _deal(
  String id, {
  String? title,
  String category = 'electronics',
  double discount = 25,
  int sold = 100,
  bool active = true,
  String? endAt,
}) => <String, dynamic>{
  'id': id,
  'title': title ?? id,
  'product_id': 'product-$id',
  'product_name': title ?? id,
  'original_price': 1000,
  'current_price': 750,
  'discount_percent': discount,
  'image_url': 'https://example.com/$id.png',
  'category_id': category,
  'is_active': active,
  'sold_count': sold,
  'start_at': '2026-10-15T00:00:00Z',
  'end_at': endAt ?? '2026-10-20T00:00:00Z',
};
