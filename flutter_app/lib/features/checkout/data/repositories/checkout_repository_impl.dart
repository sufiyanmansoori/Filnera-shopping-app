import '../datasources/checkout_local_data_source.dart';
import '../datasources/checkout_remote_data_source.dart';
import '../models/address_model.dart';
import '../models/checkout_model.dart';
import '../models/delivery_slot_model.dart';

abstract class CheckoutRepository {
  Future<List<AddressModel>> fetchSavedAddresses();
  Future<List<DeliverySlotModel>> fetchDeliverySlots();
  Future<CheckoutModel> placeOrder(Map<String, dynamic> payload);
  Future<void> saveAddress(AddressModel address);
}

class CheckoutRepositoryImpl implements CheckoutRepository {
  CheckoutRepositoryImpl({
    CheckoutRemoteDataSource? remoteDataSource,
    CheckoutLocalDataSource? localDataSource,
  }) : _remoteDataSource = remoteDataSource ?? CheckoutRemoteDataSource(),
       _localDataSource = localDataSource ?? CheckoutLocalDataSource();

  final CheckoutRemoteDataSource _remoteDataSource;
  final CheckoutLocalDataSource _localDataSource;

  @override
  Future<List<AddressModel>> fetchSavedAddresses() async {
    final cached = await _localDataSource.getSavedAddresses();
    if (cached.isNotEmpty) {
      return cached;
    }

    final addresses = await _remoteDataSource.fetchSavedAddresses();
    await _localDataSource.saveAddresses(addresses);
    return addresses;
  }

  @override
  Future<List<DeliverySlotModel>> fetchDeliverySlots() async {
    final cached = await _localDataSource.getDeliverySlots();
    if (cached.isNotEmpty) {
      return cached;
    }

    final slots = await _remoteDataSource.fetchDeliverySlots();
    await _localDataSource.saveDeliverySlots(slots);
    return slots;
  }

  @override
  Future<CheckoutModel> placeOrder(Map<String, dynamic> payload) async {
    return _remoteDataSource.placeOrder(payload);
  }

  @override
  Future<void> saveAddress(AddressModel address) async {
    final current = await _localDataSource.getSavedAddresses();
    final updated = <AddressModel>[];
    for (final item in current) {
      if (item.id == address.id) {
        updated.add(address);
      } else {
        updated.add(item);
      }
    }
    if (!updated.any((item) => item.id == address.id)) {
      updated.add(address);
    }
    await _localDataSource.saveAddresses(updated);
  }
}
