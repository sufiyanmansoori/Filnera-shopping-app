import '../../../../core/network/api_client.dart';
import '../models/wishlist_item_model.dart';
import '../models/wishlist_model.dart';

class WishlistRemoteDataSource {
  WishlistRemoteDataSource({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<WishlistModel> fetchWishlist(String userId) async {
    final response = await _apiClient.get('/wishlist/$userId');
    if (response.data is Map<String, dynamic>) {
      return WishlistModel.fromJson(response.data as Map<String, dynamic>);
    }
    return WishlistModel(
      items: <WishlistItemModel>[],
      updatedAt: DateTime.now(),
    );
  }
}
