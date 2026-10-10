import 'package:flutter/material.dart';

import '../../data/models/search_suggestion_model.dart';

class SearchSuggestionsWidget extends StatelessWidget {
  const SearchSuggestionsWidget({
    super.key,
    required this.suggestions,
    this.onSelected,
  });

  final List<SearchSuggestionModel> suggestions;
  final ValueChanged<String>? onSelected;

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: suggestions.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = suggestions[index];
        return ListTile(
          leading: const Icon(Icons.history_outlined),
          title: Text(item.text),
          subtitle: item.category.isNotEmpty ? Text(item.category) : null,
          trailing: item.score > 0 ? Text(item.score.toStringAsFixed(1)) : null,
          onTap: () => onSelected?.call(item.text),
        );
      },
    );
  }
}
