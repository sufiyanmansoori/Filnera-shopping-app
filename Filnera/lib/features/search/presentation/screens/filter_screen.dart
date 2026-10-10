import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/filter_provider.dart';

class FilterScreen extends StatelessWidget {
  const FilterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FilterProvider>(
      builder: (context, provider, _) {
        final filter = provider.filter;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Filters'),
            actions: [
              TextButton(onPressed: provider.reset, child: const Text('Reset')),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              DropdownButtonFormField<String>(
                initialValue: filter.category,
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('All categories')),
                  DropdownMenuItem(value: 'fashion', child: Text('Fashion')),
                  DropdownMenuItem(
                    value: 'electronics',
                    child: Text('Electronics'),
                  ),
                ],
                onChanged: (value) => provider.updateCategory(value ?? 'all'),
              ),
              const SizedBox(height: 16),
              Text(
                'Price range: ${filter.minPrice.toStringAsFixed(0)} - ${filter.maxPrice.toStringAsFixed(0)}',
              ),
              RangeSlider(
                values: RangeValues(filter.minPrice, filter.maxPrice),
                min: 0,
                max: 10000,
                divisions: 100,
                onChanged: (value) =>
                    provider.updatePriceRange(value.start, value.end),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('In stock only'),
                value: filter.inStockOnly,
                onChanged: provider.toggleInStockOnly,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: filter.sortBy,
                items: const [
                  DropdownMenuItem(
                    value: 'relevance',
                    child: Text('Relevance'),
                  ),
                  DropdownMenuItem(
                    value: 'price_low_high',
                    child: Text('Price Low to High'),
                  ),
                  DropdownMenuItem(
                    value: 'price_high_low',
                    child: Text('Price High to Low'),
                  ),
                ],
                onChanged: (value) => provider.updateSort(value ?? 'relevance'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(filter),
                child: const Text('Apply Filters'),
              ),
            ],
          ),
        );
      },
    );
  }
}
