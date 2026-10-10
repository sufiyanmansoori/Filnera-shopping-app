import '../entities/home_entity.dart';
import '../../data/repositories/home_repository.dart';

class GetPersonalizedDealsUseCase {
  const GetPersonalizedDealsUseCase(this.repository);

  final HomeRepository repository;

  Future<List<HomeDealEntity>> call({required String customerId}) {
    return repository.getPersonalizedDeals(customerId: customerId);
  }
}
