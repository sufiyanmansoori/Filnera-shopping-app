import '../../data/repositories/search_repository_impl.dart';

class ClearSearchHistoryUseCase {
  const ClearSearchHistoryUseCase(this.repository);

  final SearchRepository repository;

  Future<void> call() async {
    await repository.clearHistory();
  }
}
