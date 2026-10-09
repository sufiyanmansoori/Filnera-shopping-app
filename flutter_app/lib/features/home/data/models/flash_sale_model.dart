import '../../domain/entities/flash_sale_entity.dart';

class FlashSaleModel {
  const FlashSaleModel({required this.entity});

  final FlashSaleEntity entity;

  String get id => entity.id;
  String get title => entity.title;
  String get slug => entity.slug;
  String get productId => entity.productId;
  String get productName => entity.productName;
  String get imageUrl => entity.imageUrl;
  double get originalPrice => entity.originalPrice;
  double get salePrice => entity.salePrice;
  double get discountPercent => entity.discountPercent;
  DateTime get endsAt => entity.endsAt;
  String? get badge => entity.badge;
  int get soldCount => entity.soldCount;
  int get totalStock => entity.totalStock;
  bool get isActive => entity.isActive;
  int get remainingStock => (totalStock - soldCount).clamp(0, totalStock);
  bool get hasDiscount => originalPrice > salePrice && originalPrice > 0;
  double get savings => hasDiscount ? originalPrice - salePrice : 0;
  bool get hasIdentity => id.isNotEmpty || productId.isNotEmpty;

  Duration remainingAt([DateTime? dateTime]) {
    final difference = endsAt.difference(dateTime ?? DateTime.now());
    return difference.isNegative ? Duration.zero : difference;
  }

  bool isLiveAt([DateTime? dateTime]) {
    final now = dateTime ?? DateTime.now();
    return isActive && now.isBefore(endsAt.add(const Duration(minutes: 1)));
  }

  factory FlashSaleModel.fromJson(Map<String, dynamic> json) {
    final sale = _unwrapSale(json);
    final product = _saleMap(sale['product'] ?? sale['item']);
    final productId = _saleText(<dynamic>[
      sale['product_id'],
      sale['productId'],
      sale['item_id'],
      sale['itemId'],
      product['id'],
      product['product_id'],
      product['productId'],
      product['sku'],
    ]);
    final title = _saleText(<dynamic>[
      sale['title'],
      sale['name'],
      sale['campaign_title'],
      sale['campaignTitle'],
    ], fallback: 'Flash sale');
    final originalPrice = _saleNumber(
      _firstSaleValue(<dynamic>[
        sale['original_price'],
        sale['originalPrice'],
        sale['compare_at_price'],
        sale['compareAtPrice'],
        sale['mrp'],
        product['original_price'],
        product['originalPrice'],
        product['mrp'],
        sale['price'],
        product['price'],
      ]),
    );
    final salePriceValue = _firstSaleValue(<dynamic>[
      sale['sale_price'],
      sale['salePrice'],
      sale['current_price'],
      sale['currentPrice'],
      sale['offer_price'],
      sale['offerPrice'],
      sale['discounted_price'],
      sale['discountedPrice'],
      sale['price'],
      product['sale_price'],
      product['current_price'],
      product['price'],
    ]);
    final salePrice = salePriceValue == null
        ? originalPrice
        : _saleNumber(salePriceValue);
    final explicitDiscount = _saleNumber(
      _firstSaleValue(<dynamic>[
        sale['discount_percent'],
        sale['discountPercent'],
        sale['discount_percentage'],
        sale['discountPercentage'],
        sale['discount'],
      ]),
    );
    final discountPercent = explicitDiscount > 0
        ? explicitDiscount.clamp(0, 100).toDouble()
        : originalPrice > salePrice && originalPrice > 0
        ? ((originalPrice - salePrice) / originalPrice * 100)
              .clamp(0, 100)
              .toDouble()
        : 0.0;
    final id = _saleText(<dynamic>[
      sale['id'],
      sale['sale_id'],
      sale['saleId'],
      sale['flash_sale_id'],
      sale['flashSaleId'],
    ], fallback: productId.isEmpty ? '' : 'sale-$productId');

    return FlashSaleModel(
      entity: FlashSaleEntity(
        id: id,
        title: title,
        slug: _saleText(<dynamic>[
          sale['slug'],
          sale['url_slug'],
          sale['urlSlug'],
        ]),
        productId: productId,
        productName: _saleText(<dynamic>[
          sale['product_name'],
          sale['productName'],
          product['title'],
          product['name'],
          product['productName'],
        ], fallback: title),
        imageUrl: _saleImage(sale, product),
        originalPrice: originalPrice,
        salePrice: salePrice,
        discountPercent: discountPercent,
        endsAt:
            _saleDate(
              sale['ends_at'] ??
                  sale['endsAt'] ??
                  sale['end_at'] ??
                  sale['endAt'] ??
                  sale['expires_at'] ??
                  sale['expiresAt'],
            ) ??
            DateTime.fromMillisecondsSinceEpoch(0),
        badge: _saleOptionalText(<dynamic>[
          sale['badge'],
          sale['tag'],
          sale['label'],
        ]),
        soldCount: _saleInt(
          sale['sold_count'] ?? sale['soldCount'] ?? sale['units_sold'],
        ),
        totalStock: _saleInt(
          sale['total_stock'] ??
              sale['totalStock'] ??
              sale['stock'] ??
              sale['inventory'],
        ),
        isActive: _saleBool(
          sale['is_active'] ?? sale['isActive'] ?? sale['active'],
          fallback: true,
        ),
      ),
    );
  }

