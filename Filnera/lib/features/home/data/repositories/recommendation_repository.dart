import '../../domain/entities/recommendation_entity.dart';
import '../../domain/usecases/get_recommendations_usecase.dart';

/// Contract for loading recommendations across homepage and product surfaces.
///
/// [getRecommendations] implements the domain-level repository used by
/// [GetRecommendationsUseCase]. The additional methods provide similar-item,
/// category-specific, and recommendation-interaction operations.
abstract class RecommendationRepository
    implements HomeRecommendationsRepository {
  Future<List<RecommendationEntity>> getSimilarProducts({
    required String productId,
    int limit = 10,
    String? userId,
    String? locale,
    String? currency,
  });

  Future<List<RecommendationEntity>> getCategoryRecommendations({
    required String categoryId,
    int page = 1,
    int pageSize = 10,
    String? userId,
    String? locale,
    String? currency,
  });

  Future<void> trackInteraction({
    required String recommendationId,
    required String productId,
    required String action,
    String? userId,
    String? source,
    int? position,
  });
}
