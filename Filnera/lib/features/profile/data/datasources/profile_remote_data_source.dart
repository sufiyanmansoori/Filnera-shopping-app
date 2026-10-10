import '../models/address_model.dart';
import '../models/user_profile_model.dart';

class ProfileRemoteDataSource {
  const ProfileRemoteDataSource();

  Future<UserProfileModel> fetchProfile() async {
    await Future<void>.delayed(const Duration(milliseconds: 450));

    return const UserProfileModel(
      id: 'user-1001',
      firstName: 'Aisha',
      lastName: 'Rahman',
      email: 'aisha.rahman@manara.app',
      phone: '+91 98765 43210',
      avatarUrl: '',
      city: 'Bengaluru',
      country: 'India',
      bio: 'Shopper, explorer, and home essentials lover.',
      emailVerified: true,
      phoneVerified: true,
      createdAt: null,
    );
  }

  Future<List<AddressModel>> fetchAddresses() async {
    await Future<void>.delayed(const Duration(milliseconds: 450));

    return [
      const AddressModel(
        id: 'addr_1',
        label: 'Home',
        fullName: 'Aisha Rahman',
        phone: '+91 98765 43210',
        street: '12th Main Road, Koramangala',
        city: 'Bengaluru',
        state: 'Karnataka',
        country: 'India',
        postalCode: '560095',
        isDefault: true,
        addressType: 'home',
      ),
      const AddressModel(
        id: 'addr_2',
        label: 'Office',
        fullName: 'Aisha Rahman',
        phone: '+91 98765 43210',
        street: 'Level 3, MG Road Plaza',
        city: 'Bengaluru',
        state: 'Karnataka',
        country: 'India',
        postalCode: '560001',
        isDefault: false,
        addressType: 'work',
      ),
    ];
  }
}
