import '../../domain/entities/featured_product_entity.dart';

class FeaturedProductModel {
  const FeaturedProductModel({required this.entity});

  final FeaturedProductEntity entity;

  String get id => entity.id;
  String get title => entity.title;
  String get slug => entity.slug;
  String get imageUrl => entity.imageUrl;
  double get price => entity.price;
  double get compareAtPrice => entity.compareAtPrice;
  double get rating => entity.rating;
  int get reviewCount => entity.reviewCount;
  String? get badge => entity.badge;
  String? get brand => entity.brand;
  String? get seller => entity.seller;
  bool get isSponsored => entity.isSponsored;
  bool get isNew => entity.isNew;
  StockStatus get stockStatus => entity.stockStatus;
  String? get categoryId => entity.categoryId;
  bool get hasIdentity => id.isNotEmpty;
  bool get hasDiscount => entity.hasDiscount;
  double get discountPercent => entity.discountPercent;

  factory FeaturedProductModel.fromJson(Map<String, dynamic> json) {
    final product = _unwrapProduct(json);
    final category = _asMap(product['category']);
    final price = _firstNumber(<dynamic>[
      product['price'],
      product['current_price'],
      product['currentPrice'],
      product['sale_price'],
      product['salePrice'],
      product['offer_price'],
      product['offerPrice'],
    ]);
    final compareAtPrice = _firstNumber(<dynamic>[
      product['compare_at_price'],
      product['compareAtPrice'],
      product['original_price'],
      product['originalPrice'],
      product['list_price'],
      product['listPrice'],
      product['mrp'],
    ]);
    final stockValue = _firstValue(<dynamic>[
      product['stock'],
      product['stock_quantity'],
      product['stockQuantity'],
      product['inventory_quantity'],
      product['inventoryQuantity'],
      product['quantity_available'],
    ]);

    return FeaturedProductModel(
      entity: FeaturedProductEntity(
        id: _firstText(<dynamic>[
          product['id'],
          product['product_id'],
          product['productId'],
          product['sku'],
        ]),
        title: _firstText(<dynamic>[
          product['title'],
          product['name'],
          product['product_name'],
          product['productName'],
        ], fallback: 'Featured product'),
        slug: _firstText(<dynamic>[
          product['slug'],
          product['url_slug'],
          product['urlSlug'],
          product['handle'],
        ]),
        imageUrl: _imageUrl(product),
        price: price,
        compareAtPrice: compareAtPrice < price ? price : compareAtPrice,
        rating: _firstNumber(<dynamic>[
          product['rating'],
          product['average_rating'],
          product['averageRating'],
          product['stars'],
        ]),
        reviewCount: _firstInteger(<dynamic>[
          product['review_count'],
          product['reviewCount'],
          product['reviews_count'],
          product['reviewsCount'],
        ]),
        badge: _optionalText(<dynamic>[
          product['badge'],
          product['tag'],
          product['label'],
        ]),
        brand: _optionalText(<dynamic>[
          product['brand'],
          product['brand_name'],
          product['brandName'],
        ]),
        seller: _optionalText(<dynamic>[
          product['seller'],
          product['seller_name'],
          product['sellerName'],
        ]),
        isSponsored: _asBool(
          product['is_sponsored'] ??
              product['isSponsored'] ??
              product['sponsored'],
        ),
        isNew: _asBool(
          product['is_new'] ?? product['isNew'] ?? product['new_arrival'],
        ),
        stockStatus: _stockStatus(
          product['stock_status'] ??
              product['stockStatus'] ??
              product['availability'],
          stockValue: stockValue,
          hasStockValue: stockValue != null,
        ),
        categoryId: _optionalText(<dynamic>[
          product['category_id'],
          product['categoryId'],
          category['id'],
          category['slug'],
          category['name'],
          if (product['category'] is String) product['category'],
        ]),
      ),
    );
  }

  factory FeaturedProductModel.fromEntity(FeaturedProductEntity entity) =>
      FeaturedProductModel(entity: entity);

  FeaturedProductEntity toEntity() => entity;

  FeaturedProductModel copyWith({
    String? id,
    String? title,
    String? slug,
    String? imageUrl,
    double? price,
    double? compareAtPrice,
    double? rating,
    int? reviewCount,
    String? badge,
    String? brand,
    String? seller,
    bool? isSponsored,
    bool? isNew,
    StockStatus? stockStatus,
    String? categoryId,
  }) => FeaturedProductModel(
    entity: entity.copyWith(
      id: id,
      title: title,
      slug: slug,
      imageUrl: imageUrl,
      price: price,
      compareAtPrice: compareAtPrice,
      rating: rating,
      reviewCount: reviewCount,
      badge: badge,
      brand: brand,
      seller: seller,
      isSponsored: isSponsored,
      isNew: isNew,
      stockStatus: stockStatus,
      categoryId: categoryId,
    ),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'title': title,
    'slug': slug,
    'image_url': imageUrl,
    'price': price,
    'compare_at_price': compareAtPrice,
    'rating': rating,
    'review_count': reviewCount,
    'badge': badge,
    'brand': brand,
    'seller': seller,
    'is_sponsored': isSponsored,
    'is_new': isNew,
    'stock_status': stockStatus.name,
    'category_id': categoryId,
  };
}

