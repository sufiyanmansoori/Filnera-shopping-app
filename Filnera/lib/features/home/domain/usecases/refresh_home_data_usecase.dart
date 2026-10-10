import '../entities/home_data_entity.dart';

/// Forces a refresh of the complete home page payload from the backend.
class RefreshHomeDataUseCase {
  const RefreshHomeDataUseCase(this._repository);

  final HomeRefreshRepository _repository;

  Future<HomeDataEntity> call({
    String? userId,
    String? locale,
    String? currency,
    String? country,
    String? deviceType,
    bool forceRefresh = true,
  }) {
    return _repository.refreshHomeData(
      userId: userId,
      locale: locale,
      currency: currency,
      country: country,
      deviceType: deviceType,
      forceRefresh: forceRefresh,
    );
  }
}

abstract class HomeRefreshRepository {
  Future<HomeDataEntity> refreshHomeData({
    String? userId,
    String? locale,
    String? currency,
    String? country,
    String? deviceType,
    bool forceRefresh = true,
  });
}
