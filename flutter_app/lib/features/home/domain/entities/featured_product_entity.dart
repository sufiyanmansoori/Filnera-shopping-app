import 'package:equatable/equatable.dart';

/// Represents a highlighted product shown in the featured section.
class FeaturedProductEntity extends Equatable {
  const FeaturedProductEntity({
    required this.id,
    required this.title,
    required this.slug,
    required this.imageUrl,
    required this.price,
    required this.compareAtPrice,
    this.rating = 0,
    this.reviewCount = 0,
    this.badge,
    this.brand,
    this.seller,
    this.isSponsored = false,
    this.isNew = false,
    this.stockStatus = StockStatus.inStock,
    this.categoryId,
  });

  final String id;
  final String title;
  final String slug;
  final String imageUrl;
  final double price;
  final double compareAtPrice;
  final double rating;
  final int reviewCount;
  final String? badge;
  final String? brand;
  final String? seller;
  final bool isSponsored;
  final bool isNew;
  final StockStatus stockStatus;
  final String? categoryId;

  bool get hasDiscount => compareAtPrice > price && compareAtPrice > 0;

  double get discountPercent =>
      hasDiscount ? ((compareAtPrice - price) / compareAtPrice) * 100 : 0;

  FeaturedProductEntity copyWith({
    String? id,
    String? title,
    String? slug,
    String? imageUrl,
    double? price,
    double? compareAtPrice,
    double? rating,
    int? reviewCount,
    String? badge,
    String? brand,
    String? seller,
    bool? isSponsored,
    bool? isNew,
    StockStatus? stockStatus,
    String? categoryId,
  }) {
    return FeaturedProductEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      slug: slug ?? this.slug,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      compareAtPrice: compareAtPrice ?? this.compareAtPrice,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      badge: badge ?? this.badge,
      brand: brand ?? this.brand,
      seller: seller ?? this.seller,
      isSponsored: isSponsored ?? this.isSponsored,
      isNew: isNew ?? this.isNew,
      stockStatus: stockStatus ?? this.stockStatus,
      categoryId: categoryId ?? this.categoryId,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    slug,
    imageUrl,
    price,
    compareAtPrice,
    rating,
    reviewCount,
    badge,
    brand,
    seller,
    isSponsored,
    isNew,
    stockStatus,
    categoryId,
  ];
}

enum StockStatus { inStock, lowStock, outOfStock, preorder }
