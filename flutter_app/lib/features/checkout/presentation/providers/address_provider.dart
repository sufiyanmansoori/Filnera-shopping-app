import 'package:flutter/foundation.dart';

import '../../data/models/address_model.dart';
import '../../data/repositories/checkout_repository_impl.dart';

class AddressProvider extends ChangeNotifier {
  AddressProvider({CheckoutRepository? repository})
    : _repository = repository ?? CheckoutRepositoryImpl();

  final CheckoutRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;
  List<AddressModel> _addresses = const <AddressModel>[];
  AddressModel? _selectedAddress;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<AddressModel> get addresses => _addresses;
  AddressModel? get selectedAddress => _selectedAddress;

  Future<void> loadAddresses() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _addresses = await _repository.fetchSavedAddresses();
      _selectedAddress =
          _addresses.where((address) => address.isDefault).firstOrNull ??
          _addresses.firstOrNull;
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectAddress(AddressModel address) {
    _selectedAddress = address;
    notifyListeners();
  }

  Future<void> saveAddress(AddressModel address) async {
    try {
      await _repository.saveAddress(address);
      _addresses = [..._addresses, address];
      _selectedAddress = address;
      notifyListeners();
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
    }
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
