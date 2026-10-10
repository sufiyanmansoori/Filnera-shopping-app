import '../../data/models/search_filter_model.dart';

class SearchFilterEntity {
  const SearchFilterEntity({
    this.category = 'all',
    this.minPrice = 0,
    this.maxPrice = 10000,
    this.rating = 0,
    this.inStockOnly = false,
    this.sortBy = 'relevance',
  });

  final String category;
  final double minPrice;
  final double maxPrice;
  final double rating;
  final bool inStockOnly;
  final String sortBy;

  factory SearchFilterEntity.fromModel(SearchFilterModel model) {
    return SearchFilterEntity(
      category: model.category,
      minPrice: model.minPrice,
      maxPrice: model.maxPrice,
      rating: model.rating,
      inStockOnly: model.inStockOnly,
      sortBy: model.sortBy,
    );
  }

  SearchFilterModel toModel() {
    return SearchFilterModel(
      category: category,
      minPrice: minPrice,
      maxPrice: maxPrice,
      rating: rating,
      inStockOnly: inStockOnly,
      sortBy: sortBy,
    );
  }
}
