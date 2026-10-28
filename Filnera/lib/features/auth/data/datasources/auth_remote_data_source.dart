import '../models/auth_response_model.dart';
import '../models/login_request_model.dart';
import '../models/oauth_model.dart';
import '../models/register_request_model.dart';
import '../../../../core/network/api_client.dart';

class AuthRemoteDataSource {
  const AuthRemoteDataSource({this.apiClient});

  final ApiClient? apiClient;

  ApiClient get _client => apiClient ?? ApiClient();

  Future<AuthResponseModel> login(LoginRequestModel request) async {
    final response = await _client.post('/auth/login', data: request.toJson());
    return AuthResponseModel.fromJson(_responseData(response.data));
  }

  Future<AuthResponseModel> register(RegisterRequestModel request) async {
    final response = await _client.post(
      '/auth/register',
      data: request.toJson(),
    );
    return AuthResponseModel.fromJson(_responseData(response.data));
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
    throw UnsupportedError(
      'OAuth sign-in is unavailable until a provider is configured.',
    );
  }

  Map<String, dynamic> _responseData(dynamic body) {
    if (body is Map<String, dynamic> && body['data'] is Map) {
      return Map<String, dynamic>.from(body['data'] as Map);
    }
    if (body is Map<String, dynamic>) return body;
    throw const FormatException('The server returned an invalid auth response.');
  }
}
