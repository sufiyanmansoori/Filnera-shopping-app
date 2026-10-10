import '../../../../core/network/api_client.dart';
import '../datasources/cart_local_datasource.dart';
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
    CartLocalDataSource? localDataSource,
  }) : _remoteDataSource =
           remoteDataSource ?? CartRemoteDataSource(apiClient: apiClient),
       _localDataSource = localDataSource ?? CartLocalDataSource();

  final CartRemoteDataSource _remoteDataSource;
  final CartLocalDataSource _localDataSource;

  @override
  Future<CartModel> fetchCart(String userId) async {
    try {
      final cart = await _remoteDataSource.fetchCart(userId);
      await _localDataSource.saveCart(cart);
      return cart;
    } catch (_) {
      final cached = await _localDataSource.getCart();
      return cached ?? CartModel.empty();
    }
  }

  @override
  Future<CartModel> updateCart(CartModel cart) async {
    try {
      final remote = await _remoteDataSource.updateCart(cart);
      await _localDataSource.saveCart(remote);
      return remote;
    } catch (_) {
      await _localDataSource.saveCart(cart);
      return cart;
    }
  }

  @override
  Future<List<CouponModel>> fetchCoupons() async {
    return const <CouponModel>[
      CouponModel(
        code: 'WELCOME10',
        discount: 10,
        type: 'percent',
        description: '10% welcome discount',
        isActive: true,
      ),
      CouponModel(
        code: 'SAVE200',
        discount: 200,
        type: 'flat',
        description: 'Flat ₹200 off',
        isActive: true,
      ),
    ];
  }
}
