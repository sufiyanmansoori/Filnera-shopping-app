class WishlistItemModel {
  const WishlistItemModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.category,
    required this.rating,
  });

  final String id;
  final String productId;
  final String productName;
  final String productImage;
  final double price;
  final String category;
  final double rating;

  factory WishlistItemModel.fromJson(Map<String, dynamic> json) {
    return WishlistItemModel(
      id: json['id']?.toString() ?? '',
      productId:
          json['productId']?.toString() ?? json['product_id']?.toString() ?? '',
      productName:
          json['productName']?.toString() ??
          json['name']?.toString() ??
          'Product',
      productImage:
          json['productImage']?.toString() ??
          json['imageUrl']?.toString() ??
          '',
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : 0.0,
      category: json['category']?.toString() ?? '',
      rating: (json['rating'] is num)
          ? (json['rating'] as num).toDouble()
          : 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'productId': productId,
    'productName': productName,
    'productImage': productImage,
    'price': price,
    'category': category,
    'rating': rating,
  };
}
