import '../entities/home_data_entity.dart';

/// Persists a fresh home payload locally when the user is offline or refreshes.
class CacheHomeDataUseCase {
  const CacheHomeDataUseCase(this._repository);

  final HomeCacheRepository _repository;

  Future<void> call({
    required HomeDataEntity data,
    String? userId,
    String? locale,
    String? currency,
    String? country,
    String? deviceType,
  }) {
    return _repository.cacheHomeData(
      data: data,
      userId: userId,
      locale: locale,
      currency: currency,
      country: country,
      deviceType: deviceType,
    );
  }
}

abstract class HomeCacheRepository {
  Future<void> cacheHomeData({
    required HomeDataEntity data,
    String? userId,
    String? locale,
    String? currency,
    String? country,
    String? deviceType,
  });
}
