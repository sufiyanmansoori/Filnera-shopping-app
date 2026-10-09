import 'package:dio/dio.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({this.token});
  final String? token;
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (token != null && token!.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }
}
