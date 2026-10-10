import '../../domain/entities/recommendation_entity.dart';

/// Fetches personalized product recommendations for the current user.
class GetRecommendationsUseCase {
  const GetRecommendationsUseCase(this._repository);

  final HomeRecommendationsRepository _repository;

  Future<List<RecommendationEntity>> call({
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
  }) {
    return _repository.getRecommendations(
      page: page,
      pageSize: pageSize,
      forceRefresh: forceRefresh,
      locale: locale,
      currency: currency,
      country: country,
      deviceType: deviceType,
      userId: userId,
      recentlyViewed: recentlyViewed,
      favoriteCategories: favoriteCategories,
    );
  }
}

abstract class HomeRecommendationsRepository {
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
  });
}
