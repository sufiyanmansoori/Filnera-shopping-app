import 'package:dio/dio.dart';

class RetryInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) { handler.next(err); }
}
