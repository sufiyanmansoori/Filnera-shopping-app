import 'package:filnera/features/home/data/datasources/recommendation_remote_datasource.dart';
import 'package:filnera/features/home/data/repositories/recommendation_repository_impl.dart';
import 'package:filnera/features/home/domain/entities/recommendation_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RecommendationRepository', () {
    test(
      'normalizes request values and returns immutable unique results',
      () async {
        final source = _FakeRecommendationDataSource([
          _recommendation('rec-1', productId: 'p-1'),
          _recommendation('rec-1', productId: 'p-1', title: 'duplicate'),
          _recommendation('', productId: 'p-invalid'),
        ]);
        final repository = RecommendationRepositoryImpl(
          remoteDataSource: source,
        );

        final results = await repository.getRecommendations(
          page: 0,
          pageSize: 500,
          locale: ' hi_IN ',
          currency: ' INR ',
          country: ' IN ',
          deviceType: ' web ',
          userId: ' user-1 ',
          recentlyViewed: [' p-1 ', '', 'p-1'],
          favoriteCategories: [' books '],
        );

        expect(source.lastPage, 1);
        expect(source.lastPageSize, 50);
        expect(source.lastLocale, 'hi_IN');
        expect(source.lastCurrency, 'INR');
        expect(source.lastCountry, 'IN');
        expect(source.lastDeviceType, 'web');
        expect(source.lastUserId, 'user-1');
        expect(source.lastRecentlyViewed, ['p-1']);
        expect(source.lastFavoriteCategories, ['books']);
        expect(results.map((item) => item.id), ['rec-1']);
        expect(
          () => results.add(_recommendation('rec-2', productId: 'p-2')),
          throwsUnsupportedError,
        );
      },
    );

    test(
      'delegates product-similarity requests and excludes current product',
      () async {
        final source = _FakeRecommendationDataSource([
          _recommendation('same-product', productId: 'p-current'),
          _recommendation('similar-1', productId: 'p-other'),
        ]);
        final repository = RecommendationRepositoryImpl(
          remoteDataSource: source,
        );

        final results = await repository.getSimilarProducts(
          productId: ' p-current ',
          limit: 12,
          userId: ' user-3 ',
        );

        expect(source.lastSimilarProductId, 'p-current');
        expect(source.lastSimilarLimit, 12);
        expect(source.lastUserId, 'user-3');
        expect(results.map((item) => item.id), ['similar-1']);
        await expectLater(
          repository.getSimilarProducts(productId: ' '),
          throwsFormatException,
        );
      },
    );

    test('filters category results and validates category id', () async {
      final source = _FakeRecommendationDataSource([
        _recommendation('book-1', productId: 'p-1', categoryId: 'books'),
        _recommendation('shoe-1', productId: 'p-2', categoryId: 'fashion'),
        _recommendation('book-2', productId: 'p-3'),
      ]);
      final repository = RecommendationRepositoryImpl(remoteDataSource: source);

      final results = await repository.getCategoryRecommendations(
        categoryId: ' Books ',
        page: -1,
        pageSize: 5,
      );

      expect(source.lastCategoryId, 'Books');
      expect(source.lastPage, 1);
      expect(source.lastPageSize, 5);
      expect(results.map((item) => item.id), ['book-1', 'book-2']);
      await expectLater(
        repository.getCategoryRecommendations(categoryId: ''),
        throwsFormatException,
      );
    });

    test('tracks supported interaction and rejects invalid action', () async {
      final source = _FakeRecommendationDataSource(const []);
      final repository = RecommendationRepositoryImpl(remoteDataSource: source);

      await repository.trackInteraction(
        recommendationId: ' rec-1 ',
        productId: ' p-1 ',
        action: 'click',
        source: 'home',
        position: 2,
      );

      expect(source.lastTrackedRecommendationId, 'rec-1');
      expect(source.lastTrackedProductId, 'p-1');
      expect(source.lastAction, 'click');
      expect(source.lastPosition, 2);
      await expectLater(
        repository.trackInteraction(
          recommendationId: 'rec-1',
          productId: 'p-1',
          action: 'unsupported',
        ),
        throwsFormatException,
      );
    });
  });
}

class _FakeRecommendationDataSource extends RecommendationRemoteDataSource {
  _FakeRecommendationDataSource(this.recommendations);

  final List<RecommendationEntity> recommendations;
  int lastPage = 0;
  int lastPageSize = 0;
  String? lastLocale;
  String? lastCurrency;
  String? lastCountry;
  String? lastDeviceType;
  String? lastUserId;
  List<String> lastRecentlyViewed = const <String>[];
  List<String> lastFavoriteCategories = const <String>[];
  String? lastSimilarProductId;
  int lastSimilarLimit = 0;
  String? lastCategoryId;
  String? lastTrackedRecommendationId;
  String? lastTrackedProductId;
  String? lastAction;
  int? lastPosition;

  @override
  Future<List<RecommendationEntity>> fetchRecommendations({
    int page = 1,
    int pageSize = 10,
    bool forceRefresh = false,
    String? locale,
    String? currency,
    String? country,
    String? deviceType,
    String? userId,
    List<String> recentlyViewed = const <String>[],
    List<String> favoriteCategories = const <String>[],
  }) async {
    lastPage = page;
    lastPageSize = pageSize;
    lastLocale = locale;
    lastCurrency = currency;
    lastCountry = country;
    lastDeviceType = deviceType;
    lastUserId = userId;
    lastRecentlyViewed = recentlyViewed;
    lastFavoriteCategories = favoriteCategories;
    return recommendations;
  }

  @override
  Future<List<RecommendationEntity>> fetchSimilarProducts({
    required String productId,
    int limit = 10,
    String? userId,
    String? locale,
    String? currency,
  }) async {
    lastSimilarProductId = productId;
    lastSimilarLimit = limit;
    lastUserId = userId;
    return recommendations;
  }

  @override
  Future<List<RecommendationEntity>> fetchCategoryRecommendations({
    required String categoryId,
    int page = 1,
    int pageSize = 10,
    String? userId,
    String? locale,
    String? currency,
  }) async {
    lastCategoryId = categoryId;
    lastPage = page;
    lastPageSize = pageSize;
    return recommendations;
  }

  @override
  Future<void> trackRecommendationInteraction({
    required String recommendationId,
    required String productId,
    required String action,
    String? userId,
    String? source,
    int? position,
  }) async {
    lastTrackedRecommendationId = recommendationId;
    lastTrackedProductId = productId;
    lastAction = action;
    lastPosition = position;
    if (recommendationId.trim().isEmpty || productId.trim().isEmpty) {
      throw const FormatException(
        'Recommendation and product ids are required',
      );
    }
    if (!const <String>{
      'impression',
      'click',
      'add_to_cart',
      'purchase',
      'dismiss',
    }.contains(action.trim().toLowerCase())) {
      throw const FormatException('Unsupported recommendation action');
    }
  }
}

RecommendationEntity _recommendation(
  String id, {
  required String productId,
  String title = 'Product',
  String? categoryId,
}) => RecommendationEntity(
  id: id,
  productId: productId,
  title: title,
  imageUrl: 'https://example.com/$productId.png',
  price: 100,
  compareAtPrice: 150,
  categoryId: categoryId,
);
