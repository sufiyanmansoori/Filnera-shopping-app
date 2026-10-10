import 'banner_entity.dart';

class HomePageEntity {
  const HomePageEntity({
    required this.banners,
    required this.categories,
    required this.deals,
    required this.products,
    required this.updatedAt,
  });

  final List<BannerEntity> banners;
  final List<HomeCategoryEntity> categories;
  final List<HomeDealEntity> deals;
  final List<HomeProductEntity> products;
  final DateTime updatedAt;
}

class HomeCategoryEntity {
  const HomeCategoryEntity({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.slug,
  });

  final String id;
  final String name;
  final String imageUrl;
  final String slug;
}

class HomeDealEntity {
  const HomeDealEntity({
    required this.id,
    required this.title,
    required this.discount,
    required this.productId,
    required this.productName,
    required this.price,
    required this.imageUrl,
  });

  final String id;
  final String title;
  final String discount;
  final String productId;
  final String productName;
  final double price;
  final String imageUrl;
}

class HomeProductEntity {
  const HomeProductEntity({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.rating,
  });

  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final double rating;
}
