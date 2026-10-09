class ProductSpecificationModel {
  const ProductSpecificationModel({required this.name, required this.value});

  final String name;
  final String value;

  factory ProductSpecificationModel.fromJson(Map<String, dynamic> json) {
    return ProductSpecificationModel(
      name: json['name']?.toString() ?? '',
      value: json['value']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'name': name, 'value': value};
}
