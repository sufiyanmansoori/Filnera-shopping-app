import '../../data/models/search_history_model.dart';

class SearchHistoryEntity {
  const SearchHistoryEntity({required this.query, this.createdAt});

  final String query;
  final DateTime? createdAt;

  factory SearchHistoryEntity.fromModel(SearchHistoryModel model) {
    return SearchHistoryEntity(query: model.query, createdAt: model.createdAt);
  }

  SearchHistoryModel toModel() {
    return SearchHistoryModel(query: query, createdAt: createdAt);
  }
}
