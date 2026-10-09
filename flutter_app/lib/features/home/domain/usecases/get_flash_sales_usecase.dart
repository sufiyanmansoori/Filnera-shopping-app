import '../../domain/entities/flash_sale_entity.dart';

/// Fetches flash-sale offers and countdown-based promotions.
class GetFlashSalesUseCase {
  const GetFlashSalesUseCase(this._repository);

  final HomeFlashSalesRepository _repository;

  Future<List<FlashSaleEntity>> call({
    int page = 1,
    int pageSize = 10,
    bool forceRefresh = false,
    String? locale,
    String? currency,
    String? country,
    String? deviceType,
    bool includeExpired = false,
  }) {
    return _repository.getFlashSales(
      page: page,
      pageSize: pageSize,
      forceRefresh: forceRefresh,
      locale: locale,
      currency: currency,
      country: country,
      deviceType: deviceType,
      includeExpired: includeExpired,
    );
  }
}

abstract class HomeFlashSalesRepository {
  Future<List<FlashSaleEntity>> getFlashSales({
    int page = 1,
    int pageSize = 10,
    bool forceRefresh = false,
    String? locale,
    String? currency,
    String? country,
    String? deviceType,
    bool includeExpired = false,
  });
}
