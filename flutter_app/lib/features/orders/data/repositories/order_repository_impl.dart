import '../../../../core/network/api_client.dart';
import '../datasources/order_local_datasource.dart';
import '../datasources/order_remote_datasource.dart';
import '../models/order_model.dart';
import '../models/tracking_model.dart';
import '../models/return_model.dart';

abstract class OrderRepository {
  Future<List<OrderModel>> fetchOrders({String status = 'all'});
  Future<OrderModel> fetchOrderById(String orderId);
  Future<TrackingModel> fetchTracking(String orderId);
  Future<ReturnModel> submitReturn(String orderId, String reason);
}

class OrderRepositoryImpl implements OrderRepository {
  OrderRepositoryImpl({
    ApiClient? apiClient,
    OrderRemoteDataSource? remoteDataSource,
    OrderLocalDataSource? localDataSource,
  }) : _remoteDataSource =
           remoteDataSource ?? OrderRemoteDataSource(apiClient: apiClient),
       _localDataSource = localDataSource ?? OrderLocalDataSource();

  final OrderRemoteDataSource _remoteDataSource;
  final OrderLocalDataSource _localDataSource;

  @override
  Future<List<OrderModel>> fetchOrders({String status = 'all'}) async {
    final cached = await _localDataSource.getCachedOrders();
    if (cached.isNotEmpty) return cached;

    final remote = await _remoteDataSource.fetchOrders(status: status);
    await _localDataSource.cacheOrders(remote);
    return remote;
  }

  @override
  Future<OrderModel> fetchOrderById(String orderId) async {
    return await _remoteDataSource.fetchOrderById(orderId);
  }

  @override
  Future<TrackingModel> fetchTracking(String orderId) async {
    return await _remoteDataSource.fetchTracking(orderId);
  }

  @override
  Future<ReturnModel> submitReturn(String orderId, String reason) async {
    return await _remoteDataSource.submitReturn(orderId, reason);
  }
}
