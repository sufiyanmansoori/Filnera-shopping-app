import '../../domain/entities/recommendation_entity.dart';

class RecommendationModel {
  const RecommendationModel({required this.entity});

  final RecommendationEntity entity;

  String get id => entity.id;
  String get productId => entity.productId;
  String get title => entity.title;
  String get imageUrl => entity.imageUrl;
  double get price => entity.price;
  double get compareAtPrice => entity.compareAtPrice;
  String? get reason => entity.reason;
  double get score => entity.score;
  bool get isFavorite => entity.isFavorite;
  String? get brand => entity.brand;
  String? get categoryId => entity.categoryId;
  bool get hasIdentity => productId.isNotEmpty && id.isNotEmpty;
  bool get hasDiscount => entity.hasDiscount;
  double get savings => hasDiscount ? compareAtPrice - price : 0;

  factory RecommendationModel.fromJson(Map<String, dynamic> json) {
    final source = _unwrapRecommendation(json);
    final product = _recommendationMap(
      source['product'] ?? source['item'] ?? source['recommended_product'],
    );
    final category = _recommendationMap(
      source['category'] ?? product['category'],
    );
    final productId = _recommendationText(<dynamic>[
      source['product_id'],
      source['productId'],
      source['item_id'],
      source['itemId'],
      product['id'],
      product['product_id'],
      product['productId'],
      product['sku'],
    ]);
    final price = _recommendationNumber(
      _firstRecommendationValue(<dynamic>[
        source['price'],
        source['current_price'],
        source['currentPrice'],
        source['sale_price'],
        source['salePrice'],
        source['offer_price'],
        source['offerPrice'],
        product['price'],
        product['current_price'],
        product['currentPrice'],
        product['sale_price'],
        product['salePrice'],
      ]),
    );
    final compareAtPrice = _recommendationNumber(
      _firstRecommendationValue(<dynamic>[
        source['compare_at_price'],
        source['compareAtPrice'],
        source['original_price'],
        source['originalPrice'],
        source['mrp'],
        product['compare_at_price'],
        product['original_price'],
        product['originalPrice'],
        product['mrp'],
      ]),
    );

    return RecommendationModel(
      entity: RecommendationEntity(
        id: _recommendationText(<dynamic>[
          source['id'],
          source['recommendation_id'],
          source['recommendationId'],
        ], fallback: productId.isEmpty ? '' : 'rec-$productId'),
        productId: productId,
        title: _recommendationText(<dynamic>[
          source['title'],
          source['name'],
          source['product_name'],
          source['productName'],
          product['title'],
          product['name'],
          product['product_name'],
          product['productName'],
        ], fallback: 'Recommended product'),
        imageUrl: _recommendationImage(source, product),
        price: price,
        compareAtPrice: compareAtPrice < price ? price : compareAtPrice,
        reason: _recommendationOptionalText(<dynamic>[
          source['reason'],
          source['recommendation_reason'],
          source['recommendationReason'],
          source['subtitle'],
        ]),
        score: _recommendationNumber(
          _firstRecommendationValue(<dynamic>[
            source['score'],
            source['relevance_score'],
            source['relevanceScore'],
            source['confidence'],
          ]),
        ),
        isFavorite: _recommendationBool(
          source['is_favorite'] ??
              source['isFavorite'] ??
              source['is_wishlisted'] ??
              source['isWishlisted'],
        ),
        brand: _recommendationOptionalText(<dynamic>[
          source['brand'],
          source['brand_name'],
          source['brandName'],
          product['brand'],
          product['brand_name'],
          product['brandName'],
        ]),
        categoryId: _recommendationOptionalText(<dynamic>[
          source['category_id'],
          source['categoryId'],
          category['id'],
          category['category_id'],
          category['slug'],
          if (source['category'] is String) source['category'],
        ]),
      ),
    );
  }

  factory RecommendationModel.fromEntity(RecommendationEntity entity) =>
      RecommendationModel(entity: entity);

  RecommendationEntity toEntity() => entity;

