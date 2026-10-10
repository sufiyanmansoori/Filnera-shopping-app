class CouponModel {
  const CouponModel({
    required this.code,
    required this.discount,
    required this.type,
    required this.description,
    required this.isActive,
  });

  final String code;
  final double discount;
  final String type;
  final String description;
  final bool isActive;

  factory CouponModel.empty() {
    return const CouponModel(
      code: '',
      discount: 0,
      type: 'percent',
      description: '',
      isActive: false,
    );
  }

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      code: json['code']?.toString() ?? '',
      discount: (json['discount'] is num)
          ? (json['discount'] as num).toDouble()
          : 0,
      type: json['type']?.toString() ?? 'percent',
      description: json['description']?.toString() ?? '',
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'code': code,
    'discount': discount,
    'type': type,
    'description': description,
    'isActive': isActive,
  };
}
