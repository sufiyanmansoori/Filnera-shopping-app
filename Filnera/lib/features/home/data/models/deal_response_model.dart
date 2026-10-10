import 'home_deal_model.dart';

class DealItemModel {
  DealItemModel({
    required this.deal,
    this.campaignId,
    this.seller,
    this.rating = 0,
    this.reviewsCount = 0,
    Iterable<String> tags = const <String>[],
    Map<String, dynamic> metadata = const <String, dynamic>{},
  }) : tags = List<String>.unmodifiable(tags),
       metadata = Map<String, dynamic>.unmodifiable(metadata);

  final HomeDealModel deal;
  final String? campaignId;
  final String? seller;
  final double rating;
  final int reviewsCount;
  final List<String> tags;
  final Map<String, dynamic> metadata;

  String get id => deal.id;
  String get title => deal.title;
  String get productId => deal.productId;
  String get productName => deal.productName;
  double get originalPrice => deal.originalPrice;
  double get currentPrice => deal.currentPrice;
  double get discountPercent => deal.discountPercent;
  String get imageUrl => deal.imageUrl;
  bool get isActive => deal.isActive;
  double get stockProgress => deal.stockProgress;
  int get soldCount => deal.soldCount;
  int get remainingCount => deal.remainingCount;
  bool get hasDiscount =>
      deal.originalPrice > 0 && deal.currentPrice < deal.originalPrice;
  double get savings => deal.originalPrice - deal.currentPrice;

  bool get hasContent => id.isNotEmpty;

  bool isLiveAt([DateTime? dateTime]) {
    final now = dateTime ?? DateTime.now();
    return isActive &&
        (deal.startAt == null || !now.isBefore(deal.startAt!)) &&
        (deal.endAt == null || !now.isAfter(deal.endAt!));
  }

  factory DealItemModel.fromJson(Map<String, dynamic> json) {
    final product = _dealMap(json['product'] ?? json['item']);
    final title = _dealText(<dynamic>[
      json['title'],
      json['deal_title'],
      json['dealTitle'],
      json['name'],
    ], fallback: 'Deal');
    final productId = _dealText(<dynamic>[
      json['product_id'],
      json['productId'],
      json['item_id'],
      json['itemId'],
      product['id'],
      product['product_id'],
    ]);
    final productName = _dealText(<dynamic>[
      json['product_name'],
      json['productName'],
      json['product_title'],
      json['productTitle'],
      product['name'],
      product['title'],
      title,
    ], fallback: title);
    final dealId = _dealText(<dynamic>[
      json['id'],
      json['deal_id'],
      json['dealId'],
    ], fallback: productId.isEmpty ? '' : 'deal-$productId');

    final originalPrice = _dealNumber(
      _firstDealValue(<dynamic>[
        json['original_price'],
        json['originalPrice'],
        json['list_price'],
        json['listPrice'],
        json['mrp'],
        product['original_price'],
        product['originalPrice'],
        product['mrp'],
        json['price'],
        product['price'],
      ]),
    );
    final currentPriceValue = _firstDealValue(<dynamic>[
      json['current_price'],
      json['currentPrice'],
      json['sale_price'],
      json['salePrice'],
      json['offer_price'],
      json['offerPrice'],
      json['discounted_price'],
      json['discountedPrice'],
      json['price'],
      product['current_price'],
      product['sale_price'],
      product['price'],
    ]);
    final currentPrice = currentPriceValue == null
        ? originalPrice
        : _dealNumber(currentPriceValue);
    final discountValue = _firstDealValue(<dynamic>[
      json['discount_percent'],
      json['discountPercent'],
      json['discount_percentage'],
      json['discountPercentage'],
      json['discount'],
    ]);
    final explicitDiscount = _dealNumber(discountValue);
    final discountPercent = explicitDiscount > 0
        ? explicitDiscount.clamp(0, 100).toDouble()
        : originalPrice > 0 && currentPrice < originalPrice
        ? ((originalPrice - currentPrice) / originalPrice * 100)
              .clamp(0, 100)
              .toDouble()
        : 0.0;

    final normalizedDeal = <String, dynamic>{
      'id': dealId,
      'title': title,
      'slug': _dealText(<dynamic>[
        json['slug'],
        json['url_slug'],
        json['urlSlug'],
      ]),
      'product_id': productId,
      'product_name': productName,
      'original_price': originalPrice,
      'current_price': currentPrice,
      'discount_percent': discountPercent,
      'image_url': _dealText(<dynamic>[
        json['image_url'],
        json['imageUrl'],
        json['image'],
        json['thumbnail'],
        product['image_url'],
        product['imageUrl'],
        product['image'],
      ]),
      'badge': _dealText(<dynamic>[json['badge'], json['tag'], json['label']]),
      'description': _dealText(<dynamic>[
        json['description'],
        json['subtitle'],
      ]),
      'start_at': json['start_at'] ?? json['startAt'] ?? json['starts_at'],
      'end_at': json['end_at'] ?? json['endAt'] ?? json['expires_at'],
      'is_active': _dealBool(
        json['is_active'] ?? json['isActive'] ?? json['active'],
        fallback: true,
      ),
      'stock_progress': _dealNumber(
        json['stock_progress'] ?? json['stockProgress'],
      ).clamp(0, 100).toDouble(),
      'sold_count': _dealInteger(json['sold_count'] ?? json['soldCount']),
      'remaining_count': _dealInteger(
        json['remaining_count'] ?? json['remainingCount'],
      ),
      'cta_label': _dealText(<dynamic>[
        json['cta_label'],
        json['ctaLabel'],
        json['button_text'],
      ]),
      'category_id': _dealText(<dynamic>[
        json['category_id'],
        json['categoryId'],
        product['category_id'],
        product['categoryId'],
      ]),
    };

    return DealItemModel(
      deal: HomeDealModel.fromJson(normalizedDeal),
      campaignId: _dealOptionalText(
        json['campaign_id'] ?? json['campaignId'] ?? json['campaign'],
      ),
      seller: _dealOptionalText(
        json['seller'] ?? json['seller_name'] ?? json['sellerName'],
      ),
      rating: _dealNumber(json['rating'] ?? product['rating']),
      reviewsCount: _dealInteger(
        json['reviews_count'] ??
            json['reviewsCount'] ??
            json['review_count'] ??
            json['reviewCount'] ??
            product['review_count'],
      ),
      tags: _dealStringList(json['tags'] ?? json['highlights']),
      metadata: _dealMap(json['metadata'] ?? json['meta']),
    );
  }

