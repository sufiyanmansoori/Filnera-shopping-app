import '../../domain/entities/banner_entity.dart';
import '../../domain/usecases/get_banners_usecase.dart';
import '../models/banner_response_model.dart';

/// Data-layer contract for banner placements used by the storefront.
///
/// The base banner request implements [HomeBannerRepository], allowing the
/// existing domain use case to depend on this contract without coupling to
/// the concrete repository or networking layer.
abstract class BannerRepository implements HomeBannerRepository {
  Future<List<BannerEntity>> getHeroBanners({
    String? categoryId,
    int limit = 5,
    String? locale,
    String? country,
    bool forceRefresh = false,
  });

  Future<List<BannerEntity>> getPromotionalBanners({
    String? categoryId,
    int limit = 6,
    bool forceRefresh = false,
  });

  Future<List<BannerEntity>> getBannersByCategory({
    required String categoryId,
    int limit = 8,
    bool forceRefresh = false,
  });

  Future<BannerItemModel> getBannerById(
    String bannerId, {
    bool forceRefresh = false,
  });

  /// Invalidates cached results; optionally limits invalidation to a category.
  void clearCache({String? categoryId});
}
