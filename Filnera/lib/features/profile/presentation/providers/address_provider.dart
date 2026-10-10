import 'package:flutter/foundation.dart';

import '../../data/datasources/profile_local_data_source.dart';
import '../../data/datasources/profile_remote_data_source.dart';
import '../../data/models/address_model.dart';
import '../../data/repositories/profile_repository_impl.dart';

class AddressProvider extends ChangeNotifier {
  AddressProvider({ProfileRepositoryImpl? repository})
    : _repository =
          repository ??
          ProfileRepositoryImpl(
            remoteDataSource: const ProfileRemoteDataSource(),
            localDataSource: ProfileLocalDataSource(),
          );

  final ProfileRepositoryImpl _repository;

  bool _isLoading = false;
  bool _isSubmitting = false;
  List<AddressModel> _addresses = const <AddressModel>[];
  String? _errorMessage;

  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  List<AddressModel> get addresses => _addresses;
  String? get errorMessage => _errorMessage;

  Future<void> loadAddresses() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _addresses = await _repository.getAddresses();
    } catch (_) {
      _errorMessage = 'Unable to load addresses.';
      _addresses = const <AddressModel>[];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addAddress(AddressModel address) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _repository.addAddress(address);
      _addresses = updated;
    } catch (_) {
      _errorMessage = 'Address could not be added.';
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> updateAddress(AddressModel address) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _repository.updateAddress(address);
      _addresses = updated;
    } catch (_) {
      _errorMessage = 'Address could not be updated.';
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> removeAddress(String id) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _repository.removeAddress(id);
      _addresses = updated;
    } catch (_) {
      _errorMessage = 'Address could not be removed.';
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> setDefaultAddress(String id) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _repository.setDefaultAddress(id);
      _addresses = updated;
    } catch (_) {
      _errorMessage = 'Unable to update default address.';
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
