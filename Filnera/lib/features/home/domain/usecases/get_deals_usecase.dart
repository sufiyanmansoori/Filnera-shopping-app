import '../../domain/entities/deal_entity.dart';

/// Fetches all deal cards configured for the home page.
class GetDealsUseCase {
  const GetDealsUseCase(this._repository);

  final HomeDealsRepository _repository;

  Future<List<DealEntity>> call({
    int page = 1,
    int pageSize = 10,
    bool forceRefresh = false,
    String? locale,
    String? currency,
    String? country,
    String? deviceType,
    bool includeExpired = false,
  }) {
    return _repository.getDeals(
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

abstract class HomeDealsRepository {
  Future<List<DealEntity>> getDeals({
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