  factory DealItemModel.fromHomeDeal(HomeDealModel deal) =>
      DealItemModel(deal: deal);

  DealItemModel copyWith({
    HomeDealModel? deal,
    String? campaignId,
    String? seller,
    double? rating,
    int? reviewsCount,
    Iterable<String>? tags,
    Map<String, dynamic>? metadata,
  }) => DealItemModel(
    deal: deal ?? this.deal,
    campaignId: campaignId ?? this.campaignId,
    seller: seller ?? this.seller,
    rating: rating ?? this.rating,
    reviewsCount: reviewsCount ?? this.reviewsCount,
    tags: tags ?? this.tags,
    metadata: metadata ?? this.metadata,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    ...deal.toJson(),
    if (campaignId != null) 'campaign_id': campaignId,
    if (seller != null) 'seller': seller,
    'rating': rating,
    'reviews_count': reviewsCount,
    'tags': tags,
    'metadata': metadata,
  };
}

class DealResponseModel {
  DealResponseModel({
    Iterable<DealItemModel> deals = const <DealItemModel>[],
    this.success = true,
    this.message,
    this.statusCode,
    this.requestId,
    this.timestamp,
    this.page,
    this.pageSize,
    this.totalItems,
    Iterable<String> errors = const <String>[],
    Map<String, dynamic> metadata = const <String, dynamic>{},
  }) : deals = List<DealItemModel>.unmodifiable(deals),
       errors = List<String>.unmodifiable(errors),
       metadata = Map<String, dynamic>.unmodifiable(metadata);

  final List<DealItemModel> deals;
  final bool success;
  final String? message;
  final int? statusCode;
  final String? requestId;
  final DateTime? timestamp;
  final int? page;
  final int? pageSize;
  final int? totalItems;
  final List<String> errors;
  final Map<String, dynamic> metadata;

  bool get isSuccessful =>
      success &&
      (statusCode == null || (statusCode! >= 200 && statusCode! < 300));

  bool get hasMore =>
      page != null &&
      pageSize != null &&
      totalItems != null &&
      page! * pageSize! < totalItems!;

  factory DealResponseModel.fromJson(Map<String, dynamic> json) =>
      DealResponseModel.fromValue(json);

