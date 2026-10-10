import 'package:equatable/equatable.dart';

/// Represents a flash-sale section with a countdown timer and limited inventory.
class FlashSaleEntity extends Equatable {
  const FlashSaleEntity({
    required this.id,
    required this.title,
    required this.slug,
    required this.productId,
    required this.productName,
    required this.imageUrl,
    required this.originalPrice,
    required this.salePrice,
    required this.discountPercent,
    required this.endsAt,
    this.badge,
    this.soldCount = 0,
    this.totalStock = 0,
    this.isActive = true,
  });

  final String id;
  final String title;
  final String slug;
  final String productId;
  final String productName;
  final String imageUrl;
  final double originalPrice;
  final double salePrice;
  final double discountPercent;
  final DateTime endsAt;
  final String? badge;
  final int soldCount;
  final int totalStock;
  final bool isActive;

  int get remainingStock => totalStock - soldCount;

  bool get isLive =>
      isActive &&
      DateTime.now().isBefore(endsAt.add(const Duration(minutes: 1)));

  FlashSaleEntity copyWith({
    String? id,
    String? title,
    String? slug,
    String? productId,
    String? productName,
    String? imageUrl,
    double? originalPrice,
    double? salePrice,
    double? discountPercent,
    DateTime? endsAt,
    String? badge,
    int? soldCount,
    int? totalStock,
    bool? isActive,
  }) {
    return FlashSaleEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      slug: slug ?? this.slug,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      imageUrl: imageUrl ?? this.imageUrl,
      originalPrice: originalPrice ?? this.originalPrice,
      salePrice: salePrice ?? this.salePrice,
      discountPercent: discountPercent ?? this.discountPercent,
      endsAt: endsAt ?? this.endsAt,
      badge: badge ?? this.badge,
      soldCount: soldCount ?? this.soldCount,
      totalStock: totalStock ?? this.totalStock,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    slug,
    productId,
    productName,
    imageUrl,
    originalPrice,
    salePrice,
    discountPercent,
    endsAt,
    badge,
    soldCount,
    totalStock,
    isActive,
  ];
}
