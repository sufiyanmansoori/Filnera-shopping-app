enum OAuthProvider { google, apple, facebook }

class OAuthModel {
  const OAuthModel({
    required this.provider,
    required this.accessToken,
    this.email,
    this.name,
  });

  final OAuthProvider provider;
  final String accessToken;
  final String? email;
  final String? name;

  Map<String, dynamic> toJson() {
    return {
      'provider': provider.name,
      'accessToken': accessToken,
      'email': email,
      'name': name,
    };
  }

  factory OAuthModel.fromJson(Map<String, dynamic> json) {
    final providerValue = json['provider'] as String? ?? 'google';
    return OAuthModel(
      provider: OAuthProvider.values.firstWhere(
        (provider) => provider.name == providerValue,
        orElse: () => OAuthProvider.google,
      ),
      accessToken: json['accessToken'] as String? ?? '',
      email: json['email'] as String?,
      name: json['name'] as String?,
    );
  }
}
