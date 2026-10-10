import '../../domain/entities/banner_entity.dart';

class HomeBannerModel {
  const HomeBannerModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.deepLink,
    required this.isActive,
  });

  final String id;
  final String title;
  final String imageUrl;
  final String? deepLink;
  final bool isActive;

  factory HomeBannerModel.fromJson(Map<String, dynamic> json) {
    return HomeBannerModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Promotion',
      imageUrl:
          json['image_url']?.toString() ?? json['imageUrl']?.toString() ?? '',
      deepLink: json['deep_link']?.toString() ?? json['deeplink']?.toString(),
      isActive: json['is_active'] as bool? ?? json['isActive'] as bool? ?? true,
    );
  }

  factory HomeBannerModel.fromEntity(BannerEntity entity) {
    return HomeBannerModel(
      id: entity.id,
      title: entity.title,
      imageUrl: entity.imageUrl,
      deepLink: entity.deepLink,
      isActive: entity.isActive,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'image_url': imageUrl,
    'deep_link': deepLink,
    'is_active': isActive,
  };

  BannerEntity toEntity() => BannerEntity(
    id: id,
    title: title,
    imageUrl: imageUrl,
    deepLink: deepLink,
    isActive: isActive,
  );
}
