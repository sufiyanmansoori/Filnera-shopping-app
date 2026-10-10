import 'product_variant_model.dart';

class ProductModel {
  const ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.compareAtPrice,
    required this.category,
    required this.brand,
    required this.imageUrl,
    this.images = const <String>[],
    this.rating = 0,
    this.reviewCount = 0,
    this.stock = 0,
    this.isFeatured = false,
    this.sellerName = 'Manara Store',
    this.badge = '',
    this.tags = const <String>[],
    this.variants = const <ProductVariantModel>[],
    this.shortDescription = '',
    this.specifications = const <String, dynamic>{},
    this.shipping = const <String, dynamic>{},
    this.offers = const <String>[],
  });

  final String id;
  final String name;
  final String description;
  final double price;
  final double compareAtPrice;
  final String category;
  final String brand;
  final String imageUrl;
  final List<String> images;
  final double rating;
  final int reviewCount;
  final int stock;
  final bool isFeatured;
  final String sellerName;
  final String badge;
  final List<String> tags;
  final List<ProductVariantModel> variants;
  final String shortDescription;
  final Map<String, dynamic> specifications;
  final Map<String, dynamic> shipping;
  final List<String> offers;

  bool get hasDiscount => compareAtPrice > price && compareAtPrice > 0;

  double get discountPercent {
    if (!hasDiscount || compareAtPrice <= 0) {
      return 0;
    }
    return ((compareAtPrice - price) / compareAtPrice) * 100;
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final imageUrls = (json['images'] as List? ?? const <dynamic>[])
        .map((item) => item.toString())
        .toList();

    return ProductModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Product',
      description: json['description']?.toString() ?? '',
      price:
          double.tryParse(
            json['price']?.toString() ??
                json['current_price']?.toString() ??
                '0',
          ) ??
          0,
      compareAtPrice:
          double.tryParse(
            json['compare_at_price']?.toString() ??
                json['compareAtPrice']?.toString() ??
                json['original_price']?.toString() ??
                '0',
          ) ??
          0,
      category:
          json['category']?.toString() ??
          json['category_name']?.toString() ??
          '',
      brand:
          json['brand']?.toString() ??
          json['brand_name']?.toString() ??
          'Manara',
      imageUrl:
          json['image_url']?.toString() ??
          json['imageUrl']?.toString() ??
          (imageUrls.isNotEmpty ? imageUrls.first : ''),
      images: imageUrls.isNotEmpty
          ? imageUrls
          : <String>[
              (json['image_url']?.toString() ??
                  json['imageUrl']?.toString() ??
                  ''),
            ],
      rating: double.tryParse(json['rating']?.toString() ?? '0') ?? 0,
      reviewCount:
          int.tryParse(
            json['review_count']?.toString() ??
                json['reviewCount']?.toString() ??
                '0',
          ) ??
          0,
      stock: int.tryParse(json['stock']?.toString() ?? '0') ?? 0,
      isFeatured:
          json['is_featured'] as bool? ?? json['isFeatured'] as bool? ?? false,
      sellerName:
          json['seller_name']?.toString() ??
          json['sellerName']?.toString() ??
          'Manara Store',
      badge: json['badge']?.toString() ?? '',
      tags: (json['tags'] as List? ?? const <dynamic>[])
          .map((item) => item.toString())
          .toList(),
      variants: (json['variants'] as List? ?? const <dynamic>[])
          .map(
            (item) =>
                ProductVariantModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(),
      shortDescription:
          json['short_description']?.toString() ??
          json['shortDescription']?.toString() ??
          '',
      specifications: Map<String, dynamic>.from(
        json['specifications'] as Map? ?? const <String, dynamic>{},
      ),
      shipping: Map<String, dynamic>.from(
        json['shipping'] as Map? ?? const <String, dynamic>{},
      ),
      offers: (json['offers'] as List? ?? const <dynamic>[])
          .map((item) => item.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'price': price,
    'compare_at_price': compareAtPrice,
    'category': category,
    'brand': brand,
    'image_url': imageUrl,
    'images': images,
    'rating': rating,
    'review_count': reviewCount,
    'stock': stock,
    'is_featured': isFeatured,
    'seller_name': sellerName,
    'badge': badge,
    'tags': tags,
    'variants': variants.map((variant) => variant.toJson()).toList(),
    'short_description': shortDescription,
    'specifications': specifications,
    'shipping': shipping,
    'offers': offers,
  };
}
