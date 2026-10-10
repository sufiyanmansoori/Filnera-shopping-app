import '../../domain/entities/banner_entity.dart';

/// Fetches banners for the home screen.
class GetBannersUseCase {
  const GetBannersUseCase(this._repository);

  final HomeBannerRepository _repository;

  Future<List<BannerEntity>> call({
    int page = 1,
    int pageSize = 10,
    bool forceRefresh = false,
    String? locale,
    String? currency,
    String? country,
    String? deviceType,
  }) {
    return _repository.getBanners(
      page: page,
      pageSize: pageSize,
      forceRefresh: forceRefresh,
      locale: locale,
      currency: currency,
      country: country,
      deviceType: deviceType,
    );
  }
}

abstract class HomeBannerRepository {
  Future<List<BannerEntity>> getBanners({
    int page = 1,
    int pageSize = 10,
    bool forceRefresh = false,
    String? locale,
    String? currency,
    String? country,
    String? deviceType,
  });
}
