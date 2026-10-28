import '../../../../core/network/api_client.dart';
import '../models/cart_model.dart';

class CartRemoteDataSource {
  CartRemoteDataSource({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<CartModel> fetchCart(String userId) async {
    final response = await _apiClient.get('/cart');
    return _parseCart(response.data);
  }

  Future<CartModel> updateCart(CartModel desiredCart) async {
    var current = await fetchCart('');

    for (final item in current.items) {
      final desired = desiredCart.items.where(
        (entry) => entry.productId == item.productId,
      );
      if (desired.isEmpty) {
        current = await _mutate(
          () => _apiClient.delete(
            '/cart/items/${Uri.encodeComponent(item.productId)}',
          ),
        );
      } else if (desired.first.quantity != item.quantity) {
        current = await _mutate(
          () => _apiClient.put(
            '/cart/items/${Uri.encodeComponent(item.productId)}',
            data: {'quantity': desired.first.quantity},
          ),
        );
      }
    }

    for (final item in desiredCart.items) {
      if (!current.items.any((entry) => entry.productId == item.productId)) {
        current = await _mutate(
          () => _apiClient.post(
            '/cart/items',
            data: {'productId': item.productId, 'quantity': item.quantity},
          ),
        );
      }
    }
    return current;
  }

  Future<CartModel> _mutate(Future<dynamic> Function() request) async =>
      _parseCart((await request()).data);

  CartModel _parseCart(dynamic body) {
    if (body is Map) {
      final envelope = Map<String, dynamic>.from(body);
      final data = envelope['data'];
      if (data is Map) return CartModel.fromJson(Map<String, dynamic>.from(data));
    }
    throw const FormatException('The server returned an invalid cart response.');
  }
}
