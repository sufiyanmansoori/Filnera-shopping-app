import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/product_provider.dart';
import '../widgets/product_card_widget.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ProductProvider>();
      provider.fetchCategories();
      provider.fetchProducts(refresh: true, query: provider.searchQuery);
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            onPressed: () => _showSortSheet(context),
            icon: const Icon(Icons.sort_rounded),
          ),
        ],
      ),
      body: Consumer<ProductProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.products.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && provider.products.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(provider.error!, textAlign: TextAlign.center),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await provider.fetchCategories();
              await provider.fetchProducts(refresh: true);
            },
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1F5EFF), Color(0xFF4C9CFF)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      'Fresh deals for you',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      'Up to 70% off on branded essentials',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.flash_on_rounded,
                                color: Colors.amber,
                                size: 34,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: searchController,
                          decoration: InputDecoration(
                            hintText: 'Search for products, brands and deals',
                            prefixIcon: const Icon(Icons.search_rounded),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onChanged: (value) {
                            provider.updateFilters(search: value);
                            provider.fetchProducts(
                              refresh: true,
                              category: provider.selectedCategory,
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        if (provider.categories.isNotEmpty)
                          SizedBox(
                            height: 52,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: provider.categories.length + 1,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(width: 8),
                              itemBuilder: (context, index) {
                                if (index == 0) {
                                  final selected =
                                      provider.selectedCategory == 'all';
                                  return ChoiceChip(
                                    label: const Text('All'),
                                    selected: selected,
                                    onSelected: (_) {
                                      provider.updateFilters(category: 'all');
                                      provider.fetchProducts(
                                        refresh: true,
                                        category: 'all',
                                      );
                                    },
                                  );
                                }

                                final category = provider.categories[index - 1];
                                final selected =
                                    provider.selectedCategory ==
                                        category.slug ||
                                    provider.selectedCategory == category.name;
                                return ChoiceChip(
                                  label: Text(category.name),
                                  selected: selected,
                                  onSelected: (_) {
                                    provider.updateFilters(
                                      category: category.slug,
                                    );
                                    provider.fetchProducts(
                                      refresh: true,
                                      category: category.slug,
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${provider.products.length} items',
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            TextButton.icon(
                              onPressed: () => _showFilterSheet(context),
                              icon: const Icon(Icons.filter_list_rounded),
                              label: const Text('Filter'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final product = provider.products[index];
                      return ProductCardWidget(product: product);
                    }, childCount: provider.products.length),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.78,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 12,
                          mainAxisExtent: 260,
                        ),
                  ),
                ),
                if (provider.products.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Center(
                        child: provider.isLoading
                            ? const CircularProgressIndicator()
                            : OutlinedButton(
                                onPressed: () {
                                  provider.fetchProducts(
                                    category: provider.selectedCategory,
                                    page: provider.products.length ~/ 12 + 1,
                                    pageSize: 12,
                                  );
                                },
                                child: const Text('Load more'),
                              ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showSortSheet(BuildContext context) {
    final provider = context.read<ProductProvider>();
    const items = <String, String>{
      'featured': 'Featured',
      'price_low_high': 'Price: Low to High',
      'price_high_low': 'Price: High to Low',
      'customer_rating': 'Customer Ratings',
    };

    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: items.entries.map((entry) {
            final selected = provider.sortBy == entry.key;
            return ListTile(
              title: Text(entry.value),
              trailing: selected ? const Icon(Icons.check) : null,
              onTap: () {
                provider.updateFilters(sortBy: entry.key);
                provider.fetchProducts(
                  refresh: true,
                  category: provider.selectedCategory,
                );
                context.pop();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    final provider = context.read<ProductProvider>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final min = provider.minPrice;
          final max = provider.maxPrice;
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filters',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('In stock only'),
                    value: provider.inStockOnly,
                    onChanged: (value) {
                      provider.updateFilters(inStockOnly: value);
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Price range',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  RangeSlider(
                    values: RangeValues(min, max),
                    min: 0,
                    max: 50000,
                    divisions: 50,
                    labels: RangeLabels('₹${min.round()}', '₹${max.round()}'),
                    onChanged: (value) {
                      provider.updateFilters(
                        minPrice: value.start,
                        maxPrice: value.end,
                      );
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        provider.fetchProducts(
                          refresh: true,
                          category: provider.selectedCategory,
                        );
                        context.pop();
                      },
                      child: const Text('Apply filters'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
