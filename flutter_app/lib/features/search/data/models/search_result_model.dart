class SearchResultModel {
  const SearchResultModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.rating,
    required this.category,
    required this.isFeatured,
  });

  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double price;
  final double rating;
  final String category;
  final bool isFeatured;

  factory SearchResultModel.fromJson(Map<String, dynamic> json) {
    return SearchResultModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Product',
      description: json['description']?.toString() ?? '',
      imageUrl:
          json['image_url']?.toString() ?? json['imageUrl']?.toString() ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0,
      rating: double.tryParse(json['rating']?.toString() ?? '0') ?? 0,
      category:
          json['category']?.toString() ??
          json['category_name']?.toString() ??
          '',
      isFeatured:
          json['is_featured'] as bool? ?? json['isFeatured'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'image_url': imageUrl,
    'price': price,
    'rating': rating,
    'category': category,
    'is_featured': isFeatured,
  };

  SearchResultModel copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    double? price,
    double? rating,
    String? category,
    bool? isFeatured,
  }) {
    return SearchResultModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      rating: rating ?? this.rating,
      category: category ?? this.category,
      isFeatured: isFeatured ?? this.isFeatured,
    );
  }
}
