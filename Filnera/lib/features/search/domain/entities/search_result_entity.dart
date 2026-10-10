import '../../data/models/search_result_model.dart';

class SearchResultEntity {
  const SearchResultEntity({
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

  factory SearchResultEntity.fromModel(SearchResultModel model) {
    return SearchResultEntity(
      id: model.id,
      name: model.name,
      description: model.description,
      imageUrl: model.imageUrl,
      price: model.price,
      rating: model.rating,
      category: model.category,
      isFeatured: model.isFeatured,
    );
  }

  SearchResultModel toModel() {
    return SearchResultModel(
      id: id,
      name: name,
      description: description,
      imageUrl: imageUrl,
      price: price,
      rating: rating,
      category: category,
      isFeatured: isFeatured,
    );
  }
}
