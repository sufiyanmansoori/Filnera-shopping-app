import 'package:flutter/foundation.dart';

import '../../data/datasources/profile_local_data_source.dart';
import '../../data/datasources/profile_remote_data_source.dart';
import '../../data/models/user_profile_model.dart';
import '../../data/repositories/profile_repository_impl.dart';

class ProfileProvider extends ChangeNotifier {
  ProfileProvider({ProfileRepositoryImpl? repository})
    : _repository =
          repository ??
          ProfileRepositoryImpl(
            remoteDataSource: const ProfileRemoteDataSource(),
            localDataSource: ProfileLocalDataSource(),
          );

  final ProfileRepositoryImpl _repository;

  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  UserProfileModel? _profile;

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  UserProfileModel? get profile => _profile;

  Future<void> loadProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _profile = await _repository.getProfile();
    } catch (_) {
      _errorMessage = 'Unable to load your profile right now.';
      _profile = UserProfileModel.empty();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? city,
    String? country,
    String? bio,
    String? avatarUrl,
  }) async {
    final currentProfile = _profile ?? UserProfileModel.empty();
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final nextProfile = currentProfile.copyWith(
        firstName: firstName ?? currentProfile.firstName,
        lastName: lastName ?? currentProfile.lastName,
        email: email ?? currentProfile.email,
        phone: phone ?? currentProfile.phone,
        city: city ?? currentProfile.city,
        country: country ?? currentProfile.country,
        bio: bio ?? currentProfile.bio,
        avatarUrl: avatarUrl ?? currentProfile.avatarUrl,
      );

      _profile = await _repository.updateProfile(nextProfile);
    } catch (_) {
      _errorMessage = 'Profile update failed. Please try again.';
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
