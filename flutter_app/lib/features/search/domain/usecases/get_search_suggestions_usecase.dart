import '../../data/repositories/search_repository_impl.dart';
import '../entities/search_suggestion_entity.dart';

class GetSearchSuggestionsUseCase {
  const GetSearchSuggestionsUseCase(this.repository);

  final SearchRepository repository;

  Future<List<SearchSuggestionEntity>> call(String query) async {
    final result = await repository.suggestions(query);
    return result
        .map((model) => SearchSuggestionEntity.fromModel(model))
        .toList(growable: false);
  }
}
