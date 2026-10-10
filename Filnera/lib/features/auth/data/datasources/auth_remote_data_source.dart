import '../models/auth_response_model.dart';
import '../models/login_request_model.dart';
import '../models/oauth_model.dart';
import '../models/register_request_model.dart';

class AuthRemoteDataSource {
  const AuthRemoteDataSource();

  Future<AuthResponseModel> login(LoginRequestModel request) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));

    return AuthResponseModel(
      accessToken: 'mock_access_token_${DateTime.now().millisecondsSinceEpoch}',
      refreshToken:
          'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'user_01',
      email: request.email,
      fullName: request.email.split('@').first.replaceAll('.', ' ').trim(),
      roles: const ['customer'],
      expiresAt: DateTime.now().add(const Duration(hours: 24)),
      avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e',
    );
  }

  Future<AuthResponseModel> register(RegisterRequestModel request) async {
    await Future<void>.delayed(const Duration(milliseconds: 750));

    return AuthResponseModel(
      accessToken:
          'mock_access_token_register_${DateTime.now().millisecondsSinceEpoch}',
      refreshToken:
          'mock_refresh_token_register_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'user_${DateTime.now().millisecondsSinceEpoch}',
      email: request.email,
      fullName: request.fullName,
      roles: const ['customer'],
      expiresAt: DateTime.now().add(const Duration(hours: 24)),
    );
  }

  Future<void> verifyOtp({
    required String identity,
    required String otp,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (otp.length < 4) {
      throw const FormatException('OTP must be at least 4 digits.');
    }
  }

  Future<void> sendResetCode({required String email}) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (email.trim().isEmpty) {
      throw const FormatException('Email is required.');
    }
  }

  Future<void> resetPassword({
    required String email,
    required String otp,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (password.length < 6) {
      throw const FormatException('Password must be at least 6 characters.');
    }
  }

  Future<AuthResponseModel> signInWithOAuth(OAuthModel oauth) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));

    return AuthResponseModel(
      accessToken: 'oauth_access_${DateTime.now().millisecondsSinceEpoch}',
      refreshToken: 'oauth_refresh_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'oauth_user_${DateTime.now().millisecondsSinceEpoch}',
      email: oauth.email ?? 'oauth.user@example.com',
      fullName: oauth.name ?? 'OAuth User',
      roles: const ['customer'],
      expiresAt: DateTime.now().add(const Duration(hours: 24)),
      avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330',
    );
  }
}
