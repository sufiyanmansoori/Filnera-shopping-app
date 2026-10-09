
class BannerModel {
  const BannerModel({required this.imageUrl});

  final String? imageUrl;

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(imageUrl: json['imageUrl'] as String?);
  }
}
