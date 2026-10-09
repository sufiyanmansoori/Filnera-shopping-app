import '../../data/models/search_suggestion_model.dart';

class SearchSuggestionEntity {
  const SearchSuggestionEntity({
    required this.id,
    required this.text,
    required this.category,
    required this.score,
  });

  final String id;
  final String text;
  final String category;
  final double score;

  factory SearchSuggestionEntity.fromModel(SearchSuggestionModel model) {
    return SearchSuggestionEntity(
      id: model.id,
      text: model.text,
      category: model.category,
      score: model.score,
    );
  }

  SearchSuggestionModel toModel() {
    return SearchSuggestionModel(
      id: id,
      text: text,
      category: category,
      score: score,
    );
  }
}
