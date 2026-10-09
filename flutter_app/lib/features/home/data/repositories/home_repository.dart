import '../../domain/entities/home_data_entity.dart';
import '../../domain/entities/home_entity.dart';

abstract class HomeRepository {
  Future<HomeDataEntity> getHomeData({
    String? userId,
    String? locale,
    String? currency,
    String? country,
    String? deviceType,
    bool forceRefresh = false,
  });

  Future<void> cacheHomeData({
    required HomeDataEntity data,
    String? userId,
    String? locale,
    String? currency,
    String? country,
    String? deviceType,
  });

  Future<HomeDataEntity> refreshHomeData({
    String? userId,
    String? locale,
    String? currency,
    String? country,
    String? deviceType,
    bool forceRefresh = true,
  });

  Future<HomePageEntity> getHomePage();

  Future<List<HomeDealEntity>> getPersonalizedDeals({
    required String customerId,
  });
}
