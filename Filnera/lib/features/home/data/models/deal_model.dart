
class DealModel {
  const DealModel({required this.productName, this.productImage});

  final String? productName;
  final String? productImage;

  factory DealModel.fromJson(Map<String, dynamic> json) {
    return DealModel(
      productName: json['productName'] as String?,
      productImage: json['productImage'] as String?,
    );
  }
}
