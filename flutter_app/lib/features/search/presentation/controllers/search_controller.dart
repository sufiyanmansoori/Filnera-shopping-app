import 'package:flutter/foundation.dart';

import '../../data/models/search_filter_model.dart';
import '../../data/models/search_result_model.dart';
import '../../data/models/search_suggestion_model.dart';
import '../../data/repositories/search_repository_impl.dart';

class SearchController extends ChangeNotifier {
  SearchController({required this._repository});

  final SearchRepository _repository;

  bool _isLoading = false;
  bool _isBusy = false;
  String _query = '';
  String? _error;
  List<SearchResultModel> _results = const <SearchResultModel>[];
  List<SearchSuggestionModel> _suggestions = const <SearchSuggestionModel>[];
  SearchFilterModel _filters = const SearchFilterModel();

  bool get isLoading => _isLoading;
  bool get isBusy => _isBusy;
  String get query => _query;
  String? get error => _error;
  List<SearchResultModel> get results => _results;
  List<SearchSuggestionModel> get suggestions => _suggestions;
  SearchFilterModel get filters => _filters;

  Future<void> search(
    String value, {
    SearchFilterModel? filters,
    int page = 1,
    int pageSize = 20,
  }) async {
    _query = value.trim();
    _error = null;
    _isLoading = true;
    notifyListeners();

    try {
      _results = await _repository.search(
        query: _query,
        filters: filters ?? _filters,
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

  Future<void> loadSuggestions(String value) async {
    if (value.trim().isEmpty) {
      _suggestions = const <SearchSuggestionModel>[];
      notifyListeners();
      return;
    }

    _isBusy = true;
    notifyListeners();

    try {
      _suggestions = await _repository.suggestions(value);
    } catch (e) {
      _error = e.toString();
      _suggestions = const <SearchSuggestionModel>[];
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<void> loadFilters() async {
    _isBusy = true;
    notifyListeners();

    try {
      _filters = await _repository.filters();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  void updateFilters(SearchFilterModel filters) {
    _filters = filters;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearResults() {
    _results = const <SearchResultModel>[];
    notifyListeners();
  }
}
