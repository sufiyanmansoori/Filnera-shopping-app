import '../../domain/entities/brand_entity.dart';

class BrandModel {
  BrandModel({
    required this.entity,
    this.coverImageUrl,
    this.discountLabel,
    this.productCount = 0,
    this.rating = 0,
    this.isActive = true,
    Map<String, Object?> metadata = const <String, Object?>{},
  }) : metadata = Map<String, Object?>.unmodifiable(metadata);

  final BrandEntity entity;
  final String? coverImageUrl;
  final String? discountLabel;
  final int productCount;
  final double rating;
  final bool isActive;
  final Map<String, Object?> metadata;

  String get id => entity.id;
  String get name => entity.name;
  String get logoUrl => entity.logoUrl;
  String? get tagline => entity.tagline;
  String? get story => entity.story;
  String? get websiteUrl => entity.websiteUrl;
  bool get isCurated => entity.isCurated;
  int get priority => entity.priority;
  bool get hasIdentity => id.isNotEmpty && name.isNotEmpty;
  bool get hasLogo =>
      logoUrl.isNotEmpty || (coverImageUrl?.isNotEmpty ?? false);
  String? get promotionalText => discountLabel ?? tagline;

  factory BrandModel.fromJson(Map<String, dynamic> json) {
    final source = _unwrapBrand(json);
    final brand = _brandMap(source['brand'] ?? source['seller']);
    final name = _brandText(<dynamic>[
      source['name'],
      source['brand_name'],
      source['brandName'],
      source['title'],
      brand['name'],
      brand['brand_name'],
      brand['brandName'],
      brand['title'],
    ]);
    final id = _brandText(<dynamic>[
      source['id'],
      source['brand_id'],
      source['brandId'],
      brand['id'],
      brand['brand_id'],
      brand['brandId'],
      brand['slug'],
    ], fallback: _brandSlug(name));
    final logo = _brandMap(
      source['logo'] ??
          source['brand_logo'] ??
          source['brandLogo'] ??
          brand['logo'] ??
          brand['brand_logo'],
    );
    final metadata = _brandMap(source['metadata'] ?? source['meta']);
    final brandMetadata = _brandMap(brand['metadata']);

    return BrandModel(
      entity: BrandEntity(
        id: id,
        name: name.isEmpty ? 'Brand' : name,
        logoUrl: _brandText(<dynamic>[
          source['logo_url'],
          source['logoUrl'],
          source['logo_image'],
          source['logoImage'],
          if (source['logo'] is String) source['logo'],
          logo['url'],
          logo['src'],
          logo['image_url'],
          brand['logo_url'],
          brand['logoUrl'],
          if (brand['logo'] is String) brand['logo'],
          brand['image'],
        ]),
        tagline: _brandOptionalText(<dynamic>[
          source['tagline'],
          source['slogan'],
          brand['tagline'],
          brand['slogan'],
        ]),
        story: _brandOptionalText(<dynamic>[
          source['story'],
          source['description'],
          brand['story'],
          brand['description'],
        ]),
        websiteUrl: _brandOptionalText(<dynamic>[
          source['website_url'],
          source['websiteUrl'],
          source['url'],
          brand['website_url'],
          brand['websiteUrl'],
          brand['url'],
        ]),
        isCurated: _brandBool(
          source['is_curated'] ??
              source['isCurated'] ??
              source['is_featured'] ??
              source['isFeatured'] ??
              source['featured'] ??
              brand['is_curated'] ??
              brand['isFeatured'],
        ),
        priority: _brandInt(
          source['priority'] ??
              source['sort_order'] ??
              source['sortOrder'] ??
              source['rank'] ??
              brand['priority'],
        ),
      ),
      coverImageUrl: _brandOptionalText(<dynamic>[
        source['cover_image_url'],
        source['coverImageUrl'],
        source['banner_url'],
        source['bannerUrl'],
        brand['cover_image_url'],
        brand['coverImageUrl'],
      ]),
      discountLabel: _brandOptionalText(<dynamic>[
        source['discount_label'],
        source['discountLabel'],
        source['offer_text'],
        source['offerText'],
        brand['discount_label'],
        brand['offer_text'],
      ]),
      productCount: _brandInt(
        source['product_count'] ??
            source['productCount'] ??
            source['products_count'] ??
            brand['product_count'],
      ),
      rating: _brandNumber(source['rating'] ?? brand['rating']),
      isActive: _brandBool(
        source['is_active'] ??
            source['isActive'] ??
            source['active'] ??
            brand['is_active'],
        fallback: true,
      ),
      metadata: <String, Object?>{
        ...brandMetadata.cast<String, Object?>(),
        ...metadata.cast<String, Object?>(),
      },
    );
  }

