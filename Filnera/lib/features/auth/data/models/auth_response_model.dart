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
    final user = json['user'] is Map
        ? Map<String, dynamic>.from(json['user'] as Map)
        : json;
    final accessToken = (json['accessToken'] ?? json['token'])?.toString() ?? '';
    if (accessToken.isEmpty) {
      throw const FormatException('The server did not return an access token.');
    }
    return AuthResponseModel(
      accessToken: accessToken,
      refreshToken: json['refreshToken']?.toString() ?? '',
      userId:
          (user['userId'] ?? user['id'] ?? user['_id'])?.toString() ?? '',
      email: user['email']?.toString() ?? '',
      fullName:
          (user['fullName'] ?? user['name'])?.toString() ?? 'User',
      roles: (user['roles'] as List<dynamic>? ??
              (user['role'] == null ? const [] : [user['role']]))
          .map((role) => role.toString())
          .toList(),
      expiresAt:
          DateTime.tryParse(
            (json['expiresAt'] as String?) ??
                DateTime.now().add(const Duration(days: 7)).toIso8601String(),
          ) ??
          DateTime.now().add(const Duration(days: 7)),
      avatarUrl: user['avatarUrl']?.toString(),
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