Map<String, dynamic> _unwrapProduct(Map<String, dynamic> source) {
  var product = source;
  for (var depth = 0; depth < 4; depth++) {
    final nested = product['product'] ?? product['item'];
    if (nested is Map) {
      product = _asMap(nested);
      continue;
    }
    final data = product['data'];
    if (data is Map && !_looksLikeProduct(product)) {
      product = _asMap(data);
      continue;
    }
    break;
  }
  return product;
}

bool _looksLikeProduct(Map<String, dynamic> map) =>
    map.containsKey('id') ||
    map.containsKey('product_id') ||
    map.containsKey('productId') ||
    map.containsKey('sku');

String _imageUrl(Map<String, dynamic> product) {
  final direct = _firstText(<dynamic>[
    product['image_url'],
    product['imageUrl'],
    product['image'],
    product['thumbnail'],
    product['featured_image'],
    product['featuredImage'],
  ]);
  if (direct.isNotEmpty) return direct;

  final images = product['images'] ?? product['gallery'];
  if (images is Iterable) {
    for (final image in images) {
      if (image is String && image.trim().isNotEmpty) return image.trim();
      if (image is Map) {
        final imageMap = _asMap(image);
        final url = _firstText(<dynamic>[
          imageMap['url'],
          imageMap['src'],
          imageMap['image_url'],
          imageMap['imageUrl'],
        ]);
        if (url.isNotEmpty) return url;
      }
    }
  }
  return '';
}

StockStatus _stockStatus(
  dynamic status, {
  required dynamic stockValue,
  required bool hasStockValue,
}) {
  if (status is num) {
    if (status <= 0) return StockStatus.outOfStock;
    if (status <= 5) return StockStatus.lowStock;
    return StockStatus.inStock;
  }
  if (status is String) {
    switch (status.trim().toLowerCase().replaceAll(RegExp(r'[\s-]'), '_')) {
      case 'out_of_stock':
      case 'outofstock':
      case 'unavailable':
      case 'sold_out':
        return StockStatus.outOfStock;
      case 'low_stock':
      case 'lowstock':
      case 'limited_stock':
        return StockStatus.lowStock;
      case 'preorder':
      case 'pre_order':
      case 'coming_soon':
        return StockStatus.preorder;
      case 'in_stock':
      case 'instock':
      case 'available':
        return StockStatus.inStock;
    }
  }
  if (!hasStockValue) return StockStatus.inStock;
  final quantity = _number(stockValue).toInt();
  if (quantity <= 0) return StockStatus.outOfStock;
  if (quantity <= 5) return StockStatus.lowStock;
  return StockStatus.inStock;
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is! Map) return const <String, dynamic>{};
  return value.map((key, value) => MapEntry(key.toString(), value));
}

dynamic _firstValue(Iterable<dynamic> values) {
  for (final value in values) {
    if (value == null) continue;
    if (value is String && value.trim().isEmpty) continue;
    return value;
  }
  return null;
}

String _firstText(Iterable<dynamic> values, {String fallback = ''}) {
  for (final value in values) {
    if (value == null) continue;
    final text = value.toString().trim();
    if (text.isNotEmpty && text != 'null') return text;
  }
  return fallback;
}

String? _optionalText(Iterable<dynamic> values) {
  final text = _firstText(values);
  return text.isEmpty ? null : text;
}

double _firstNumber(Iterable<dynamic> values) {
  for (final value in values) {
    final number = _number(value);
    if (number != 0) return number;
  }
  return 0;
}

double _number(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is Map) {
    return _number(value['amount'] ?? value['value'] ?? value['price']);
  }
  final normalized = value?.toString().replaceAll(',', '').trim() ?? '';
  final match = RegExp(r'-?\d+(?:\.\d+)?').firstMatch(normalized);
  return match == null ? 0 : double.tryParse(match.group(0)!) ?? 0;
}

int _firstInteger(Iterable<dynamic> values) {
  for (final value in values) {
    final parsed = _number(value).toInt();
    if (parsed != 0) return parsed;
  }
  return 0;
}

bool _asBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    switch (value.trim().toLowerCase()) {
      case 'true':
      case '1':
      case 'yes':
      case 'sponsored':
      case 'new':
        return true;
      case 'false':
      case '0':
      case 'no':
        return false;
    }
  }
  return false;
}
