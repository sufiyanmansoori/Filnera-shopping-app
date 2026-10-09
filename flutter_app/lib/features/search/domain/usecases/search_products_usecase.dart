import '../../data/repositories/search_repository_impl.dart';
import '../entities/search_filter_entity.dart';
import '../entities/search_result_entity.dart';

class SearchProductsUseCase {
  const SearchProductsUseCase(this.repository);

  final SearchRepository repository;

  Future<List<SearchResultEntity>> call({
    required String query,
    SearchFilterEntity? filters,
    int page = 1,
    int pageSize = 20,
  }) async {
    final result = await repository.search(
      query: query,
      filters: filters?.toModel(),
      page: page,
      pageSize: pageSize,
    );

    return result
        .map((model) => SearchResultEntity.fromModel(model))
        .toList(growable: false);
  }
}
