import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/search_history_model.dart';
import '../models/search_result_model.dart';

class SearchLocalDataSource {
  static const String _historyKey = 'search_history_v1';
  static const String _lastResultsKey = 'search_last_results_v1';

  Future<List<SearchHistoryModel>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_historyKey) ?? <String>[];

    return raw
        .map((value) => SearchHistoryModel.fromJson(jsonDecode(value)))
        .toList();
  }

  Future<void> saveHistory(SearchHistoryModel history) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await getHistory();

    final existing = all.where((item) => item.query == history.query).toList();
    for (final item in existing) {
      all.remove(item);
    }

    all.insert(0, history);
    final values = all
        .take(30)
        .map((item) => jsonEncode(item.toJson()))
        .toList();
    await prefs.setStringList(_historyKey, values);
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  Future<List<SearchResultModel>> getLastResults() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_lastResultsKey) ?? <String>[];

    return raw
        .map((value) => SearchResultModel.fromJson(jsonDecode(value)))
        .toList();
  }

  Future<void> saveLastResults(List<SearchResultModel> results) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = results.map((item) => jsonEncode(item.toJson())).toList();
    await prefs.setStringList(_lastResultsKey, payload);
  }
}
