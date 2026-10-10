import '../datasources/profile_local_data_source.dart';
import '../datasources/profile_remote_data_source.dart';
import '../models/address_model.dart';
import '../models/user_profile_model.dart';

class ProfileRepositoryImpl {
  const ProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  final ProfileRemoteDataSource remoteDataSource;
  final ProfileLocalDataSource localDataSource;

  Future<UserProfileModel> getProfile() async {
    final localProfile = await localDataSource.loadProfile();
    if (localProfile != null) {
      return localProfile;
    }

    final remoteProfile = await remoteDataSource.fetchProfile();
    await localDataSource.saveProfile(remoteProfile);
    return remoteProfile;
  }

  Future<UserProfileModel> updateProfile(UserProfileModel profile) async {
    await localDataSource.saveProfile(profile);
    return profile;
  }

  Future<List<AddressModel>> getAddresses() async {
    final localAddresses = await localDataSource.loadAddresses();
    if (localAddresses.isNotEmpty) {
      return localAddresses;
    }

    final remoteAddresses = await remoteDataSource.fetchAddresses();
    await localDataSource.saveAddresses(remoteAddresses);
    return remoteAddresses;
  }

  Future<List<AddressModel>> addAddress(AddressModel address) async {
    final addresses = await getAddresses();
    final updated = [...addresses, address];
    await localDataSource.saveAddresses(updated);
    return updated;
  }

  Future<List<AddressModel>> updateAddress(AddressModel address) async {
    final addresses = await getAddresses();
    final updated = addresses.map((item) {
      if (item.id == address.id) {
        return address;
      }
      return item;
    }).toList();

    await localDataSource.saveAddresses(updated);
    return updated;
  }

  Future<List<AddressModel>> removeAddress(String id) async {
    final addresses = await getAddresses();
    final updated = addresses.where((address) => address.id != id).toList();
    await localDataSource.saveAddresses(updated);
    return updated;
  }

  Future<List<AddressModel>> setDefaultAddress(String id) async {
    final addresses = await getAddresses();
    final updated = addresses
        .map((address) => address.copyWith(isDefault: address.id == id))
        .toList();
    await localDataSource.saveAddresses(updated);
    return updated;
  }
}
