import 'package:equatable/equatable.dart';

/// Represents a time-bound promotional deal shown in the home feed.
class DealEntity extends Equatable {
  const DealEntity({
    required this.id,
    required this.title,
    required this.slug,
    required this.productId,
    required this.productName,
    required this.originalPrice,
    required this.currentPrice,
    required this.discountPercent,
    required this.imageUrl,
    this.badge,
    this.description,
    this.startAt,
    this.endAt,
    this.isActive = true,
    this.stockProgress = 0,
    this.soldCount = 0,
    this.remainingCount = 0,
    this.ctaLabel,
    this.categoryId,
  });

  final String id;
  final String title;
  final String slug;
  final String productId;
  final String productName;
  final double originalPrice;
  final double currentPrice;
  final double discountPercent;
  final String imageUrl;
  final String? badge;
  final String? description;
  final DateTime? startAt;
  final DateTime? endAt;
  final bool isActive;
  final double stockProgress;
  final int soldCount;
  final int remainingCount;
  final String? ctaLabel;
  final String? categoryId;

  bool get hasDiscount => currentPrice < originalPrice && originalPrice > 0;

  double get savings => originalPrice - currentPrice;

  bool get isLive =>
      isActive &&
      (startAt == null || !DateTime.now().isBefore(startAt!)) &&
      (endAt == null ||
          DateTime.now().isBefore(endAt!.add(const Duration(days: 1))));

  DealEntity copyWith({
    String? id,
    String? title,
    String? slug,
    String? productId,
    String? productName,
    double? originalPrice,
    double? currentPrice,
    double? discountPercent,
    String? imageUrl,
    String? badge,
    String? description,
    DateTime? startAt,
    DateTime? endAt,
    bool? isActive,
    double? stockProgress,
    int? soldCount,
    int? remainingCount,
    String? ctaLabel,
    String? categoryId,
  }) {
    return DealEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      slug: slug ?? this.slug,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      originalPrice: originalPrice ?? this.originalPrice,
      currentPrice: currentPrice ?? this.currentPrice,
      discountPercent: discountPercent ?? this.discountPercent,
      imageUrl: imageUrl ?? this.imageUrl,
      badge: badge ?? this.badge,
      description: description ?? this.description,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      isActive: isActive ?? this.isActive,
      stockProgress: stockProgress ?? this.stockProgress,
      soldCount: soldCount ?? this.soldCount,
      remainingCount: remainingCount ?? this.remainingCount,
      ctaLabel: ctaLabel ?? this.ctaLabel,
      categoryId: categoryId ?? this.categoryId,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    slug,
    productId,
    productName,
    originalPrice,
    currentPrice,
    discountPercent,
    imageUrl,
    badge,
    description,
    startAt,
    endAt,
    isActive,
    stockProgress,
    soldCount,
    remainingCount,
    ctaLabel,
    categoryId,
  ];
}
