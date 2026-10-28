 import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

import '../../data/models/auth_response_model.dart';
import '../../data/models/login_request_model.dart';
import '../../data/models/oauth_model.dart';
import '../../data/models/register_request_model.dart';
import '../../data/repositories/auth_repository_impl.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthRepositoryImpl? repository})
    : _repository = repository ?? AuthRepositoryImpl();

  final AuthRepositoryImpl _repository;

  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _errorMessage;
  AuthResponseModel? _currentUser;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get errorMessage => _errorMessage;
  AuthResponseModel? get currentUser => _currentUser;

  Future<void> loadSession() async {
    _isLoading = true;
    notifyListeners();

    try {
      final session = await _repository.loadSession();
      _currentUser = session;
      _isAuthenticated = session != null;
      _errorMessage = null;
    } catch (error) {
      _errorMessage = error.toString();
      _isAuthenticated = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loginWithEmail({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final session = await _repository.login(
        LoginRequestModel(email: email.trim(), password: password),
      );
      _currentUser = session;
      _isAuthenticated = true;
    } catch (error) {
      _errorMessage = _messageFor(error);
      _isAuthenticated = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    String? referralCode,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final session = await _repository.register(
        RegisterRequestModel(
          fullName: fullName.trim(),
          email: email.trim(),
          password: password,
          phone: phone.trim(),
          referralCode: referralCode,
        ),
      );
      _currentUser = session;
      _isAuthenticated = true;
    } catch (error) {
      _errorMessage = _messageFor(error);
      _isAuthenticated = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> verifyOtp({
    required String identity,
    required String otp,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.verifyOtp(identity: identity, otp: otp);
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendPasswordResetCode({required String email}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.sendResetOtp(email: email);
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetPassword({
    required String email,
    required String otp,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.resetPassword(
        email: email,
        otp: otp,
        password: password,
      );
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loginWithOAuth(OAuthProvider provider) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final session = await _repository.signInWithOAuth(
        OAuthModel(
          provider: provider,
          accessToken: 'oauth_${provider.name}_token',
          email: 'user@${provider.name}.example',
          name: provider.name.toUpperCase(),
        ),
      );
      _currentUser = session;
      _isAuthenticated = true;
    } catch (error) {
      _errorMessage = error.toString();
      _isAuthenticated = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.logout();
      _currentUser = null;
      _isAuthenticated = false;
      _errorMessage = null;
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _messageFor(Object error) {
    if (error is DioException) {
      if (error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        return 'Server se connection nahi ho pa raha. Project root se '
            '`npm run dev` chala kar dobara try karein.';
      }
      final responseBody = error.response?.data;
      if (responseBody is Map && responseBody['message'] is String) {
        return responseBody['message'] as String;
      }
    }
    return error.toString();
  }
}
