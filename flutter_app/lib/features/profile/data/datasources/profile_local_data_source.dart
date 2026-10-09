import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/address_model.dart';
import '../models/user_profile_model.dart';

class ProfileLocalDataSource {
  ProfileLocalDataSource([SharedPreferences? sharedPreferences])
    : _sharedPreferences = sharedPreferences;

  final SharedPreferences? _sharedPreferences;

  static const String _profileKey = 'profile_data';
  static const String _addressesKey = 'profile_addresses';

  Future<SharedPreferences> get _prefs async =>
      _sharedPreferences ?? await SharedPreferences.getInstance();

  Future<UserProfileModel?> loadProfile() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_profileKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return UserProfileModel.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveProfile(UserProfileModel profile) async {
    final prefs = await _prefs;
    await prefs.setString(_profileKey, jsonEncode(profile.toJson()));
  }

  Future<List<AddressModel>> loadAddresses() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_addressesKey);
    if (raw == null || raw.isEmpty) {
      return const <AddressModel>[];
    }

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((item) => AddressModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (_) {
      return const <AddressModel>[];
    }
  }

  Future<void> saveAddresses(List<AddressModel> addresses) async {
    final prefs = await _prefs;
    await prefs.setString(
      _addressesKey,
      jsonEncode(addresses.map((address) => address.toJson()).toList()),
    );
  }
}
