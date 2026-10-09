import '../../domain/entities/home_entity.dart';

class HomeProductModel {
  const HomeProductModel({
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

  factory HomeProductModel.fromJson(Map<String, dynamic> json) {
    return HomeProductModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Product',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0,
      imageUrl:
          json['image_url']?.toString() ?? json['imageUrl']?.toString() ?? '',
      rating: double.tryParse(json['rating']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'price': price,
    'image_url': imageUrl,
    'rating': rating,
  };

  HomeProductEntity toEntity() => HomeProductEntity(
    id: id,
    name: name,
    price: price,
    imageUrl: imageUrl,
    rating: rating,
  );
}
