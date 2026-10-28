import 'package:dio/dio.dart';

import '../../config/api_config.dart';
import '../services/session_service.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.timeout,
        receiveTimeout: ApiConfig.timeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await SessionService.readAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onResponse: (response, handler) => handler.next(response),
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401) {
            await SessionService.clear();
          }
          handler.next(error);
        },
      ),
    );
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) => _dio.get(path, queryParameters: queryParameters);

  Future<Response> post(String path, {dynamic data}) =>
      _dio.post(path, data: data);

  Future<Response> put(String path, {dynamic data}) =>
      _dio.put(path, data: data);

  Future<Response> delete(String path) => _dio.delete(path);
}
