class UserProfileModel {
  const UserProfileModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone = '',
    this.avatarUrl = '',
    this.city = '',
    this.country = 'India',
    this.bio = '',
    this.emailVerified = true,
    this.phoneVerified = false,
    this.createdAt,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String avatarUrl;
  final String city;
  final String country;
  final String bio;
  final bool emailVerified;
  final bool phoneVerified;
  final DateTime? createdAt;

  String get fullName => '$firstName $lastName'.trim();
  String get initials =>
      '${firstName.isNotEmpty ? firstName[0].toUpperCase() : ''}'
              '${lastName.isNotEmpty ? lastName[0].toUpperCase() : ''}'
          .trim();

  factory UserProfileModel.empty() => UserProfileModel(
    id: '',
    firstName: 'Guest',
    lastName: 'User',
    email: 'guest@example.com',
    phone: '',
    city: 'New Delhi',
    country: 'India',
    bio: 'Welcome to Manara.',
    createdAt: DateTime.now(),
  );

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String? ?? '',
      city: json['city'] as String? ?? '',
      country: json['country'] as String? ?? 'India',
      bio: json['bio'] as String? ?? '',
      emailVerified: json['emailVerified'] as bool? ?? true,
      phoneVerified: json['phoneVerified'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'avatarUrl': avatarUrl,
      'city': city,
      'country': country,
      'bio': bio,
      'emailVerified': emailVerified,
      'phoneVerified': phoneVerified,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  UserProfileModel copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? avatarUrl,
    String? city,
    String? country,
    String? bio,
    bool? emailVerified,
    bool? phoneVerified,
    DateTime? createdAt,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      city: city ?? this.city,
      country: country ?? this.country,
      bio: bio ?? this.bio,
      emailVerified: emailVerified ?? this.emailVerified,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
