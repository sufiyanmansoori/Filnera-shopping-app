import '../../data/models/product_model.dart';

class ProductEntity {
  const ProductEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.rating,
    required this.stock,
    required this.sellerName,
    required this.isFeatured,
    required this.images,
    required this.specifications,
    required this.shipping,
    required this.offers,
  });

  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final double rating;
  final int stock;
  final String sellerName;
  final bool isFeatured;
  final List<String> images;
  final Map<String, dynamic> specifications;
  final Map<String, dynamic> shipping;
  final List<String> offers;

  factory ProductEntity.fromModel(ProductModel model) {
    return ProductEntity(
      id: model.id,
      name: model.name,
      description: model.description,
      price: model.price,
      imageUrl: model.imageUrl,
      category: model.category,
      rating: model.rating,
      stock: model.stock,
      sellerName: model.sellerName,
      isFeatured: model.isFeatured,
      images: model.images,
      specifications: model.specifications,
      shipping: model.shipping,
      offers: model.offers,
    );
  }
}
