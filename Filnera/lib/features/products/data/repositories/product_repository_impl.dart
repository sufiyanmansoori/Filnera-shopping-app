import '../../../../core/network/api_client.dart';
import '../datasources/product_local_datasource.dart';
import '../datasources/product_remote_datasource.dart';
import '../models/category_model.dart';
import '../models/product_detail_model.dart';
import '../models/product_model.dart';
import '../models/product_review_model.dart';
import '../models/product_specification_model.dart';
import '../models/product_variant_model.dart';

abstract class ProductRepository {
  Future<List<ProductModel>> fetchProducts({
    String category,
    int page,
    int pageSize,
  });
  Future<ProductModel> fetchProductById(String id);
  Future<ProductDetailModel> fetchProductDetails(String id);
  Future<List<ProductModel>> fetchSimilarProducts(String productId);
  Future<List<CategoryModel>> fetchCategories();
}

class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl({
    ApiClient? apiClient,
    ProductRemoteDataSource? remoteDataSource,
    ProductLocalDataSource? localDataSource,
  }) : _remoteDataSource =
           remoteDataSource ?? ProductRemoteDataSource(apiClient: apiClient),
       _localDataSource = localDataSource ?? ProductLocalDataSource();

  final ProductRemoteDataSource _remoteDataSource;
  final ProductLocalDataSource _localDataSource;

  @override
  Future<List<ProductModel>> fetchProducts({
    String category = 'all',
    int page = 1,
    int pageSize = 20,
  }) async {
    final cached = await _localDataSource.getCachedProducts();
    if (cached.isNotEmpty) {
      return cached;
    }

    final products = await _remoteDataSource.fetchProducts(
      category: category,
      page: page,
      pageSize: pageSize,
    );
    await _localDataSource.cacheProducts(products);
    return products;
  }

  @override
  Future<ProductModel> fetchProductById(String id) async {
    final cached = await _localDataSource.getCachedProduct(id);
    if (cached != null) return cached;

    final product = await _remoteDataSource.fetchProductById(id);
    await _localDataSource.cacheProduct(product);
    return product;
  }

  @override
  Future<ProductDetailModel> fetchProductDetails(String id) async {
    final cachedProduct = await _localDataSource.getCachedProduct(id);
    if (cachedProduct != null) {
      return ProductDetailModel(
        product: cachedProduct,
        variants: const <ProductVariantModel>[],
        specifications: const <ProductSpecificationModel>[],
        reviews: const <ProductReviewModel>[],
        sellerName: cachedProduct.sellerName,
        deliveryMessage: 'Free delivery available',
        offers: cachedProduct.offers,
        images: cachedProduct.images,
      );
    }

    final product = await _remoteDataSource.fetchProductDetails(id);
    await _localDataSource.cacheProduct(product.product);
    return product;
  }

  @override
  Future<List<ProductModel>> fetchSimilarProducts(String productId) async {
    return await _remoteDataSource.fetchSimilarProducts(productId);
  }

  @override
  Future<List<CategoryModel>> fetchCategories() async {
    return await _remoteDataSource.fetchCategories();
  }
}
