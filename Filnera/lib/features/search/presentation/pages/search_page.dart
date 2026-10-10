import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../admin/data/admin_product_store.dart';
import '../../../../data/repositories/catalog_repository.dart';
import '../../../../data/models/product_model.dart';
import '../widgets/search_bar_widget.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key, this.initialQuery = ''});

  final String initialQuery;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final controller = TextEditingController();
  Timer? _debounce;
  String _query = '';
  List<ProductModel>? _remoteProducts;
  final _catalogRepository = CatalogRepository();

  @override
  void initState() {
    super.initState();
    _query = widget.initialQuery;
    controller.text = widget.initialQuery;
    _loadRemoteProducts();
  }

  Future<void> _loadRemoteProducts() async {
    try {
      final products = await _catalogRepository.fetchProducts();
      if (mounted && products.isNotEmpty) {
        setState(() => _remoteProducts = products);
      }
    } catch (_) {
      // The local catalog remains available when the API is offline.
    }
  }

  @override
  void dispose() {
    controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  List<ProductModel> _results(List<ProductModel> products) {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return products.take(20).toList();
    return products
        .where(
          (item) =>
              item.name.toLowerCase().contains(query) ||
              item.category.toLowerCase().contains(query),
        )
        .take(30)
        .toList();
  }

  @override
  Widget build(BuildContext context) =>
      ValueListenableBuilder<List<ProductModel>>(
        valueListenable: AdminProductStore.products,
        builder: (context, products, _) {
          final results = _results(_remoteProducts ?? products);
          return Scaffold(
            appBar: AppBar(title: const Text('Search products')),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: SearchBarWidget(
                    initialQuery: _query,
                    onChanged: (value) {
                      _debounce?.cancel();
                      _debounce = Timer(const Duration(milliseconds: 220), () {
                        if (mounted) setState(() => _query = value);
                      });
                    },
                    onSearch: (value) {
                      _debounce?.cancel();
                      setState(() => _query = value);
                    },
                  ),
                ),
                if (_query.trim().isNotEmpty) _suggestions(results),
                Expanded(
                  child: ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final product = results[index];
                      return ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            product.imageUrl,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) =>
                                const Icon(Icons.image_not_supported),
                          ),
                        ),
                        title: Text(product.name),
                        subtitle: Text(product.category),
                        trailing: Text('₹${product.price.toStringAsFixed(0)}'),
                        onTap: () => context.push('/product/${product.id}'),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );

  Widget _suggestions(List<ProductModel> results) {
    final suggestions = results.take(4).toList();
    return Align(
      alignment: Alignment.centerLeft,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          children: [
            for (final product in suggestions)
              ListTile(
                dense: true,
                leading: const Icon(Icons.search),
                title: Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  controller.text = product.name;
                  setState(() => _query = product.name);
                },
              ),
          ],
        ),
      ),
    );
  }
}
