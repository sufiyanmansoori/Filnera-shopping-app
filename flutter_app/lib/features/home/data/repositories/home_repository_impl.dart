import '../../../../core/network/api_client.dart';
import '../../domain/entities/featured_product_entity.dart';
import '../../domain/entities/home_data_entity.dart';
import '../../domain/entities/home_entity.dart' as legacy;
import '../../domain/entities/recommendation_entity.dart';
import '../../domain/usecases/get_featured_products_usecase.dart';
import '../../domain/usecases/get_home_categories_usecase.dart';
import '../../domain/usecases/get_recommendations_usecase.dart';
import '../datasources/category_home_datasource.dart';
import '../datasources/featured_products_datasource.dart';
import '../datasources/home_cache_datasource.dart';
import '../datasources/home_local_datasource.dart';
import '../datasources/home_remote_datasource.dart';
import '../datasources/home_remote_datasource_impl.dart';
import '../datasources/home_sync_datasource.dart';
import '../datasources/recommendation_remote_datasource.dart';
import '../datasources/recommendation_remote_datasource_impl.dart';
import '../models/home_data_model.dart';
import '../models/home_response_model.dart';
import '../models/deal_response_model.dart';
import 'home_repository.dart';

class HomeRepositoryImpl
    implements
        HomeRepository,
        HomeRecommendationsRepository,
        HomeFeaturedProductsRepository,
        HomeCategoriesRepository {
  HomeRepositoryImpl({
    ApiClient? apiClient,
    HomeRemoteDataSource? remoteDataSource,
    HomeLocalDataSource? localDataSource,
    RecommendationRemoteDataSource? recommendationDataSource,
    FeaturedProductsDataSource? featuredProductsDataSource,
    CategoryHomeDataSource? categoryDataSource,
    HomeSyncDataSource? syncDataSource,
  }) : _remoteDataSource =
           remoteDataSource ?? HomeRemoteDataSourceImpl(apiClient: apiClient),
       _localDataSource = localDataSource ?? HomeCacheDataSource(),
       _recommendationDataSource =
           recommendationDataSource ??
           RecommendationRemoteDataSourceImpl(apiClient: apiClient),
       _featuredProductsDataSource =
           featuredProductsDataSource ??
           FeaturedProductsDataSource(apiClient: apiClient),
       _categoryDataSource =
           categoryDataSource ?? CategoryHomeDataSource(apiClient: apiClient),
       _syncDataSource = syncDataSource ?? HomeSyncDataSource();

  final HomeRemoteDataSource _remoteDataSource;
  final HomeLocalDataSource _localDataSource;
  final RecommendationRemoteDataSource _recommendationDataSource;
  final FeaturedProductsDataSource _featuredProductsDataSource;
  final CategoryHomeDataSource _categoryDataSource;
  final HomeSyncDataSource _syncDataSource;

  @override
  Future<List<HomeCategoryEntity>> getCategories({
    bool forceRefresh = false,
    bool activeOnly = true,
    String? searchQuery,
    String? parentId,
    int page = 1,
    int pageSize = 50,
    String? locale,
    String? country,
  }) {
    return _categoryDataSource.fetchCategories(
      forceRefresh: forceRefresh,
      activeOnly: activeOnly,
      searchQuery: searchQuery,
      parentId: parentId,
      page: page,
      pageSize: pageSize,
      locale: locale,
      country: country,
    );
  }

  @override
  Future<List<FeaturedProductEntity>> getFeaturedProducts({
    int page = 1,
    int pageSize = 12,
    bool forceRefresh = false,
    String? locale,
    String? currency,
    String? country,
    String? deviceType,
    String? categoryId,
  }) {
    return _featuredProductsDataSource.fetchFeaturedProducts(
      page: page,
      pageSize: pageSize,
      forceRefresh: forceRefresh,
      locale: locale,
      currency: currency,
      country: country,
      deviceType: deviceType,
      categoryId: categoryId,
    );
  }

  @override
  Future<List<RecommendationEntity>> getRecommendations({
    int page = 1,
    int pageSize = 10,
    bool forceRefresh = false,
    String? locale,
    String? currency,
    String? country,
    String? deviceType,
    String? userId,
    List<String> recentlyViewed = const <String>[],
    List<String> favoriteCategories = const <String>[],
  }) {
    return _recommendationDataSource.fetchRecommendations(
      page: page,
      pageSize: pageSize,
      forceRefresh: forceRefresh,
      locale: locale,
      currency: currency,
      country: country,
      deviceType: deviceType,
      userId: userId,
      recentlyViewed: recentlyViewed,
      favoriteCategories: favoriteCategories,
    );
  }

  @override
  Future<HomeDataEntity> getHomeData({
    String? userId,
    String? locale,
    String? currency,
    String? country,
    String? deviceType,
    bool forceRefresh = false,
  }) async {
    final result = await _syncDataSource.syncHomePayload(
      localDataSource: _localDataSource,
      fetchRemote: _remoteDataSource.getHomePayload,
      forceRefresh: forceRefresh,
    );
    return _fromPayload(result.payload);
  }

  @override
  Future<void> cacheHomeData({
    required HomeDataEntity data,
    String? userId,
    String? locale,
    String? currency,
    String? country,
    String? deviceType,
  }) async {
    await _localDataSource.saveHomePayload(_toPayload(data));
  }

  @override
  Future<HomeDataEntity> refreshHomeData({
    String? userId,
    String? locale,
    String? currency,
    String? country,
    String? deviceType,
    bool forceRefresh = true,
  }) async {
    return getHomeData(
      userId: userId,
      locale: locale,
      currency: currency,
      country: country,
      deviceType: deviceType,
      forceRefresh: forceRefresh,
    );
  }

  @override
  Future<legacy.HomePageEntity> getHomePage() async {
    final data = await getHomeData();
    return _legacyHomePage(data);
  }

  @override
  Future<List<legacy.HomeDealEntity>> getPersonalizedDeals({
    required String customerId,
  }) async {
    final payload = await _remoteDataSource.getPersonalizedDealsPayload(
      customerId: customerId,
    );
    final response = DealResponseModel.fromValue(payload);
    if (!response.isSuccessful) return const <legacy.HomeDealEntity>[];

    return response.deals.map((item) => item.deal.toLegacy()).toList();
  }

  HomeDataEntity _fromPayload(Map<String, dynamic> payload) {
    final response = HomeResponseModel.fromJson(payload);
    if (!response.isSuccessful) {
      final message = response.errors.isNotEmpty
          ? response.errors.join('; ')
          : response.message ?? 'Home data request failed';
      throw FormatException(message);
    }
    return response.data.toEntity();
  }

  Map<String, dynamic> _toPayload(HomeDataEntity data) =>
      HomeDataModel.fromEntity(data).toJson();

  legacy.HomePageEntity _legacyHomePage(HomeDataEntity data) {
    return legacy.HomePageEntity(
      banners: data.banners,
      categories: data.categories
          .map(
            (item) => legacy.HomeCategoryEntity(
              id: item.id,
              name: item.name,
              imageUrl: item.imageUrl ?? '',
              slug: item.slug,
            ),
          )
          .toList(),
      deals: data.deals
          .map(
            (item) => legacy.HomeDealEntity(
              id: item.id,
              title: item.title,
              discount: '${item.discountPercent.toStringAsFixed(0)}%',
              productId: item.productId,
              productName: item.productName,
              price: item.currentPrice,
              imageUrl: item.imageUrl,
            ),
          )
          .toList(),
      products: data.featuredProducts
          .map(
            (item) => legacy.HomeProductEntity(
              id: item.id,
              name: item.title,
              price: item.price,
              imageUrl: item.imageUrl,
              rating: item.rating,
            ),
          )
          .toList(),
      updatedAt: data.lastUpdated ?? DateTime.now(),
    );
  }
}
