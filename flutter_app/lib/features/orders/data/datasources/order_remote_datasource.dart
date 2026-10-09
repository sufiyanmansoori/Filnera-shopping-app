import '../../../../core/network/api_client.dart';
import '../models/order_model.dart';
import '../models/tracking_model.dart';
import '../models/return_model.dart';

class OrderRemoteDataSource {
  OrderRemoteDataSource({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<OrderModel>> fetchOrders({String status = 'all'}) async {
    final response = await _apiClient.get(
      '/orders',
      queryParameters: {'status': status},
    );

    final data = response.data;
    if (data is List) {
      return data
          .map((item) => OrderModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }
    if (data is Map<String, dynamic>) {
      final items = data['items'] as List? ?? const <dynamic>[];
      return items
          .map((item) => OrderModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }
    return const <OrderModel>[];
  }

  Future<OrderModel> fetchOrderById(String orderId) async {
    final response = await _apiClient.get('/orders/$orderId');
    return OrderModel.fromJson(Map<String, dynamic>.from(response.data));
  }

  Future<TrackingModel> fetchTracking(String orderId) async {
    final response = await _apiClient.get('/orders/$orderId/tracking');
    return TrackingModel.fromJson(Map<String, dynamic>.from(response.data));
  }

  Future<ReturnModel> submitReturn(String orderId, String reason) async {
    final response = await _apiClient.post(
      '/orders/$orderId/returns',
      data: {'reason': reason},
    );
    return ReturnModel.fromJson(Map<String, dynamic>.from(response.data));
  }
}
