import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/address_model.dart';
import '../models/delivery_slot_model.dart';

class CheckoutLocalDataSource {
  static const String _addressesKey = 'checkout_addresses';
  static const String _slotsKey = 'checkout_slots';

  Future<List<AddressModel>> getSavedAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_addressesKey);
    if (raw == null || raw.isEmpty) {
      return const <AddressModel>[];
    }

    try {
      final decoded = jsonDecode(raw) as List;
      return decoded
          .map((item) => AddressModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (_) {
      return const <AddressModel>[];
    }
  }

  Future<void> saveAddresses(List<AddressModel> addresses) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _addressesKey,
      jsonEncode(addresses.map((address) => address.toJson()).toList()),
    );
  }

  Future<List<DeliverySlotModel>> getDeliverySlots() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_slotsKey);
    if (raw == null || raw.isEmpty) {
      return const <DeliverySlotModel>[];
    }

    try {
      final decoded = jsonDecode(raw) as List;
      return decoded
          .map(
            (item) =>
                DeliverySlotModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    } catch (_) {
      return const <DeliverySlotModel>[];
    }
  }

  Future<void> saveDeliverySlots(List<DeliverySlotModel> slots) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _slotsKey,
      jsonEncode(slots.map((slot) => slot.toJson()).toList()),
    );
  }
}
