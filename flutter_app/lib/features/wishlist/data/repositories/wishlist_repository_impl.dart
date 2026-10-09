import '../../../../core/network/api_client.dart';
import '../datasources/wishlist_local_datasource.dart';
import '../datasources/wishlist_remote_datasource.dart';
import '../models/wishlist_item_model.dart';
import '../models/wishlist_model.dart';

abstract class WishlistRepository {
  Future<WishlistModel> fetchWishlist(String userId);
  Future<void> addToWishlist(String userId, String productId);
  Future<void> removeFromWishlist(String userId, String productId);
}

class WishlistRepositoryImpl implements WishlistRepository {
  WishlistRepositoryImpl({
    ApiClient? apiClient,
    WishlistRemoteDataSource? remoteDataSource,
    WishlistLocalDataSource? localDataSource,
  }) : _remoteDataSource =
           remoteDataSource ?? WishlistRemoteDataSource(apiClient: apiClient),
       _localDataSource = localDataSource ?? WishlistLocalDataSource();

  final WishlistRemoteDataSource _remoteDataSource;
  final WishlistLocalDataSource _localDataSource;

  @override
  Future<WishlistModel> fetchWishlist(String userId) async {
    try {
      final remote = await _remoteDataSource.fetchWishlist(userId);
      await _localDataSource.saveWishlist(remote);
      return remote;
    } catch (_) {
      final cached = await _localDataSource.getWishlist();
      return cached ??
          WishlistModel(
            items: <WishlistItemModel>[],
            updatedAt: DateTime.now(),
          );
    }
  }

  @override
  Future<void> addToWishlist(String userId, String productId) async {
    await _remoteDataSource.fetchWishlist(userId);
  }

  @override
  Future<void> removeFromWishlist(String userId, String productId) async {
    await _remoteDataSource.fetchWishlist(userId);
  }
}
