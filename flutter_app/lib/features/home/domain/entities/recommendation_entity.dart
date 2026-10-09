import 'package:equatable/equatable.dart';

/// Represents a personalized product recommendation for the current user.
class RecommendationEntity extends Equatable {
  const RecommendationEntity({
    required this.id,
    required this.productId,
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.compareAtPrice,
    this.reason,
    this.score = 0,
    this.isFavorite = false,
    this.brand,
    this.categoryId,
  });

  final String id;
  final String productId;
  final String title;
  final String imageUrl;
  final double price;
  final double compareAtPrice;
  final String? reason;
  final double score;
  final bool isFavorite;
  final String? brand;
  final String? categoryId;

  bool get hasDiscount => compareAtPrice > price && compareAtPrice > 0;

  RecommendationEntity copyWith({
    String? id,
    String? productId,
    String? title,
    String? imageUrl,
    double? price,
    double? compareAtPrice,
    String? reason,
    double? score,
    bool? isFavorite,
    String? brand,
    String? categoryId,
  }) {
    return RecommendationEntity(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      compareAtPrice: compareAtPrice ?? this.compareAtPrice,
      reason: reason ?? this.reason,
      score: score ?? this.score,
      isFavorite: isFavorite ?? this.isFavorite,
      brand: brand ?? this.brand,
      categoryId: categoryId ?? this.categoryId,
    );
  }

  @override
  List<Object?> get props => [
    id,
    productId,
    title,
    imageUrl,
    price,
    compareAtPrice,
    reason,
    score,
    isFavorite,
    brand,
    categoryId,
  ];
}
