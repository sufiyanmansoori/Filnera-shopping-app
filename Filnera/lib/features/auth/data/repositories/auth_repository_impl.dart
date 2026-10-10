import '../../data/datasources/auth_local_data_source.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/models/auth_response_model.dart';
import '../../data/models/login_request_model.dart';
import '../../data/models/oauth_model.dart';
import '../../data/models/register_request_model.dart';

class AuthRepositoryImpl {
  AuthRepositoryImpl({
    AuthRemoteDataSource? remoteDataSource,
    AuthLocalDataSource? localDataSource,
  }) : _remoteDataSource = remoteDataSource ?? const AuthRemoteDataSource(),
       _localDataSource = localDataSource ?? const AuthLocalDataSource();

  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  Future<AuthResponseModel> login(LoginRequestModel request) async {
    final response = await _remoteDataSource.login(request);
    await _localDataSource.saveSession(response);
    return response;
  }

  Future<AuthResponseModel> register(RegisterRequestModel request) async {
    final response = await _remoteDataSource.register(request);
    await _localDataSource.saveSession(response);
    return response;
  }

  Future<void> verifyOtp({
    required String identity,
    required String otp,
  }) async {
    await _remoteDataSource.verifyOtp(identity: identity, otp: otp);
  }

  Future<void> sendResetOtp({required String email}) async {
    await _remoteDataSource.sendResetCode(email: email);
  }

  Future<void> resetPassword({
    required String email,
    required String otp,
    required String password,
  }) async {
    await _remoteDataSource.resetPassword(
      email: email,
      otp: otp,
      password: password,
    );
  }

  Future<AuthResponseModel> signInWithOAuth(OAuthModel oauth) async {
    final response = await _remoteDataSource.signInWithOAuth(oauth);
    await _localDataSource.saveSession(response);
    return response;
  }

  Future<AuthResponseModel?> loadSession() async {
    return _localDataSource.loadSession();
  }

  Future<void> logout() async {
    await _localDataSource.clearSession();
  }
}
