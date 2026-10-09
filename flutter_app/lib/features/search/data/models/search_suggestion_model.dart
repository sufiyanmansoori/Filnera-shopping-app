class SearchSuggestionModel {
  const SearchSuggestionModel({
    required this.id,
    required this.text,
    required this.category,
    required this.score,
  });

  final String id;
  final String text;
  final String category;
  final double score;

  factory SearchSuggestionModel.fromJson(Map<String, dynamic> json) {
    return SearchSuggestionModel(
      id: json['id']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      category: json['category']?.toString() ?? 'general',
      score: double.tryParse(json['score']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'category': category,
    'score': score,
  };
}
