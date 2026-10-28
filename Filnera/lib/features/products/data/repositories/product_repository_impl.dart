import '../../../../core/network/api_client.dart';
import 'package:dio/dio.dart';

import '../datasources/product_local_datasource.dart';
import '../datasources/product_remote_datasource.dart';
import '../datasources/storefront_product_fallback_data_source.dart';
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
    StorefrontProductFallbackDataSource? fallbackDataSource,
  }) : _remoteDataSource =
           remoteDataSource ?? ProductRemoteDataSource(apiClient: apiClient),
       _localDataSource = localDataSource ?? ProductLocalDataSource(),
       _fallbackDataSource =
           fallbackDataSource ?? StorefrontProductFallbackDataSource();

  final ProductRemoteDataSource _remoteDataSource;
  final ProductLocalDataSource _localDataSource;
  final StorefrontProductFallbackDataSource _fallbackDataSource;

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

    final product = await _fetchProductOrFallback(id);
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

    try {
      final product = await _remoteDataSource.fetchProductDetails(id);
      await _localDataSource.cacheProduct(product.product);
      return product;
    } on DioException catch (error) {
      if (error.response?.statusCode != 404) rethrow;
      final fallbackProduct = _fallbackDataSource.findById(id);
      if (fallbackProduct == null) rethrow;
      await _localDataSource.cacheProduct(fallbackProduct);
      return _detailsFor(fallbackProduct);
    }
  }

  Future<ProductModel> _fetchProductOrFallback(String id) async {
    try {
      return await _remoteDataSource.fetchProductById(id);
    } on DioException catch (error) {
      if (error.response?.statusCode != 404) rethrow;
      final product = _fallbackDataSource.findById(id);
      if (product == null) rethrow;
      return product;
    }
  }

  ProductDetailModel _detailsFor(ProductModel product) => ProductDetailModel(
    product: product,
    variants: const <ProductVariantModel>[],
    specifications: product.specifications.entries
        .map(
          (entry) => ProductSpecificationModel(
            name: entry.key,
            value: entry.value.toString(),
          ),
        )
        .toList(),
    reviews: const <ProductReviewModel>[],
    sellerName: product.sellerName,
    deliveryMessage: 'Free delivery available',
    offers: product.offers,
    images: product.images,
  );

  @override
  Future<List<ProductModel>> fetchSimilarProducts(String productId) async {
    return await _remoteDataSource.fetchSimilarProducts(productId);
  }

  @override
  Future<List<CategoryModel>> fetchCategories() async {
    return await _remoteDataSource.fetchCategories();
  }
}
