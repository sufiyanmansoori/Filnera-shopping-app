class SearchFilterModel {
  const SearchFilterModel({
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

  factory SearchFilterModel.fromJson(Map<String, dynamic> json) {
    return SearchFilterModel(
      category: json['category']?.toString() ?? 'all',
      minPrice: double.tryParse(json['min_price']?.toString() ?? '0') ?? 0,
      maxPrice:
          double.tryParse(json['max_price']?.toString() ?? '10000') ?? 10000,
      rating: double.tryParse(json['rating']?.toString() ?? '0') ?? 0,
      inStockOnly: json['in_stock_only'] as bool? ?? false,
      sortBy: json['sort_by']?.toString() ?? 'relevance',
    );
  }

  Map<String, dynamic> toJson() => {
    'category': category,
    'min_price': minPrice,
    'max_price': maxPrice,
    'rating': rating,
    'in_stock_only': inStockOnly,
    'sort_by': sortBy,
  };

  Map<String, dynamic> toQueryParameters() => {
    'category': category,
    'min_price': minPrice,
    'max_price': maxPrice,
    'rating': rating,
    'in_stock_only': inStockOnly,
    'sort_by': sortBy,
  };

  SearchFilterModel copyWith({
    String? category,
    double? minPrice,
    double? maxPrice,
    double? rating,
    bool? inStockOnly,
    String? sortBy,
  }) {
    return SearchFilterModel(
      category: category ?? this.category,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      rating: rating ?? this.rating,
      inStockOnly: inStockOnly ?? this.inStockOnly,
      sortBy: sortBy ?? this.sortBy,
    );
  }
}
