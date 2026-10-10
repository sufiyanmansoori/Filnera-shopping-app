import '../../domain/entities/featured_product_entity.dart';

/// Fetches trending products for the home hero grid.
class GetTrendingProductsUseCase {
  const GetTrendingProductsUseCase(this._repository);

  final HomeTrendingProductsRepository _repository;

  Future<List<FeaturedProductEntity>> call({
    int page = 1,
    int pageSize = 10,
    bool forceRefresh = false,
    String? locale,
    String? currency,
    String? country,
    String? deviceType,
    String? categoryId,
  }) {
    return _repository.getTrendingProducts(
      page: page,
      pageSize: pageSize,
      forceRefresh: forceRefresh,
      locale: locale,
      currency: currency,
      country: country,
      deviceType: deviceType,
      categoryId: categoryId,
    );
  }
}

abstract class HomeTrendingProductsRepository {
  Future<List<FeaturedProductEntity>> getTrendingProducts({
    int page = 1,
    int pageSize = 10,
    bool forceRefresh = false,
    String? locale,
    String? currency,
    String? country,
    String? deviceType,
    String? categoryId,
  });
}
