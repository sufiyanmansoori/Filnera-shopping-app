import '../../core/network/api_client.dart';
import '../../data/models/product_model.dart';

class CatalogRepository {
  CatalogRepository({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<List<ProductModel>> fetchProducts({
    String query = '',
    String? category,
  }) async {
    final response = await _client.get(
      '/products',
      queryParameters: {
        if (query.trim().isNotEmpty) 'q': query.trim(),
        if (category != null && category.trim().isNotEmpty)
          'category': category.trim(),
      },
    );
    final body = response.data;
    final data = body is Map ? body['data'] : null;
    final rawItems = data is Map ? data['items'] : null;
    if (rawItems is! List) return const [];

    return rawItems
        .whereType<Map>()
        .map((item) => ProductModel.fromJson(Map<String, dynamic>.from(item)))
        .where((product) {
          final normalizedQuery = query.trim().toLowerCase();
          final matchesQuery =
              normalizedQuery.isEmpty ||
              '${product.name} ${product.category}'.toLowerCase().contains(
                normalizedQuery,
              );
          final matchesCategory =
              category == null ||
              category.trim().isEmpty ||
              product.category.toLowerCase() == category.toLowerCase();
          return matchesQuery && matchesCategory;
        })
        .toList();
  }
}
