import 'package:equatable/equatable.dart';

class ProductModel extends Equatable {
  const ProductModel({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.originalPrice,
    required this.rating,
    required this.reviewCount,
    required this.imageUrl,
    required this.gallery,
    required this.description,
    required this.features,
    required this.isFeatured,
    required this.stock,
  });

  final String id;
  final String name;
  final String category;
  final double price;
  final double originalPrice;
  final double rating;
  final int reviewCount;
  final String imageUrl;
  final List<String> gallery;
  final String description;
  final List<String> features;
  final bool isFeatured;
  final int stock;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      price: (json['price'] as num).toDouble(),
      originalPrice: (json['originalPrice'] as num).toDouble(),
      rating: (json['rating'] as num).toDouble(),
      reviewCount: json['reviewCount'] as int,
      imageUrl: json['imageUrl'] as String,
      gallery: List<String>.from(json['gallery'] as List<dynamic>),
      description: json['description'] as String,
      features: List<String>.from(json['features'] as List<dynamic>),
      isFeatured: json['isFeatured'] as bool? ?? false,
      stock: json['stock'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'originalPrice': originalPrice,
      'rating': rating,
      'reviewCount': reviewCount,
      'imageUrl': imageUrl,
      'gallery': gallery,
      'description': description,
      'features': features,
      'isFeatured': isFeatured,
      'stock': stock,
    };
  }

  ProductModel copyWith({
    String? id,
    String? name,
    String? category,
    double? price,
    double? originalPrice,
    double? rating,
    int? reviewCount,
    String? imageUrl,
    List<String>? gallery,
    String? description,
    List<String>? features,
    bool? isFeatured,
    int? stock,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      imageUrl: imageUrl ?? this.imageUrl,
      gallery: gallery ?? this.gallery,
      description: description ?? this.description,
      features: features ?? this.features,
      isFeatured: isFeatured ?? this.isFeatured,
      stock: stock ?? this.stock,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        category,
        price,
        originalPrice,
        rating,
        reviewCount,
        imageUrl,
        gallery,
        description,
        features,
        isFeatured,
        stock,
      ];
}
