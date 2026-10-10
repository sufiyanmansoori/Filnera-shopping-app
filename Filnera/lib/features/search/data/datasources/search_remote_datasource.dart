import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../models/search_result_model.dart';
import '../models/search_filter_model.dart';
import '../models/search_suggestion_model.dart';
import '../models/search_history_model.dart';

class SearchRemoteDataSource {
  SearchRemoteDataSource({ApiClient? apiClient})
    : _client = apiClient ?? ApiClient();

  final ApiClient _client;

  Future<List<SearchResultModel>> search({
    required String query,
    SearchFilterModel? filters,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _client.get(
        '/search',
        queryParameters: {
          'q': query,
          'page': page,
          'page_size': pageSize,
          if (filters != null) ...filters.toQueryParameters(),
        },
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final items = data['items'] as List? ?? const <dynamic>[];
        return items
            .map(
              (item) =>
                  SearchResultModel.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList();
      }

      if (data is List) {
        return data
            .map(
              (item) =>
                  SearchResultModel.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList();
      }

      return const <SearchResultModel>[];
    } on DioException catch (e) {
      throw Exception('Remote search failed: ${e.message}');
    }
  }

  Future<List<SearchSuggestionModel>> suggestions(String query) async {
    try {
      final response = await _client.get(
        '/search/suggestions',
        queryParameters: {'q': query},
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final items = data['items'] as List? ?? const <dynamic>[];
        return items
            .map(
              (item) => SearchSuggestionModel.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList();
      }

      if (data is List) {
        return data
            .map(
              (item) => SearchSuggestionModel.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList();
      }

      return const <SearchSuggestionModel>[];
    } on DioException catch (e) {
      throw Exception('Suggestion fetch failed: ${e.message}');
    }
  }

  Future<SearchFilterModel> filters() async {
    try {
      final response = await _client.get('/search/filters');
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return SearchFilterModel.fromJson(data);
      }
      return const SearchFilterModel();
    } on DioException catch (e) {
      throw Exception('Filter metadata failed: ${e.message}');
    }
  }

  Future<List<SearchHistoryModel>> history({required String customerId}) async {
    try {
      final response = await _client.get(
        '/search/history',
        queryParameters: {'customer_id': customerId},
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final items = data['items'] as List? ?? const <dynamic>[];
        return items
            .map(
              (item) =>
                  SearchHistoryModel.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList();
      }

      if (data is List) {
        return data
            .map(
              (item) =>
                  SearchHistoryModel.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList();
      }

      return const <SearchHistoryModel>[];
    } on DioException catch (e) {
      throw Exception('History fetch failed: ${e.message}');
    }
  }
}
