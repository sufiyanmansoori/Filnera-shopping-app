import '../../../../core/network/api_client.dart';
import '../datasources/cart_remote_datasource.dart';
import '../models/cart_model.dart';
import '../models/coupon_model.dart';

abstract class CartRepository {
  Future<CartModel> fetchCart(String userId);
  Future<CartModel> updateCart(CartModel cart);
  Future<List<CouponModel>> fetchCoupons();
}

class CartRepositoryImpl implements CartRepository {
  CartRepositoryImpl({
    ApiClient? apiClient,
    CartRemoteDataSource? remoteDataSource,
  }) : _remoteDataSource =
           remoteDataSource ?? CartRemoteDataSource(apiClient: apiClient);

  final CartRemoteDataSource _remoteDataSource;

  @override
  Future<CartModel> fetchCart(String userId) =>
      _remoteDataSource.fetchCart(userId);

  @override
  Future<CartModel> updateCart(CartModel cart) =>
      _remoteDataSource.updateCart(cart);

  @override
  Future<List<CouponModel>> fetchCoupons() async => const <CouponModel>[];
}
