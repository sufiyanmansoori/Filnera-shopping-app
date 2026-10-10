import '../../data/repositories/search_repository_impl.dart';
import '../entities/search_filter_entity.dart';

class GetSearchFiltersUseCase {
  const GetSearchFiltersUseCase(this.repository);

  final SearchRepository repository;

  Future<SearchFilterEntity> call() async {
    final result = await repository.filters();
    return SearchFilterEntity.fromModel(result);
  }
}
