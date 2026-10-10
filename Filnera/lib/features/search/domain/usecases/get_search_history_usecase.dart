import '../../data/repositories/search_repository_impl.dart';
import '../entities/search_history_entity.dart';

class GetSearchHistoryUseCase {
  const GetSearchHistoryUseCase(this.repository);

  final SearchRepository repository;

  Future<List<SearchHistoryEntity>> call({required String customerId}) async {
    final result = await repository.history(customerId: customerId);
    return result
        .map((model) => SearchHistoryEntity.fromModel(model))
        .toList(growable: false);
  }
}
