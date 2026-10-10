import '../../../../core/network/api_client.dart';
import '../models/cart_model.dart';

class CartRemoteDataSource {
  CartRemoteDataSource({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<CartModel> fetchCart(String userId) async {
    final response = await _apiClient.get('/cart/$userId');
    if (response.data is Map<String, dynamic>) {
      return CartModel.fromJson(response.data as Map<String, dynamic>);
    }
    return CartModel.empty();
  }

  Future<CartModel> updateCart(CartModel cart) async {
    final response = await _apiClient.post('/cart/update', data: cart.toJson());
    if (response.data is Map<String, dynamic>) {
      return CartModel.fromJson(response.data as Map<String, dynamic>);
    }
    return cart;
  }
}
