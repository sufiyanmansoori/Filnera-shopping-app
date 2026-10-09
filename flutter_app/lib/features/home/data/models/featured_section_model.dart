import '../../domain/entities/section_entity.dart';

class FeaturedSectionModel {
  FeaturedSectionModel({
    required this.id,
    required this.key,
    required this.title,
    required this.type,
    this.subtitle,
    this.description,
    this.itemsCount = 0,
    this.enabled = true,
    this.sortOrder = 0,
    this.viewAllRoute,
    Iterable<Object?> items = const <Object?>[],
    Map<String, Object?> metadata = const <String, Object?>{},
  }) : items = List<Object?>.unmodifiable(items.map(_normalizeSectionItem)),
       metadata = Map<String, Object?>.unmodifiable(metadata);

  final String id;
  final String key;
  final String title;
  final SectionType type;
  final String? subtitle;
  final String? description;
  final int itemsCount;
  final bool enabled;
  final int sortOrder;
  final String? viewAllRoute;
  final List<Object?> items;
  final Map<String, Object?> metadata;

  bool get hasContent => id.isNotEmpty || title.isNotEmpty;
  bool get hasItems => items.isNotEmpty;
  int get effectiveItemsCount => itemsCount > 0 ? itemsCount : items.length;

  factory FeaturedSectionModel.fromJson(Map<String, dynamic> json) {
    final source = _unwrapSection(json);
    final title = _sectionText(<dynamic>[
      source['title'],
      source['name'],
      source['label'],
    ]);
    final id = _sectionText(<dynamic>[
      source['id'],
      source['section_id'],
      source['sectionId'],
    ], fallback: _slugify(title));
    final sectionKey = _sectionText(<dynamic>[
      source['key'],
      source['section_key'],
      source['sectionKey'],
      source['slug'],
    ], fallback: _slugify(title.isEmpty ? id : title));
    final items = _sectionItems(
      source['items'] ??
          source['products'] ??
          source['categories'] ??
          source['deals'],
    );
    final metadata = _sectionMap(
      source['metadata'] ?? source['config'] ?? source['settings'],
    ).cast<String, Object?>();

    return FeaturedSectionModel(
      id: id,
      key: sectionKey,
      title: title.isEmpty ? 'Section' : title,
      type: _sectionType(
        source['type'] ?? source['section_type'] ?? source['sectionType'],
      ),
      subtitle: _sectionOptionalText(source['subtitle']),
      description: _sectionOptionalText(source['description']),
      itemsCount: _sectionInt(
        source['items_count'] ??
            source['itemsCount'] ??
            source['item_count'] ??
            source['itemCount'] ??
            source['total_items'],
      ),
      enabled: _sectionBool(
        source['enabled'] ??
            source['is_enabled'] ??
            source['isEnabled'] ??
            source['active'],
        fallback: true,
      ),
      sortOrder: _sectionInt(
        source['sort_order'] ??
            source['sortOrder'] ??
            source['position'] ??
            source['order'],
      ),
      viewAllRoute: _sectionOptionalText(
        source['view_all_route'] ??
            source['viewAllRoute'] ??
            source['view_all_url'] ??
            source['viewAllUrl'],
      ),
      items: items,
      metadata: metadata,
    );
  }

  factory FeaturedSectionModel.fromEntity(SectionEntity entity) {
    final metadata = Map<String, Object?>.from(entity.metadata);
    final items = _sectionItems(metadata.remove('items'));
    return FeaturedSectionModel(
      id: entity.id,
      key: entity.key,
      title: entity.title,
      type: entity.type,
      subtitle: entity.subtitle,
      description: entity.description,
      itemsCount: entity.itemsCount,
      enabled: entity.enabled,
      sortOrder: entity.sortOrder,
      viewAllRoute: entity.viewAllRoute,
      items: items,
      metadata: metadata,
    );
  }

  FeaturedSectionModel copyWith({
    String? id,
    String? key,
    String? title,
    SectionType? type,
    String? subtitle,
    String? description,
    int? itemsCount,
    bool? enabled,
    int? sortOrder,
    String? viewAllRoute,
    Iterable<Object?>? items,
    Map<String, Object?>? metadata,
  }) => FeaturedSectionModel(
    id: id ?? this.id,
    key: key ?? this.key,
    title: title ?? this.title,
    type: type ?? this.type,
    subtitle: subtitle ?? this.subtitle,
    description: description ?? this.description,
    itemsCount: itemsCount ?? this.itemsCount,
    enabled: enabled ?? this.enabled,
    sortOrder: sortOrder ?? this.sortOrder,
    viewAllRoute: viewAllRoute ?? this.viewAllRoute,
    items: items ?? this.items,
    metadata: metadata ?? this.metadata,
  );

