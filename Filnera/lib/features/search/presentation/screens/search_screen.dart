import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/search_provider.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/search_suggestions_widget.dart';
import '../widgets/search_result_tile_widget.dart';
import '../widgets/no_results_widget.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Consumer<SearchProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              SearchBarWidget(
                onSearch: (value) => provider.search(value),
                onChanged: (value) => provider.fetchSuggestions(value),
              ),
              if (provider.isLoading) const LinearProgressIndicator(),
              if (provider.error != null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    provider.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              Expanded(
                child: provider.suggestions.isNotEmpty
                    ? SearchSuggestionsWidget(suggestions: provider.suggestions)
                    : provider.results.isEmpty
                    ? const NoResultsWidget()
                    : ListView.builder(
                        itemCount: provider.results.length,
                        itemBuilder: (context, index) {
                          final result = provider.results[index];
                          return SearchResultTileWidget(result: result);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
