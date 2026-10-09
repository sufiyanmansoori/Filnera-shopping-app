import '../../domain/entities/deal_entity.dart';
import '../../domain/entities/home_entity.dart';

class HomeDealModel {
  const HomeDealModel({
    required this.id,
    required this.title,
    this.slug = '',
    this.productId = '',
    this.productName = '',
    this.originalPrice = 0,
    this.currentPrice = 0,
    this.discountPercent = 0,
    this.imageUrl = '',
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

  factory HomeDealModel.fromJson(Map<String, dynamic> json) {
    return HomeDealModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Deal',
      slug: json['slug']?.toString() ?? '',
      productId:
          json['product_id']?.toString() ?? json['productId']?.toString() ?? '',
      productName:
          json['product_name']?.toString() ??
          json['productName']?.toString() ??
          '',
      originalPrice:
          double.tryParse(
            json['original_price']?.toString() ??
                json['originalPrice']?.toString() ??
                '0',
          ) ??
          0,
      currentPrice:
          double.tryParse(
            json['current_price']?.toString() ??
                json['currentPrice']?.toString() ??
                json['price']?.toString() ??
                '0',
          ) ??
          0,
      discountPercent:
          double.tryParse(
            json['discount_percent']?.toString() ??
                json['discountPercent']?.toString() ??
                '0',
          ) ??
          0,
      imageUrl:
          json['image_url']?.toString() ?? json['imageUrl']?.toString() ?? '',
      badge: json['badge']?.toString(),
      description: json['description']?.toString(),
      startAt: _dateTimeFromJson(json['start_at'] ?? json['startAt']),
      endAt: _dateTimeFromJson(json['end_at'] ?? json['endAt']),
      isActive: json['is_active'] as bool? ?? json['isActive'] as bool? ?? true,
      stockProgress:
          double.tryParse(json['stock_progress']?.toString() ?? '0') ?? 0,
      soldCount: int.tryParse(json['sold_count']?.toString() ?? '0') ?? 0,
      remainingCount:
          int.tryParse(json['remaining_count']?.toString() ?? '0') ?? 0,
      ctaLabel: json['cta_label']?.toString() ?? json['ctaLabel']?.toString(),
      categoryId:
          json['category_id']?.toString() ?? json['categoryId']?.toString(),
    );
  }

  factory HomeDealModel.fromEntity(DealEntity entity) {
    return HomeDealModel(
      id: entity.id,
      title: entity.title,
      slug: entity.slug,
      productId: entity.productId,
      productName: entity.productName,
      originalPrice: entity.originalPrice,
      currentPrice: entity.currentPrice,
      discountPercent: entity.discountPercent,
      imageUrl: entity.imageUrl,
      badge: entity.badge,
      description: entity.description,
      startAt: entity.startAt,
      endAt: entity.endAt,
      isActive: entity.isActive,
      stockProgress: entity.stockProgress,
      soldCount: entity.soldCount,
      remainingCount: entity.remainingCount,
      ctaLabel: entity.ctaLabel,
      categoryId: entity.categoryId,
    );
  }

  DealEntity toEntity() => DealEntity(
    id: id,
    title: title,
    slug: slug,
    productId: productId,
    productName: productName,
    originalPrice: originalPrice,
    currentPrice: currentPrice,
    discountPercent: discountPercent,
    imageUrl: imageUrl,
    badge: badge,
    description: description,
    startAt: startAt,
    endAt: endAt,
    isActive: isActive,
    stockProgress: stockProgress,
    soldCount: soldCount,
    remainingCount: remainingCount,
    ctaLabel: ctaLabel,
    categoryId: categoryId,
  );

  HomeDealEntity toLegacy() => HomeDealEntity(
    id: id,
    title: title,
    discount: '${discountPercent.round()}%',
    productId: productId,
    productName: productName,
    price: currentPrice,
    imageUrl: imageUrl,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'slug': slug,
    'product_id': productId,
    'product_name': productName,
    'original_price': originalPrice,
    'current_price': currentPrice,
    'discount_percent': discountPercent,
    'image_url': imageUrl,
    'badge': badge,
    'description': description,
    'start_at': startAt?.toIso8601String(),
    'end_at': endAt?.toIso8601String(),
    'is_active': isActive,
    'stock_progress': stockProgress,
    'sold_count': soldCount,
    'remaining_count': remainingCount,
    'cta_label': ctaLabel,
    'category_id': categoryId,
  };

  static DateTime? _dateTimeFromJson(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}
