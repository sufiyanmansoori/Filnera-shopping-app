import '../../../../core/network/api_client.dart';
import '../models/category_model.dart';
import '../models/product_detail_model.dart';
import '../models/product_model.dart';

class ProductRemoteDataSource {
  ProductRemoteDataSource({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<ProductModel>> fetchProducts({
    String category = 'all',
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _apiClient.get(
      '/products',
      queryParameters: {
        'category': category,
        'page': page,
        'page_size': pageSize,
      },
    );

    final data = response.data;
    if (data is List) {
      return data
          .map((item) => ProductModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }
    if (data is Map<String, dynamic>) {
      final items = data['items'] as List? ?? const <dynamic>[];
      return items
          .map((item) => ProductModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }
    return const <ProductModel>[];
  }

  Future<ProductModel> fetchProductById(String id) async {
    final response = await _apiClient.get('/products/$id');
    return ProductModel.fromJson(_unwrapProduct(response.data));
  }

  Future<ProductDetailModel> fetchProductDetails(String id) async {
    final response = await _apiClient.get('/products/$id');
    return ProductDetailModel.fromJson(
      _unwrapProduct(response.data),
    );
  }

  Map<String, dynamic> _unwrapProduct(dynamic responseData) {
    if (responseData is! Map) {
      throw const FormatException('Product response must be a JSON object.');
    }
    final response = Map<String, dynamic>.from(responseData);
    final payload = response['data'];
    return payload is Map
        ? Map<String, dynamic>.from(payload)
        : response;
  }

  Future<List<ProductModel>> fetchSimilarProducts(String productId) async {
    final response = await _apiClient.get('/products/$productId/similar');
    final data = response.data;
    if (data is List) {
      return data
          .map((item) => ProductModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }
    if (data is Map<String, dynamic>) {
      final items = data['items'] as List? ?? const <dynamic>[];
      return items
          .map((item) => ProductModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }
    return const <ProductModel>[];
  }

  Future<List<CategoryModel>> fetchCategories() async {
    final response = await _apiClient.get('/categories');
    final data = response.data;
    if (data is List) {
      return data
          .map(
            (item) => CategoryModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    }
    if (data is Map<String, dynamic>) {
      final items = data['items'] as List? ?? const <dynamic>[];
      return items
          .map(
            (item) => CategoryModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    }
    return const <CategoryModel>[];
  }
}
