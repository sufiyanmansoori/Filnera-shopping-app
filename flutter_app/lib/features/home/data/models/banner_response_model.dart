import '../../domain/entities/banner_entity.dart';

class BannerItemModel {
  BannerItemModel({
    this.id = '',
    this.title = 'Promotion',
    this.subtitle = '',
    this.description = '',
    this.imageUrl = '',
    this.deepLink = '/products',
    this.type = 'promo',
    this.priority = 'regular',
    this.position = 'regular',
    this.ctaLabel = 'Shop now',
    this.isActive = true,
    this.categoryId = '',
    this.campaignId = '',
    this.startAt,
    this.endAt,
    this.orderIndex = 0,
    this.altText = 'Offer banner',
    this.backgroundColor = '#F5F5F7',
    Map<String, dynamic> metadata = const <String, dynamic>{},
    this.isFeatured = false,
  }) : metadata = Map<String, dynamic>.unmodifiable(metadata);

  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String imageUrl;
  final String deepLink;
  final String type;
  final String priority;
  final String position;
  final String ctaLabel;
  final bool isActive;
  final String categoryId;
  final String campaignId;
  final DateTime? startAt;
  final DateTime? endAt;
  final int orderIndex;
  final String altText;
  final String backgroundColor;
  final Map<String, dynamic> metadata;
  final bool isFeatured;

  bool get hasContent =>
      id.isNotEmpty || imageUrl.isNotEmpty || title != 'Promotion';

  bool isVisibleAt([DateTime? dateTime]) {
    final now = dateTime ?? DateTime.now();
    return isActive &&
        (startAt == null || !now.isBefore(startAt!)) &&
        (endAt == null || !now.isAfter(endAt!));
  }

  factory BannerItemModel.fromJson(Map<String, dynamic> json) {
    final title = _bannerText(<dynamic>[json['title'], json['name']]);
    final deepLink = _bannerText(<dynamic>[
      json['deep_link'],
      json['deepLink'],
      json['target_url'],
      json['targetUrl'],
      json['link'],
    ]);

    return BannerItemModel(
      id: _bannerText(<dynamic>[
        json['id'],
        json['banner_id'],
        json['bannerId'],
      ]),
      title: title.isEmpty ? 'Promotion' : title,
      subtitle: _bannerText(<dynamic>[json['subtitle'], json['sub_title']]),
      description: _bannerText(<dynamic>[json['description'], json['body']]),
      imageUrl: _bannerText(<dynamic>[
        json['image_url'],
        json['imageUrl'],
        json['image'],
        json['desktop_image'],
      ]),
      deepLink: deepLink.isEmpty ? '/products' : deepLink,
      type: _bannerText(<dynamic>[
        json['type'],
        json['banner_type'],
        json['bannerType'],
      ], fallback: 'promo'),
      priority: _bannerText(<dynamic>[
        json['priority'],
        json['position'],
      ], fallback: 'regular'),
      position: _bannerText(<dynamic>[
        json['position'],
        json['priority'],
      ], fallback: 'regular'),
      ctaLabel: _bannerText(<dynamic>[
        json['cta_label'],
        json['ctaLabel'],
        json['button_text'],
      ], fallback: 'Shop now'),
      isActive: _bannerBool(
        json['is_active'] ?? json['isActive'] ?? json['active'],
        fallback: true,
      ),
      categoryId: _bannerText(<dynamic>[
        json['category_id'],
        json['categoryId'],
      ]),
      campaignId: _bannerText(<dynamic>[
        json['campaign_id'],
        json['campaignId'],
      ]),
      startAt: _bannerDate(json['start_at'] ?? json['startAt']),
      endAt: _bannerDate(json['end_at'] ?? json['endAt']),
      orderIndex: _bannerInt(json['order_index'] ?? json['orderIndex']) ?? 0,
      altText: _bannerText(<dynamic>[
        json['alt_text'],
        json['altText'],
        json['title'],
        json['name'],
      ], fallback: 'Offer banner'),
      backgroundColor: _bannerText(<dynamic>[
        json['background_color'],
        json['backgroundColor'],
      ], fallback: '#F5F5F7'),
      metadata: _bannerMap(json['metadata'] ?? json['meta']),
      isFeatured: _bannerBool(
        json['is_featured'] ?? json['isFeatured'],
        fallback: false,
      ),
    );
  }

  factory BannerItemModel.fromEntity(BannerEntity entity) => BannerItemModel(
    id: entity.id,
    title: entity.title,
    imageUrl: entity.imageUrl,
    deepLink: entity.deepLink ?? '/products',
    isActive: entity.isActive,
  );

  BannerEntity toEntity() => BannerEntity(
    id: id,
    title: title,
    imageUrl: imageUrl,
    deepLink: deepLink,
    isActive: isActive,
  );

  BannerItemModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? description,
    String? imageUrl,
    String? deepLink,
    String? type,
    String? priority,
    String? position,
    String? ctaLabel,
    bool? isActive,
    String? categoryId,
    String? campaignId,
    DateTime? startAt,
    DateTime? endAt,
    int? orderIndex,
    String? altText,
    String? backgroundColor,
    Map<String, dynamic>? metadata,
    bool? isFeatured,
  }) => BannerItemModel(
    id: id ?? this.id,
    title: title ?? this.title,
    subtitle: subtitle ?? this.subtitle,
    description: description ?? this.description,
    imageUrl: imageUrl ?? this.imageUrl,
    deepLink: deepLink ?? this.deepLink,
    type: type ?? this.type,
    priority: priority ?? this.priority,
    position: position ?? this.position,
    ctaLabel: ctaLabel ?? this.ctaLabel,
    isActive: isActive ?? this.isActive,
    categoryId: categoryId ?? this.categoryId,
    campaignId: campaignId ?? this.campaignId,
    startAt: startAt ?? this.startAt,
    endAt: endAt ?? this.endAt,
    orderIndex: orderIndex ?? this.orderIndex,
    altText: altText ?? this.altText,
    backgroundColor: backgroundColor ?? this.backgroundColor,
    metadata: metadata ?? this.metadata,
    isFeatured: isFeatured ?? this.isFeatured,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'title': title,
    'subtitle': subtitle,
    'description': description,
    'image_url': imageUrl,
    'deep_link': deepLink,
    'target_url': deepLink,
    'type': type,
    'priority': priority,
    'position': position,
    'cta_label': ctaLabel,
    'is_active': isActive,
    'active': isActive,
    'category_id': categoryId,
    'campaign_id': campaignId,
    'start_at': startAt?.toUtc().toIso8601String(),
    'end_at': endAt?.toUtc().toIso8601String(),
    'order_index': orderIndex,
    'alt_text': altText,
    'background_color': backgroundColor,
    'metadata': metadata,
    'isFeatured': isFeatured,
  };
}

class BannerResponseModel {
  BannerResponseModel({
    Iterable<BannerItemModel> banners = const <BannerItemModel>[],
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
  }) : banners = List<BannerItemModel>.unmodifiable(banners),
       errors = List<String>.unmodifiable(errors),
       metadata = Map<String, dynamic>.unmodifiable(metadata);

  final List<BannerItemModel> banners;
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

  factory BannerResponseModel.fromJson(Map<String, dynamic> json) =>
      BannerResponseModel.fromValue(json);

  factory BannerResponseModel.fromValue(dynamic value) {
    final root = _bannerMap(value);
    final errors = _bannerErrors(root['errors'] ?? root['error']);
    final statusCode = _bannerInt(
      root['status_code'] ?? root['statusCode'] ?? root['code'],
    );
    final success = _bannerBool(
      root['success'] ?? root['ok'],
      fallback: errors.isEmpty && (statusCode == null || statusCode < 400),
    );
    final metadata = _bannerMap(root['metadata'] ?? root['meta']);
    final banners = _extractBannerItems(value)
        .whereType<Map>()
        .map((item) => BannerItemModel.fromJson(_bannerMap(item)))
        .where((banner) => banner.hasContent)
        .toList(growable: false);

    return BannerResponseModel(
      banners: banners,
      success: success,
      message: _bannerOptionalText(root['message'] ?? root['detail']),
      statusCode: statusCode,
      requestId: _bannerOptionalText(
        root['request_id'] ?? root['requestId'] ?? root['trace_id'],
      ),
      timestamp: _bannerDate(
        root['timestamp'] ?? root['generated_at'] ?? root['generatedAt'],
      ),
      page: _bannerInt(root['page'] ?? root['current_page']),
      pageSize: _bannerInt(
        root['page_size'] ?? root['pageSize'] ?? root['limit'],
      ),
      totalItems: _bannerInt(
        root['total_items'] ?? root['totalItems'] ?? root['total'],
      ),
      errors: errors,
      metadata: metadata,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'success': success,
    'data': banners.map((banner) => banner.toJson()).toList(growable: false),
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

  static List<dynamic> _extractBannerItems(dynamic value, [int depth = 0]) {
    if (depth > 5) return const <dynamic>[];
    if (value is List) return value;
    if (value is! Map) return const <dynamic>[];

    final map = _bannerMap(value);
    for (final key in const <String>[
      'banners',
      'items',
      'results',
      'content',
      'data',
    ]) {
      final candidate = map[key];
      if (candidate is List) return candidate;
      if (candidate is Map) {
        final nested = _extractBannerItems(candidate, depth + 1);
        if (nested.isNotEmpty) return nested;
      }
    }

    if (_looksLikeBanner(map)) return <dynamic>[map];
    return const <dynamic>[];
  }

  static bool _looksLikeBanner(Map<String, dynamic> map) =>
      map.containsKey('id') ||
      map.containsKey('banner_id') ||
      map.containsKey('bannerId') ||
      map.containsKey('image_url') ||
      map.containsKey('imageUrl') ||
      map.containsKey('image');
}

Map<String, dynamic> _bannerMap(dynamic value) {
  if (value is! Map) return const <String, dynamic>{};
  return value.map((key, value) => MapEntry(key.toString(), value));
}

String _bannerText(Iterable<dynamic> values, {String fallback = ''}) {
  for (final value in values) {
    if (value == null) continue;
    final text = value.toString().trim();
    if (text.isNotEmpty) return text;
  }
  return fallback;
}

String? _bannerOptionalText(dynamic value) {
  final text = _bannerText(<dynamic>[value]);
  return text.isEmpty ? null : text;
}

bool _bannerBool(dynamic value, {required bool fallback}) {
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

int? _bannerInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

DateTime? _bannerDate(dynamic value) {
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  return null;
}

List<String> _bannerErrors(dynamic value) {
  if (value == null) return const <String>[];
  if (value is String) {
    final message = value.trim();
    return message.isEmpty ? const <String>[] : <String>[message];
  }
  if (value is Iterable) {
    return value.expand(_bannerErrors).toList(growable: false);
  }
  if (value is Map) {
    return value.entries
        .expand((entry) {
          final field = entry.key.toString();
          return _bannerErrors(entry.value)
              .map((message) => '$field: $message');
        })
        .toList(growable: false);
  }
  return const <String>[];
}
