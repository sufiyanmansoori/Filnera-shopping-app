class ProductReviewModel {
  const ProductReviewModel({
    required this.id,
    required this.reviewerName,
    required this.rating,
    required this.title,
    required this.comment,
    required this.createdAt,
    this.verified = false,
    this.helpfulCount = 0,
  });

  final String id;
  final String reviewerName;
  final double rating;
  final String title;
  final String comment;
  final DateTime createdAt;
  final bool verified;
  final int helpfulCount;

  factory ProductReviewModel.fromJson(Map<String, dynamic> json) {
    return ProductReviewModel(
      id: json['id']?.toString() ?? '',
      reviewerName:
          json['reviewer_name']?.toString() ??
          json['reviewerName']?.toString() ??
          'Verified buyer',
      rating: double.tryParse(json['rating']?.toString() ?? '0') ?? 0,
      title: json['title']?.toString() ?? 'Review',
      comment: json['comment']?.toString() ?? '',
      createdAt:
          DateTime.tryParse(
            json['created_at']?.toString() ??
                json['createdAt']?.toString() ??
                '',
          ) ??
          DateTime.now(),
      verified: json['verified'] as bool? ?? false,
      helpfulCount:
          int.tryParse(
            json['helpful_count']?.toString() ??
                json['helpfulCount']?.toString() ??
                '0',
          ) ??
          0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'reviewer_name': reviewerName,
    'rating': rating,
    'title': title,
    'comment': comment,
    'created_at': createdAt.toIso8601String(),
    'verified': verified,
    'helpful_count': helpfulCount,
  };
}
