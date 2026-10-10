import 'package:flutter/material.dart';

class SortOptionsWidget extends StatelessWidget {
  const SortOptionsWidget({
    super.key,
    required this.sortBy,
    required this.onSortChanged,
  });

  final String sortBy;
  final ValueChanged<String> onSortChanged;

  @override
  Widget build(BuildContext context) {
    const options = <String, String>{
      'relevance': 'Relevance',
      'price_asc': 'Price: Low to High',
      'price_desc': 'Price: High to Low',
      'rating': 'Rating',
      'newest': 'Newest',
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.sort),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: options.containsKey(sortBy) ? sortBy : 'relevance',
                items: options.entries
                    .map(
                      (entry) => DropdownMenuItem<String>(
                        value: entry.key,
                        child: Text(entry.value),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) onSortChanged(value);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
