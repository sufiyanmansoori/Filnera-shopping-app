class AddressModel {
  const AddressModel({
    required this.id,
    required this.label,
    required this.fullName,
    required this.mobile,
    required this.addressLine1,
    required this.addressLine2,
    required this.city,
    required this.state,
    required this.pinCode,
    required this.country,
    this.isDefault = false,
  });

  final String id;
  final String label;
  final String fullName;
  final String mobile;
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String state;
  final String pinCode;
  final String country;
  final bool isDefault;

  String get fullAddress =>
      '$addressLine1, ${addressLine2.isNotEmpty ? '$addressLine2, ' : ''}$city, $state $pinCode, $country';

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id']?.toString() ?? '',
      label: json['label']?.toString() ?? 'Home',
      fullName:
          json['full_name']?.toString() ?? json['fullName']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? '',
      addressLine1:
          json['address_line_1']?.toString() ??
          json['addressLine1']?.toString() ??
          '',
      addressLine2:
          json['address_line_2']?.toString() ??
          json['addressLine2']?.toString() ??
          '',
      city: json['city']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      pinCode:
          json['pin_code']?.toString() ?? json['pinCode']?.toString() ?? '',
      country: json['country']?.toString() ?? 'India',
      isDefault:
          json['is_default'] as bool? ?? json['isDefault'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'full_name': fullName,
    'mobile': mobile,
    'address_line_1': addressLine1,
    'address_line_2': addressLine2,
    'city': city,
    'state': state,
    'pin_code': pinCode,
    'country': country,
    'is_default': isDefault,
  };
}
