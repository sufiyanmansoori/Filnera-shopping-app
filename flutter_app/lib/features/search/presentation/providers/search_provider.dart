import 'package:flutter/foundation.dart';

import '../../data/models/search_filter_model.dart';
import '../../data/models/search_result_model.dart';
import '../../data/models/search_suggestion_model.dart';
import '../../data/repositories/search_repository_impl.dart';

class SearchProvider extends ChangeNotifier {
  SearchProvider({required this._repository});

  final SearchRepository _repository;

  bool _isLoading = false;
  String? _error;
  String _query = '';
  SearchFilterModel _filters = const SearchFilterModel();
  List<SearchResultModel> _results = const <SearchResultModel>[];
  List<SearchSuggestionModel> _suggestions = const <SearchSuggestionModel>[];

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get query => _query;
  SearchFilterModel get filters => _filters;
  List<SearchResultModel> get results => _results;
  List<SearchSuggestionModel> get suggestions => _suggestions;

  Future<void> search(
    String query, {
    SearchFilterModel? filters,
    int page = 1,
    int pageSize = 20,
  }) async {
    _query = query.trim();
    _error = null;
    _isLoading = true;
    notifyListeners();

    try {
      _filters = filters ?? _filters;
      _results = await _repository.search(
        query: _query,
        filters: _filters,
        page: page,
        pageSize: pageSize,
      );
    } catch (e) {
      _error = e.toString();
      _results = const <SearchResultModel>[];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchSuggestions(String query) async {
    if (query.trim().isEmpty) {
      _suggestions = const <SearchSuggestionModel>[];
      notifyListeners();
      return;
    }

    try {
      _suggestions = await _repository.suggestions(query);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _suggestions = const <SearchSuggestionModel>[];
      notifyListeners();
    }
  }

  void updateFilters(SearchFilterModel filter) {
    _filters = filter;
    notifyListeners();
  }

  void clear() {
    _query = '';
    _error = null;
    _results = const <SearchResultModel>[];
    _suggestions = const <SearchSuggestionModel>[];
    notifyListeners();
  }
}
