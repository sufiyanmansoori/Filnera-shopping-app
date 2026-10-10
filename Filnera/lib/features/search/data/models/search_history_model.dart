class SearchHistoryModel {
  const SearchHistoryModel({required this.query, this.createdAt});

  final String query;
  final DateTime? createdAt;

  factory SearchHistoryModel.fromJson(Map<String, dynamic> json) {
    return SearchHistoryModel(
      query: json['query']?.toString() ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'query': query,
    'created_at': createdAt?.toIso8601String(),
  };
}
