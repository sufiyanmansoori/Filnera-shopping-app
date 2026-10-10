class ApiConfig {
  const ApiConfig._();
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:5000/api/v1',
  );
  static const Duration timeout = Duration(seconds: 30);
}