  factory FlashSaleModel.fromEntity(FlashSaleEntity entity) =>
      FlashSaleModel(entity: entity);

  FlashSaleEntity toEntity() => entity;

  FlashSaleModel copyWith({
    String? id,
    String? title,
    String? slug,
    String? productId,
    String? productName,
    String? imageUrl,
    double? originalPrice,
    double? salePrice,
    double? discountPercent,
    DateTime? endsAt,
    String? badge,
    int? soldCount,
    int? totalStock,
    bool? isActive,
  }) => FlashSaleModel(
    entity: entity.copyWith(
      id: id,
      title: title,
      slug: slug,
      productId: productId,
      productName: productName,
      imageUrl: imageUrl,
      originalPrice: originalPrice,
      salePrice: salePrice,
      discountPercent: discountPercent,
      endsAt: endsAt,
      badge: badge,
      soldCount: soldCount,
      totalStock: totalStock,
      isActive: isActive,
    ),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'title': title,
    'slug': slug,
    'product_id': productId,
    'product_name': productName,
    'image_url': imageUrl,
    'original_price': originalPrice,
    'sale_price': salePrice,
    'discount_percent': discountPercent,
    'ends_at': endsAt.toUtc().toIso8601String(),
    'badge': badge,
    'sold_count': soldCount,
    'total_stock': totalStock,
    'is_active': isActive,
  };
}

Map<String, dynamic> _unwrapSale(Map<String, dynamic> source) {
  var sale = source;
  for (var depth = 0; depth < 4; depth++) {
    final nested = sale['flash_sale'] ?? sale['flashSale'] ?? sale['sale'];
    if (nested is Map) {
      sale = _saleMap(nested);
      continue;
    }
    final data = sale['data'];
    if (data is Map && !_looksLikeSale(sale)) {
      sale = _saleMap(data);
      continue;
    }
    break;
  }
  return sale;
}

bool _looksLikeSale(Map<String, dynamic> map) =>
    map.containsKey('id') ||
    map.containsKey('sale_id') ||
    map.containsKey('saleId') ||
    map.containsKey('product_id') ||
    map.containsKey('productId');

Map<String, dynamic> _saleMap(dynamic value) {
  if (value is! Map) return const <String, dynamic>{};
  return value.map((key, value) => MapEntry(key.toString(), value));
}

dynamic _firstSaleValue(Iterable<dynamic> values) {
  for (final value in values) {
    if (value == null) continue;
    if (value is String && value.trim().isEmpty) continue;
    return value;
  }
  return null;
}

String _saleText(Iterable<dynamic> values, {String fallback = ''}) {
  for (final value in values) {
    if (value == null) continue;
    final text = value.toString().trim();
    if (text.isNotEmpty && text != 'null') return text;
  }
  return fallback;
}

String? _saleOptionalText(Iterable<dynamic> values) {
  final text = _saleText(values);
  return text.isEmpty ? null : text;
}

double _saleNumber(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is Map) {
    return _saleNumber(value['amount'] ?? value['value'] ?? value['price']);
  }
  final normalized = value?.toString().replaceAll(',', '').trim() ?? '';
  final match = RegExp(r'-?\d+(?:\.\d+)?').firstMatch(normalized);
  return match == null ? 0 : double.tryParse(match.group(0)!) ?? 0;
}

int _saleInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is Map) {
    return _saleInt(value['count'] ?? value['quantity'] ?? value['value']);
  }
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

bool _saleBool(dynamic value, {required bool fallback}) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    switch (value.trim().toLowerCase()) {
      case 'true':
      case '1':
      case 'yes':
      case 'active':
        return true;
      case 'false':
      case '0':
      case 'no':
      case 'inactive':
        return false;
    }
  }
  return fallback;
}

DateTime? _saleDate(dynamic value) {
  if (value is DateTime) return value;
  if (value is int) {
    return DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);
  }
  if (value is String) {
    final normalized = value.trim();
    if (normalized.isEmpty) return null;
    final milliseconds = int.tryParse(normalized);
    if (milliseconds != null) {
      return DateTime.fromMillisecondsSinceEpoch(milliseconds, isUtc: true);
    }
    return DateTime.tryParse(normalized);
  }
  return null;
}

String _saleImage(Map<String, dynamic> sale, Map<String, dynamic> product) {
  final direct = _saleText(<dynamic>[
    sale['image_url'],
    sale['imageUrl'],
    sale['image'],
    sale['thumbnail'],
    product['image_url'],
    product['imageUrl'],
    product['image'],
    product['thumbnail'],
  ]);
  if (direct.isNotEmpty) return direct;

  final images = sale['images'] ?? product['images'];
  if (images is Iterable) {
    for (final image in images) {
      if (image is String && image.trim().isNotEmpty) return image.trim();
      if (image is Map) {
        final imageMap = _saleMap(image);
        final url = _saleText(<dynamic>[
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
