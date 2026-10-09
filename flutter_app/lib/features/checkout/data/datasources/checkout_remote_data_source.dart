import '../../../../core/network/api_client.dart';
import '../models/address_model.dart';
import '../models/checkout_model.dart';
import '../models/delivery_slot_model.dart';

class CheckoutRemoteDataSource {
  CheckoutRemoteDataSource({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<DeliverySlotModel>> fetchDeliverySlots() async {
    final response = await _apiClient.get('/checkout/slots');
    final data = response.data;
    if (data is List) {
      return data
          .map(
            (item) =>
                DeliverySlotModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    }
    if (data is Map<String, dynamic>) {
      final items = data['slots'] as List? ?? const <dynamic>[];
      return items
          .map(
            (item) =>
                DeliverySlotModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    }
    return const <DeliverySlotModel>[];
  }

  Future<List<AddressModel>> fetchSavedAddresses() async {
    final response = await _apiClient.get('/addresses');
    final data = response.data;
    if (data is List) {
      return data
          .map((item) => AddressModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }
    if (data is Map<String, dynamic>) {
      final items = data['items'] as List? ?? const <dynamic>[];
      return items
          .map((item) => AddressModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }
    return const <AddressModel>[];
  }

  Future<CheckoutModel> placeOrder(Map<String, dynamic> payload) async {
    final response = await _apiClient.post(
      '/checkout/place-order',
      data: payload,
    );
    final map = response.data is Map<String, dynamic>
        ? response.data as Map<String, dynamic>
        : Map<String, dynamic>.from(response.data as Map);
    return CheckoutModel.fromJson(map);
  }
}