  factory DealResponseModel.fromValue(dynamic value) {
    final root = _dealMap(value);
    final errors = _dealErrors(root['errors'] ?? root['error']);
    final statusCode = _dealInteger(
      root['status_code'] ?? root['statusCode'] ?? root['code'],
    );
    final success = _dealBool(
      root['success'] ?? root['ok'],
      fallback: errors.isEmpty && (statusCode < 400),
    );
    final metadata = _dealMap(root['metadata'] ?? root['meta']);
    final pagination = _dealMap(root['pagination'] ?? metadata['pagination']);
    final items = _extractDealItems(value)
        .whereType<Map>()
        .map((item) => DealItemModel.fromJson(_dealMap(item)))
        .where((deal) => deal.hasContent)
        .toList(growable: false);

    return DealResponseModel(
      deals: items,
      success: success,
      message: _dealOptionalText(root['message'] ?? root['detail']),
      statusCode: statusCode,
      requestId: _dealOptionalText(
        root['request_id'] ?? root['requestId'] ?? root['trace_id'],
      ),
      timestamp: _dealDate(
        root['timestamp'] ?? root['generated_at'] ?? root['generatedAt'],
      ),
      page: _dealInteger(
        root['page'] ?? root['current_page'] ?? pagination['page'],
      ),
      pageSize: _dealInteger(
        root['page_size'] ??
            root['pageSize'] ??
            root['limit'] ??
            pagination['page_size'] ??
            pagination['pageSize'],
      ),
      totalItems: _dealInteger(
        root['total_items'] ??
            root['totalItems'] ??
            root['total'] ??
            pagination['total_items'] ??
            pagination['totalItems'] ??
            pagination['total'],
      ),
      errors: errors,
      metadata: metadata,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'success': success,
    'data': deals.map((deal) => deal.toJson()).toList(growable: false),
    if (message != null) 'message': message,
    if (statusCode != null) 'status_code': statusCode,
    if (requestId != null) 'request_id': requestId,
    if (timestamp != null) 'timestamp': timestamp!.toUtc().toIso8601String(),
    if (page != null) 'page': page,
    if (pageSize != null) 'page_size': pageSize,
    if (totalItems != null) 'total_items': totalItems,
    if (errors.isNotEmpty) 'errors': errors,
    if (metadata.isNotEmpty) 'meta': metadata,
  };

  static List<dynamic> _extractDealItems(dynamic value, [int depth = 0]) {
    if (depth > 5) return const <dynamic>[];
    if (value is List) return value;
    if (value is! Map) return const <dynamic>[];

    final map = _dealMap(value);
    for (final key in const <String>[
      'deals',
      'items',
      'results',
      'content',
      'data',
    ]) {
      final candidate = map[key];
      if (candidate is List) return candidate;
      if (candidate is Map) {
        final nested = _extractDealItems(candidate, depth + 1);
        if (nested.isNotEmpty) return nested;
      }
    }

    if (_looksLikeDeal(map)) return <dynamic>[map];
    return const <dynamic>[];
  }

  static bool _looksLikeDeal(Map<String, dynamic> map) =>
      map.containsKey('id') ||
      map.containsKey('deal_id') ||
      map.containsKey('dealId') ||
      map.containsKey('product_id') ||
      map.containsKey('productId') ||
      map.containsKey('current_price') ||
      map.containsKey('sale_price');
}

Map<String, dynamic> _dealMap(dynamic value) {
  if (value is! Map) return const <String, dynamic>{};
  return value.map((key, value) => MapEntry(key.toString(), value));
}

dynamic _firstDealValue(Iterable<dynamic> values) {
  for (final value in values) {
    if (value == null) continue;
    if (value is String && value.trim().isEmpty) continue;
    return value;
  }
  return null;
}

String _dealText(Iterable<dynamic> values, {String fallback = ''}) {
  for (final value in values) {
    if (value == null) continue;
    final text = value.toString().trim();
    if (text.isNotEmpty) return text;
  }
  return fallback;
}

String? _dealOptionalText(dynamic value) {
  final text = _dealText(<dynamic>[value]);
  return text.isEmpty ? null : text;
}

double _dealNumber(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is Map) {
    return _dealNumber(value['amount'] ?? value['value'] ?? value['price']);
  }
  final normalized = value?.toString().replaceAll(',', '').trim() ?? '';
  final match = RegExp(r'-?\d+(?:\.\d+)?').firstMatch(normalized);
  return match == null ? 0 : double.tryParse(match.group(0)!) ?? 0;
}

int _dealInteger(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is Map) {
    return _dealInteger(value['count'] ?? value['value'] ?? value['total']);
  }
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

bool _dealBool(dynamic value, {required bool fallback}) {
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

DateTime? _dealDate(dynamic value) {
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  return null;
}

List<String> _dealStringList(dynamic value) {
  if (value is! Iterable) return const <String>[];
  return value
      .map(
        (item) => item is Map
            ? _dealText(<dynamic>[item['name'], item['label'], item['value']])
            : item.toString().trim(),
      )
      .where((item) => item.isNotEmpty)
      .toList(growable: false);
}

List<String> _dealErrors(dynamic value) {
  if (value == null) return const <String>[];
  if (value is String) {
    final message = value.trim();
    return message.isEmpty ? const <String>[] : <String>[message];
  }
  if (value is Iterable) {
    return value.expand(_dealErrors).toList(growable: false);
  }
  if (value is Map) {
    return value.entries
        .expand((entry) {
          final field = entry.key.toString();
          return _dealErrors(entry.value).map((message) => '$field: $message');
        })
        .toList(growable: false);
  }
  return const <String>[];
}
