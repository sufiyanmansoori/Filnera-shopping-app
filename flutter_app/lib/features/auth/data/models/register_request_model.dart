class RegisterRequestModel {
  const RegisterRequestModel({
    required this.fullName,
    required this.email,
    required this.password,
    required this.phone,
    this.referralCode,
    this.acceptTerms = true,
  });

  final String fullName;
  final String email;
  final String password;
  final String phone;
  final String? referralCode;
  final bool acceptTerms;

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'password': password,
      'phone': phone,
      'referralCode': referralCode,
      'acceptTerms': acceptTerms,
    };
  }
}