  SectionEntity toEntity() => SectionEntity(
    id: id,
    key: key,
    title: title,
    type: type,
    subtitle: subtitle,
    description: description,
    itemsCount: effectiveItemsCount,
    enabled: enabled,
    sortOrder: sortOrder,
    viewAllRoute: viewAllRoute,
    metadata: <String, Object?>{
      ...metadata,
      if (items.isNotEmpty) 'items': items,
    },
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'key': key,
    'title': title,
    'type': type.name,
    'subtitle': subtitle,
    'description': description,
    'items_count': effectiveItemsCount,
    'enabled': enabled,
    'sort_order': sortOrder,
    'view_all_route': viewAllRoute,
    'items': items,
    'metadata': metadata,
  };
}

Map<String, dynamic> _unwrapSection(Map<String, dynamic> source) {
  var section = source;
  for (var depth = 0; depth < 4; depth++) {
    final nested = section['section'];
    if (nested is Map) {
      section = _sectionMap(nested);
      continue;
    }
    final data = section['data'];
    if (data is Map && !_looksLikeSection(section)) {
      section = _sectionMap(data);
      continue;
    }
    break;
  }
  return section;
}

bool _looksLikeSection(Map<String, dynamic> map) =>
    map.containsKey('id') ||
    map.containsKey('section_id') ||
    map.containsKey('sectionId') ||
    map.containsKey('title') ||
    map.containsKey('name');

Map<String, dynamic> _sectionMap(dynamic value) {
  if (value is! Map) return const <String, dynamic>{};
  return value.map((key, value) => MapEntry(key.toString(), value));
}

List<Object?> _sectionItems(dynamic value) {
  if (value is List) {
    return value.map<Object?>(_normalizeSectionItem).toList(growable: false);
  }
  if (value is Map) {
    final map = _sectionMap(value);
    final nested = map['items'] ?? map['results'] ?? map['data'];
    if (nested is List) return _sectionItems(nested);
  }
  return const <Object?>[];
}

Object? _normalizeSectionItem(Object? value) {
  if (value is Map) {
    return Map<String, Object?>.unmodifiable(
      value.map((key, entry) => MapEntry(key.toString(), entry)),
    );
  }
  return value;
}

String _sectionText(Iterable<dynamic> values, {String fallback = ''}) {
  for (final value in values) {
    if (value == null) continue;
    final text = value.toString().trim();
    if (text.isNotEmpty && text != 'null') return text;
  }
  return fallback;
}

String? _sectionOptionalText(dynamic value) {
  final text = _sectionText(<dynamic>[value]);
  return text.isEmpty ? null : text;
}

int _sectionInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is Map) {
    return _sectionInt(value['count'] ?? value['value'] ?? value['total']);
  }
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

bool _sectionBool(dynamic value, {required bool fallback}) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    switch (value.trim().toLowerCase()) {
      case 'true':
      case '1':
      case 'yes':
      case 'enabled':
      case 'active':
        return true;
      case 'false':
      case '0':
      case 'no':
      case 'disabled':
      case 'inactive':
        return false;
    }
  }
  return fallback;
}

SectionType _sectionType(dynamic value) {
  final normalized = value?.toString().toLowerCase().replaceAll(
    RegExp(r'[_\-\s]'),
    '',
  );
  switch (normalized) {
    case 'banner':
    case 'hero':
      return SectionType.banner;
    case 'category':
    case 'categories':
      return SectionType.category;
    case 'deal':
    case 'deals':
      return SectionType.deal;
    case 'flashsale':
    case 'flashdeals':
      return SectionType.flashSale;
    case 'featured':
    case 'featuredproducts':
    case 'productrail':
      return SectionType.featured;
    case 'recommendation':
    case 'recommendations':
      return SectionType.recommendation;
    case 'trending':
      return SectionType.trending;
    case 'sponsored':
      return SectionType.sponsored;
    case 'promo':
    case 'promotional':
      return SectionType.promotional;
    case 'brand':
    case 'brands':
      return SectionType.brand;
    default:
      return SectionType.custom;
  }
}

String _slugify(String value) => value
    .trim()
    .toLowerCase()
    .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
    .replaceAll(RegExp(r'^-+|-+$'), '');
