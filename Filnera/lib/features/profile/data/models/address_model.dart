class AddressModel {
  const AddressModel({
    required this.id,
    required this.label,
    required this.fullName,
    required this.phone,
    required this.street,
    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
    this.isDefault = false,
    this.addressType = 'home',
    this.latitude,
    this.longitude,
  });

  final String id;
  final String label;
  final String fullName;
  final String phone;
  final String street;
  final String city;
  final String state;
  final String country;
  final String postalCode;
  final bool isDefault;
  final String addressType;
  final double? latitude;
  final double? longitude;

  String get fullAddress => '$street, $city, $state, $country - $postalCode';

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] as String? ?? '',
      label: json['label'] as String? ?? 'Home',
      fullName: json['fullName'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      street: json['street'] as String? ?? '',
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      country: json['country'] as String? ?? 'India',
      postalCode: json['postalCode'] as String? ?? '',
      isDefault: json['isDefault'] as bool? ?? false,
      addressType: json['addressType'] as String? ?? 'home',
      latitude: json['latitude'] != null
          ? (json['latitude'] as num).toDouble()
          : null,
      longitude: json['longitude'] != null
          ? (json['longitude'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'fullName': fullName,
      'phone': phone,
      'street': street,
      'city': city,
      'state': state,
      'country': country,
      'postalCode': postalCode,
      'isDefault': isDefault,
      'addressType': addressType,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  AddressModel copyWith({
    String? id,
    String? label,
    String? fullName,
    String? phone,
    String? street,
    String? city,
    String? state,
    String? country,
    String? postalCode,
    bool? isDefault,
    String? addressType,
    double? latitude,
    double? longitude,
  }) {
    return AddressModel(
      id: id ?? this.id,
      label: label ?? this.label,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      street: street ?? this.street,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      isDefault: isDefault ?? this.isDefault,
      addressType: addressType ?? this.addressType,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}
