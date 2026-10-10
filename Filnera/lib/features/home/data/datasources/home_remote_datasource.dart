import '../../../../core/network/api_client.dart';

/// Remote datasource for the Home feature. It is intentionally aligned with
/// the existing project ApiClient so the service remains fast and modular.
class HomeRemoteDataSource {
  HomeRemoteDataSource({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> getHomePayload() async {
    final response = await _apiClient.get('/home');
    final payload = response.data;
    if (payload is! Map<String, dynamic> && payload is Map) {
      return Map<String, dynamic>.from(payload);
    }
    if (payload is Map<String, dynamic>) {
      return payload;
    }
    throw const FormatException('Invalid home payload');
  }

  Future<Map<String, dynamic>> getPersonalizedDealsPayload({
    required String customerId,
  }) async {
    final response = await _apiClient.get(
      '/home/personalized-deals',
      queryParameters: {'customer_id': customerId},
    );
    final payload = response.data;
    if (payload is! Map<String, dynamic> && payload is Map) {
      return Map<String, dynamic>.from(payload);
    }
    if (payload is Map<String, dynamic>) {
      return payload;
    }
    throw const FormatException('Invalid personalized deals payload');
  }
}