  RecommendationModel copyWith({
    String? id,
    String? productId,
    String? title,
    String? imageUrl,
    double? price,
    double? compareAtPrice,
    String? reason,
    double? score,
    bool? isFavorite,
    String? brand,
    String? categoryId,
  }) => RecommendationModel(
    entity: entity.copyWith(
      id: id,
      productId: productId,
      title: title,
      imageUrl: imageUrl,
      price: price,
      compareAtPrice: compareAtPrice,
      reason: reason,
      score: score,
      isFavorite: isFavorite,
      brand: brand,
      categoryId: categoryId,
    ),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'product_id': productId,
    'title': title,
    'image_url': imageUrl,
    'price': price,
    'compare_at_price': compareAtPrice,
    'reason': reason,
    'score': score,
    'is_favorite': isFavorite,
    'brand': brand,
    'category_id': categoryId,
  };
}

Map<String, dynamic> _unwrapRecommendation(Map<String, dynamic> source) {
  var recommendation = source;
  for (var depth = 0; depth < 4; depth++) {
    final nested = recommendation['recommendation'];
    if (nested is Map) {
      recommendation = _recommendationMap(nested);
      continue;
    }
    final data = recommendation['data'];
    if (data is Map && !_looksLikeRecommendation(recommendation)) {
      recommendation = _recommendationMap(data);
      continue;
    }
    break;
  }
  return recommendation;
}

bool _looksLikeRecommendation(Map<String, dynamic> map) =>
    map.containsKey('product_id') ||
    map.containsKey('productId') ||
    map.containsKey('product') ||
    map.containsKey('recommendation_id') ||
    map.containsKey('recommendationId');

Map<String, dynamic> _recommendationMap(dynamic value) {
  if (value is! Map) return const <String, dynamic>{};
  return value.map((key, value) => MapEntry(key.toString(), value));
}

String _recommendationText(Iterable<dynamic> values, {String fallback = ''}) {
  for (final value in values) {
    if (value == null) continue;
    final text = value.toString().trim();
    if (text.isNotEmpty && text != 'null') return text;
  }
  return fallback;
}

String? _recommendationOptionalText(Iterable<dynamic> values) {
  final text = _recommendationText(values);
  return text.isEmpty ? null : text;
}

dynamic _firstRecommendationValue(Iterable<dynamic> values) {
  for (final value in values) {
    if (value == null) continue;
    if (value is String && value.trim().isEmpty) continue;
    return value;
  }
  return null;
}

double _recommendationNumber(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is Map) {
    return _recommendationNumber(
      value['amount'] ?? value['value'] ?? value['price'],
    );
  }
  final normalized = value?.toString().replaceAll(',', '').trim() ?? '';
  final match = RegExp(r'-?\d+(?:\.\d+)?').firstMatch(normalized);
  return match == null ? 0 : double.tryParse(match.group(0)!) ?? 0;
}

bool _recommendationBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    switch (value.trim().toLowerCase()) {
      case 'true':
      case '1':
      case 'yes':
      case 'favorite':
        return true;
      case 'false':
      case '0':
      case 'no':
        return false;
    }
  }
  return false;
}

String _recommendationImage(
  Map<String, dynamic> recommendation,
  Map<String, dynamic> product,
) {
  final direct = _recommendationText(<dynamic>[
    recommendation['image_url'],
    recommendation['imageUrl'],
    recommendation['image'],
    recommendation['thumbnail'],
    product['image_url'],
    product['imageUrl'],
    product['image'],
    product['thumbnail'],
  ]);
  if (direct.isNotEmpty) return direct;

  final images = recommendation['images'] ?? product['images'];
  if (images is Iterable) {
    for (final image in images) {
      if (image is String && image.trim().isNotEmpty) return image.trim();
      if (image is Map) {
        final imageMap = _recommendationMap(image);
        final url = _recommendationText(<dynamic>[
          imageMap['url'],
          imageMap['image_url'],
          imageMap['imageUrl'],
          imageMap['src'],
        ]);
        if (url.isNotEmpty) return url;
      }
    }
  }
  return '';
}
