class LoginRequestModel {
  const LoginRequestModel({
    required this.email,
    required this.password,
    this.deviceName = 'Flutter App',
    this.rememberMe = true,
  });

  final String email;
  final String password;
  final String deviceName;
  final bool rememberMe;

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'deviceName': deviceName,
      'rememberMe': rememberMe,
    };
  }
}
