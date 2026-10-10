import '../../domain/entities/featured_product_entity.dart';

/// Fetches the featured product rail for the home screen.
class GetFeaturedProductsUseCase {
  const GetFeaturedProductsUseCase(this._repository);

  final HomeFeaturedProductsRepository _repository;

  Future<List<FeaturedProductEntity>> call({
    int page = 1,
    int pageSize = 12,
    bool forceRefresh = false,
    String? locale,
    String? currency,
    String? country,
    String? deviceType,
    String? categoryId,
  }) {
    return _repository.getFeaturedProducts(
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

abstract class HomeFeaturedProductsRepository {
  Future<List<FeaturedProductEntity>> getFeaturedProducts({
    int page = 1,
    int pageSize = 12,
    bool forceRefresh = false,
    String? locale,
    String? currency,
    String? country,
    String? deviceType,
    String? categoryId,
  });
}
