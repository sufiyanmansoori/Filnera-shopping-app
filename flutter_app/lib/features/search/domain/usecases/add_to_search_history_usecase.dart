import '../../data/models/search_history_model.dart';
import '../../data/repositories/search_repository_impl.dart';
import '../entities/search_history_entity.dart';

class AddToSearchHistoryUseCase {
  const AddToSearchHistoryUseCase(this.repository);

  final SearchRepository repository;

  Future<void> call(SearchHistoryEntity history) async {
    await repository.saveHistory(
      SearchHistoryModel(query: history.query, createdAt: history.createdAt),
    );
  }
}
