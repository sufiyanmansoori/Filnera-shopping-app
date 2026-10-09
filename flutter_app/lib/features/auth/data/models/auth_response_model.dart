class AuthResponseModel {
  const AuthResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
    required this.email,
    required this.fullName,
    required this.roles,
    required this.expiresAt,
    this.avatarUrl,
    this.requiresTwoFactor = false,
  });

  final String accessToken;
  final String refreshToken;
  final String userId;
  final String email;
  final String fullName;
  final List<String> roles;
  final DateTime expiresAt;
  final String? avatarUrl;
  final bool requiresTwoFactor;

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      accessToken: json['accessToken'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      email: json['email'] as String? ?? '',
      fullName: json['fullName'] as String? ?? 'User',
      roles: (json['roles'] as List<dynamic>? ?? const [])
          .map((role) => role.toString())
          .toList(),
      expiresAt:
          DateTime.tryParse(
            (json['expiresAt'] as String?) ?? DateTime.now().toIso8601String(),
          ) ??
          DateTime.now().add(const Duration(hours: 24)),
      avatarUrl: json['avatarUrl'] as String?,
      requiresTwoFactor: json['requiresTwoFactor'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'userId': userId,
      'email': email,
      'fullName': fullName,
      'roles': roles,
      'expiresAt': expiresAt.toIso8601String(),
      'avatarUrl': avatarUrl,
      'requiresTwoFactor': requiresTwoFactor,
    };
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  AuthResponseModel copyWith({
    String? accessToken,
    String? refreshToken,
    String? userId,
    String? email,
    String? fullName,
    List<String>? roles,
    DateTime? expiresAt,
    String? avatarUrl,
    bool? requiresTwoFactor,
  }) {
    return AuthResponseModel(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      roles: roles ?? this.roles,
      expiresAt: expiresAt ?? this.expiresAt,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      requiresTwoFactor: requiresTwoFactor ?? this.requiresTwoFactor,
    );
  }
}