  factory BrandModel.fromEntity(BrandEntity entity) =>
      BrandModel(entity: entity);

  factory BrandModel.fromName(String name) {
    final normalizedName = name.trim();
    final id = _brandSlug(normalizedName);
    return BrandModel(
      entity: BrandEntity(id: id, name: normalizedName, logoUrl: ''),
    );
  }

  BrandEntity toEntity() => entity;

  BrandModel copyWith({
    BrandEntity? entity,
    String? coverImageUrl,
    String? discountLabel,
    int? productCount,
    double? rating,
    bool? isActive,
    Map<String, Object?>? metadata,
  }) => BrandModel(
    entity: entity ?? this.entity,
    coverImageUrl: coverImageUrl ?? this.coverImageUrl,
    discountLabel: discountLabel ?? this.discountLabel,
    productCount: productCount ?? this.productCount,
    rating: rating ?? this.rating,
    isActive: isActive ?? this.isActive,
    metadata: metadata ?? this.metadata,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'logo_url': logoUrl,
    'tagline': tagline,
    'story': story,
    'website_url': websiteUrl,
    'is_curated': isCurated,
    'priority': priority,
    'cover_image_url': coverImageUrl,
    'discount_label': discountLabel,
    'product_count': productCount,
    'rating': rating,
    'is_active': isActive,
    'metadata': metadata,
  };
}

Map<String, dynamic> _unwrapBrand(Map<String, dynamic> source) {
  var brand = source;
  for (var depth = 0; depth < 4; depth++) {
    final nested = brand['brand'] ?? brand['seller'];
    if (nested is Map) {
      brand = _brandMap(nested);
      continue;
    }
    final data = brand['data'];
    if (data is Map && !_looksLikeBrand(brand)) {
      brand = _brandMap(data);
      continue;
    }
    break;
  }
  return brand;
}

bool _looksLikeBrand(Map<String, dynamic> value) =>
    value.containsKey('id') ||
    value.containsKey('brand_id') ||
    value.containsKey('brandId') ||
    value.containsKey('name') ||
    value.containsKey('brand_name');

Map<String, dynamic> _brandMap(dynamic value) {
  if (value is! Map) return const <String, dynamic>{};
  return value.map((key, value) => MapEntry(key.toString(), value));
}

String _brandText(Iterable<dynamic> values, {String fallback = ''}) {
  for (final value in values) {
    if (value == null) continue;
    final text = value.toString().trim();
    if (text.isNotEmpty && text != 'null') return text;
  }
  return fallback;
}

String? _brandOptionalText(Iterable<dynamic> values) {
  final text = _brandText(values);
  return text.isEmpty ? null : text;
}

int _brandInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is Map) {
    return _brandInt(value['count'] ?? value['value'] ?? value['total']);
  }
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _brandNumber(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is Map) {
    return _brandNumber(value['value'] ?? value['rating'] ?? value['amount']);
  }
  final normalized = value?.toString().replaceAll(',', '').trim() ?? '';
  final match = RegExp(r'-?\d+(?:\.\d+)?').firstMatch(normalized);
  return match == null ? 0 : double.tryParse(match.group(0)!) ?? 0;
}

bool _brandBool(dynamic value, {bool fallback = false}) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    switch (value.trim().toLowerCase()) {
      case 'true':
      case '1':
      case 'yes':
      case 'curated':
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

String _brandSlug(String value) => value
    .trim()
    .toLowerCase()
    .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
    .replaceAll(RegExp(r'^-+|-+$'), '');
