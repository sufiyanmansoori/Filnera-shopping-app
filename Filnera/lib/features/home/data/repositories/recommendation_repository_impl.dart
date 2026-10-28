import '../../domain/entities/recommendation_entity.dart';
import '../datasources/recommendation_remote_datasource.dart';
import '../datasources/recommendation_remote_datasource_impl.dart';
import 'recommendation_repository.dart';

const int _maximumRecommendationPageSize = 50;

/// Coordinates recommendation requests for homepage and product surfaces.
///
/// The remote datasource owns transport parsing, fallback catalog behavior,
/// request coalescing, and its bounded cache. This repository keeps the
/// domain-facing API independent from those details and returns immutable
/// results to presentation code.
class RecommendationRepositoryImpl implements RecommendationRepository {
  RecommendationRepositoryImpl({
    RecommendationRemoteDataSource? remoteDataSource,
  }) : _remoteDataSource =
           remoteDataSource ?? RecommendationRemoteDataSourceImpl();

  final RecommendationRemoteDataSource _remoteDataSource;

  @override
  Future<List<RecommendationEntity>> getRecommendations({
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
    final safePage = page < 1 ? 1 : page;
    final safePageSize = pageSize.clamp(1, _maximumRecommendationPageSize);
    final recommendations = await _remoteDataSource.fetchRecommendations(
      page: safePage,
      pageSize: safePageSize,
      forceRefresh: forceRefresh,
      locale: _normalizeOptional(locale),
      currency: _normalizeOptional(currency),
      country: _normalizeOptional(country),
      deviceType: _normalizeOptional(deviceType),
      userId: _normalizeOptional(userId),
      recentlyViewed: _normalizeIds(recentlyViewed),
      favoriteCategories: _normalizeIds(favoriteCategories),
    );
    return _immutableUniqueRecommendations(recommendations);
  }

  /// Returns products similar to the specified product.
  @override
  Future<List<RecommendationEntity>> getSimilarProducts({
    required String productId,
    int limit = 10,
    String? userId,
    String? locale,
    String? currency,
  }) async {
    final id = productId.trim();
    if (id.isEmpty) {
      throw const FormatException('Product id cannot be empty');
    }

    final recommendations = await _remoteDataSource.fetchSimilarProducts(
      productId: id,
      limit: _safeLimit(limit),
      userId: _normalizeOptional(userId),
      locale: _normalizeOptional(locale),
      currency: _normalizeOptional(currency),
    );
    return _immutableUniqueRecommendations(
      recommendations.where((item) => item.productId != id),
    );
  }

  /// Loads category-scoped recommendations with bounded pagination.
  @override
  Future<List<RecommendationEntity>> getCategoryRecommendations({
    required String categoryId,
    int page = 1,
    int pageSize = 10,
    String? userId,
    String? locale,
    String? currency,
  }) async {
    final id = categoryId.trim();
    if (id.isEmpty) {
      throw const FormatException('Category id cannot be empty');
    }

    final recommendations = await _remoteDataSource
        .fetchCategoryRecommendations(
          categoryId: id,
          page: page < 1 ? 1 : page,
          pageSize: pageSize.clamp(1, _maximumRecommendationPageSize),
          userId: _normalizeOptional(userId),
          locale: _normalizeOptional(locale),
          currency: _normalizeOptional(currency),
        );
    return _immutableUniqueRecommendations(
      recommendations.where(
        (item) =>
            item.categoryId == null ||
            item.categoryId!.toLowerCase() == id.toLowerCase(),
      ),
    );
  }

  /// Records a recommendation impression or conversion interaction.
  ///
  /// The datasource treats analytics transport errors as non-blocking, so
  /// tracking never interrupts browsing or checkout.
  @override
  Future<void> trackInteraction({
    required String recommendationId,
    required String productId,
    required String action,
    String? userId,
    String? source,
    int? position,
  }) {
    final id = recommendationId.trim();
    final itemId = productId.trim();
    final normalizedAction = action.trim().toLowerCase();
    if (id.isEmpty || itemId.isEmpty) {
      throw const FormatException(
        'Recommendation and product ids are required',
      );
    }
    return _remoteDataSource.trackRecommendationInteraction(
      recommendationId: id,
      productId: itemId,
      action: normalizedAction,
      userId: _normalizeOptional(userId),
      source: _normalizeOptional(source),
      position: position,
    );
  }

  static List<RecommendationEntity> _immutableUniqueRecommendations(
    Iterable<RecommendationEntity> recommendations,
  ) {
    final unique = <String, RecommendationEntity>{};
    for (final recommendation in recommendations) {
      final id = recommendation.id.trim();
      final productId = recommendation.productId.trim();
      if (id.isEmpty || productId.isEmpty) continue;
      unique.putIfAbsent(id, () => recommendation);
    }
    return List<RecommendationEntity>.unmodifiable(unique.values);
  }

  static List<String> _normalizeIds(Iterable<String> values) {
    final unique = <String>{};
    for (final value in values) {
      final normalized = value.trim();
      if (normalized.isEmpty) continue;
      unique.add(normalized);
      if (unique.length == 20) break;
    }
    return List<String>.unmodifiable(unique);
  }

  static String? _normalizeOptional(String? value) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }

  static int _safeLimit(int limit) =>
      limit.clamp(1, _maximumRecommendationPageSize);
}
