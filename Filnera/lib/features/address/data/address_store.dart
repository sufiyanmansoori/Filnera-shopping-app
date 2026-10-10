import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeliveryAddress {
  const DeliveryAddress({
    required this.id,
    required this.name,
    required this.phone,
    required this.house,
    required this.city,
    required this.state,
    required this.pincode,
  });

  final String id;
  final String name;
  final String phone;
  final String house;
  final String city;
  final String state;
  final String pincode;

  String get formatted => '$house, $city, $state - $pincode';

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'house': house,
    'city': city,
    'state': state,
    'pincode': pincode,
  };

  factory DeliveryAddress.fromJson(Map<String, dynamic> json) =>
      DeliveryAddress(
        id: json['id'] as String,
        name: json['name'] as String,
        phone: json['phone'] as String,
        house: json['house'] as String,
        city: json['city'] as String,
        state: json['state'] as String,
        pincode: json['pincode'] as String,
      );
}

class AddressStore {
  static final addresses = ValueNotifier<List<DeliveryAddress>>([]);
  static final selected = ValueNotifier<DeliveryAddress?>(null);

  static Future<void> load() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString('delivery_addresses');
    if (raw == null) return;
    final decoded = (jsonDecode(raw) as List)
        .map((item) => DeliveryAddress.fromJson(item as Map<String, dynamic>))
        .toList();
    addresses.value = decoded;
    final selectedId = preferences.getString('selected_delivery_address');
    selected.value = decoded.cast<DeliveryAddress?>().firstWhere(
      (item) => item!.id == selectedId,
      orElse: () => decoded.isEmpty ? null : decoded.first,
    );
  }

  static Future<void> save(DeliveryAddress address) async {
    final next = [
      ...addresses.value.where((item) => item.id != address.id),
      address,
    ];
    addresses.value = next;
    selected.value = address;
    await _persist();
  }

  static Future<void> remove(String id) async {
    addresses.value = addresses.value.where((item) => item.id != id).toList();
    if (selected.value?.id == id) {
      selected.value = addresses.value.isEmpty ? null : addresses.value.first;
    }
    await _persist();
  }

  static Future<void> choose(DeliveryAddress address) async {
    selected.value = address;
    await _persist();
  }

  static Future<void> _persist() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      'delivery_addresses',
      jsonEncode(addresses.value.map((item) => item.toJson()).toList()),
    );
    final id = selected.value?.id;
    if (id == null) {
      await preferences.remove('selected_delivery_address');
    } else {
      await preferences.setString('selected_delivery_address', id);
    }
  }
}
