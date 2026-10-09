import '../../../../core/network/api_client.dart';
import '../datasources/search_local_datasource.dart';
import '../datasources/search_remote_datasource.dart';
import '../models/search_filter_model.dart';
import '../models/search_history_model.dart';
import '../models/search_result_model.dart';
import '../models/search_suggestion_model.dart';

abstract class SearchRepository {
  Future<List<SearchResultModel>> search({
    required String query,
    SearchFilterModel? filters,
    int page = 1,
    int pageSize = 20,
  });

  Future<List<SearchSuggestionModel>> suggestions(String query);
  Future<SearchFilterModel> filters();
  Future<List<SearchHistoryModel>> history({required String customerId});
  Future<void> saveHistory(SearchHistoryModel history);
  Future<void> clearHistory();
}

class SearchRepositoryImpl implements SearchRepository {
  SearchRepositoryImpl({
    ApiClient? apiClient,
    SearchRemoteDataSource? remoteDataSource,
    SearchLocalDataSource? localDataSource,
  }) : _remoteDataSource =
           remoteDataSource ?? SearchRemoteDataSource(apiClient: apiClient),
       _localDataSource = localDataSource ?? SearchLocalDataSource();

  final SearchRemoteDataSource _remoteDataSource;
  final SearchLocalDataSource _localDataSource;

  @override
  Future<List<SearchResultModel>> search({
    required String query,
    SearchFilterModel? filters,
    int page = 1,
    int pageSize = 20,
  }) async {
    final results = await _remoteDataSource.search(
      query: query,
      filters: filters,
      page: page,
      pageSize: pageSize,
    );

    await _localDataSource.saveLastResults(results);
    return results;
  }

  @override
  Future<List<SearchSuggestionModel>> suggestions(String query) async {
    return await _remoteDataSource.suggestions(query);
  }

  @override
  Future<SearchFilterModel> filters() async {
    return await _remoteDataSource.filters();
  }

  @override
  Future<List<SearchHistoryModel>> history({required String customerId}) async {
    final localHistory = await _localDataSource.getHistory();
    if (localHistory.isNotEmpty) return localHistory;

    final remoteHistory = await _remoteDataSource.history(
      customerId: customerId,
    );
    for (final item in remoteHistory) {
      await _localDataSource.saveHistory(item);
    }
    return remoteHistory;
  }

  @override
  Future<void> saveHistory(SearchHistoryModel history) async {
    await _localDataSource.saveHistory(history);
  }

  @override
  Future<void> clearHistory() async {
    await _localDataSource.clearHistory();
  }
}
