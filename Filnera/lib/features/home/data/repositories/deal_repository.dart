import '../../domain/entities/deal_entity.dart';
import '../../domain/usecases/get_deals_usecase.dart';

/// Data-layer contract for deal listings and storefront placements.
///
/// The primary listing method satisfies [HomeDealsRepository], which is the
/// existing domain contract consumed by [GetDealsUseCase].
abstract class DealRepository implements HomeDealsRepository {
  Future<List<DealEntity>> getFlashDeals({
    int limit = 8,
    String? categoryId,
    bool forceRefresh = false,
  });

  Future<List<DealEntity>> getFeaturedDeals({
    int limit = 6,
    String? categoryId,
    bool forceRefresh = false,
  });

  Future<List<DealEntity>> getTrendingDeals({
    int limit = 8,
    String? categoryId,
    bool forceRefresh = false,
  });

  Future<List<DealEntity>> getDealsByCategory({
    required String categoryId,
    int limit = 10,
    bool forceRefresh = false,
  });

  Future<List<DealEntity>> searchDeals({
    required String query,
    int limit = 12,
    String? categoryId,
    bool forceRefresh = false,
  });

  Future<DealEntity> getDealById(String dealId, {bool forceRefresh = false});

  /// Removes all cached results, or results related to one category.
  void clearCache({String? categoryId});
}
