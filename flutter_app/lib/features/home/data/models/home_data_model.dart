import '../../domain/entities/banner_entity.dart';
import '../../domain/entities/deal_entity.dart';
import '../../domain/entities/featured_product_entity.dart';
import '../../domain/entities/flash_sale_entity.dart';
import '../../domain/entities/home_data_entity.dart';
import '../../domain/entities/recommendation_entity.dart';
import '../../domain/entities/section_entity.dart';
import 'home_category_model.dart';
import 'home_deal_model.dart';
import 'banner_response_model.dart';
import 'deal_response_model.dart';
import 'featured_product_model.dart';
import 'featured_section_model.dart';
import 'recommendation_model.dart';
import 'flash_sale_model.dart';
import 'trending_section_model.dart';
import 'sponsored_product_model.dart';
import 'brand_model.dart';
import 'section_config_model.dart';

/// Data-layer adapter for the complete home API/cache payload.
class HomeDataModel {
  const HomeDataModel({
    required this.banners,
    required this.categories,
    required this.deals,
    required this.featuredProducts,
    required this.flashSales,
    required this.recommendations,
    required this.trendingProducts,
    required this.sections,
    this.personalizedSummary,
    this.lastUpdated,
  });

  final List<BannerEntity> banners;
  final List<HomeCategoryEntity> categories;
  final List<DealEntity> deals;
  final List<FeaturedProductEntity> featuredProducts;
  final List<FlashSaleEntity> flashSales;
  final List<RecommendationEntity> recommendations;
  final List<FeaturedProductEntity> trendingProducts;
  final List<SectionEntity> sections;
  final String? personalizedSummary;
  final DateTime? lastUpdated;

  factory HomeDataModel.fromJson(Map<String, dynamic> json) {
    final payload = _unwrapPayload(json);
    final trendingSectionConfig = _asMap(
      payload['trending_section'] ?? payload['trendingSection'],
    );
    final trendingSection = TrendingSectionModel.fromJson(<String, dynamic>{
      'section': trendingSectionConfig.isNotEmpty
          ? trendingSectionConfig
          : <String, dynamic>{
              'id': 'trending-products',
              'key': 'trending-products',
              'title': _firstText(<dynamic>[
                payload['trending_title'],
                payload['trendingTitle'],
              ], fallback: 'Trending products'),
              'type': 'trending',
            },
      'products': payload['trending_products'] ?? payload['trendingProducts'],
    });
    return HomeDataModel(
      banners: _list(payload['banners'])
          .map(_bannerFromJson)
          .whereType<BannerEntity>()
          .toList(),
      categories: _list(payload['categories'] ?? payload['top_categories'])
          .map(_categoryFromJson)
          .whereType<HomeCategoryEntity>()
          .toList(),
      deals: _list(payload['deals'] ?? payload['offers'])
          .map(_dealFromJson)
          .whereType<DealEntity>()
          .toList(),
      featuredProducts:
          _list(payload['featured_products'] ?? payload['featuredProducts'])
              .map(_featuredProductFromJson)
              .whereType<FeaturedProductEntity>()
              .toList(),
      flashSales: _list(payload['flash_sales'] ?? payload['flashSales'])
          .map(_flashSaleFromJson)
          .whereType<FlashSaleEntity>()
          .toList(),
      recommendations: _list(payload['recommendations'])
          .map(_recommendationFromJson)
          .whereType<RecommendationEntity>()
          .toList(),
      trendingProducts: trendingSection.products,
      sections: _list(payload['sections'])
          .map(_sectionFromJson)
          .whereType<SectionEntity>()
          .toList(),
      personalizedSummary: _textOrNull(
        payload['personalized_summary'] ?? payload['personalizedSummary'],
      ),
      lastUpdated:
          _dateTime(
            payload['last_updated'] ??
                payload['lastUpdated'] ??
                payload['updated_at'] ??
                payload['updatedAt'],
          ) ??
          DateTime.now(),
    );
  }

  factory HomeDataModel.fromEntity(HomeDataEntity entity) {
    return HomeDataModel(
      banners: entity.banners,
      categories: entity.categories,
      deals: entity.deals,
      featuredProducts: entity.featuredProducts,
      flashSales: entity.flashSales,
      recommendations: entity.recommendations,
      trendingProducts: entity.trendingProducts,
      sections: entity.sections,
      personalizedSummary: entity.personalizedSummary,
      lastUpdated: entity.lastUpdated,
    );
  }

  HomeDataEntity toEntity() => HomeDataEntity(
    banners: banners,
    categories: categories,
    deals: deals,
    featuredProducts: featuredProducts,
    flashSales: flashSales,
    recommendations: recommendations,
    trendingProducts: trendingProducts,
    sections: sections,
    personalizedSummary: personalizedSummary,
    lastUpdated: lastUpdated,
  );

  Map<String, dynamic> toJson() => {
    'banners': banners.map(_bannerToJson).toList(),
    'categories': categories
        .map((category) => HomeCategoryModel.fromEntity(category).toJson())
        .toList(),
    'deals': deals
        .map((deal) => HomeDealModel.fromEntity(deal).toJson())
        .toList(),
    'featured_products': featuredProducts.map(_featuredProductToJson).toList(),
    'flash_sales': flashSales.map(_flashSaleToJson).toList(),
    'recommendations': recommendations.map(_recommendationToJson).toList(),
    'trending_products': trendingProducts.map(_featuredProductToJson).toList(),
    'sections': sections.map(_sectionToJson).toList(),
    'personalized_summary': personalizedSummary,
    'last_updated': lastUpdated?.toUtc().toIso8601String(),
  };

  static Map<String, dynamic> _unwrapPayload(Map<String, dynamic> json) {
    dynamic value = json;
    for (var depth = 0; depth < 4; depth++) {
      if (value is! Map) return const <String, dynamic>{};
      final map = _asMap(value);
      final nested = map['data'];
      if (nested is Map) {
        value = nested;
        continue;
      }
      return map;
    }
    return value is Map ? _asMap(value) : const <String, dynamic>{};
  }

  static List<dynamic> _list(dynamic value) {
    if (value is List) return value;
    if (value is Map) {
      final map = _asMap(value);
      final nested = map['items'] ?? map['results'] ?? map['data'];
      if (nested is List) return nested;
    }
    return const <dynamic>[];
  }

  static BannerEntity? _bannerFromJson(dynamic value) {
    if (value is! Map) return null;
    final model = BannerItemModel.fromJson(_asMap(value));
    if (!model.hasContent) return null;
    return model
        .copyWith(id: model.id.isEmpty ? _slugify(model.title) : model.id)
        .toEntity();
  }

  static Map<String, dynamic> _bannerToJson(BannerEntity banner) =>
      BannerItemModel.fromEntity(banner).toJson();

  static HomeCategoryEntity? _categoryFromJson(dynamic value) {
    if (value is String) {
      final name = value.trim();
      if (name.isEmpty) return null;
      final slug = _slugify(name);
      return HomeCategoryEntity(id: slug, name: name, slug: slug, imageUrl: '');
    }
    if (value is! Map) return null;
    final map = _asMap(value);
    final name = _firstText(<dynamic>[map['name'], map['title'], map['label']]);
    final id = _firstText(<dynamic>[
      map['id'],
      map['category_id'],
      map['categoryId'],
    ]);
    final slug = _firstText(<dynamic>[
      map['slug'],
      map['url_slug'],
      map['urlSlug'],
    ], fallback: _slugify(name.isEmpty ? id : name));
    if (name.isEmpty && id.isEmpty) return null;
    return HomeCategoryModel.fromJson(<String, dynamic>{
      ...map,
      'id': id.isEmpty ? slug : id,
      'name': name.isEmpty ? _titleFromSlug(slug) : name,
      'slug': slug,
      'is_active': _asBool(
        map['is_active'] ?? map['isActive'] ?? map['active'],
        fallback: true,
      ),
    }).toEntity();
  }

  static DealEntity? _dealFromJson(dynamic value) {
    if (value is! Map) return null;
    final model = DealItemModel.fromJson(_asMap(value));
    return model.hasContent ? model.deal.toEntity() : null;
  }

  static FeaturedProductEntity? _featuredProductFromJson(dynamic value) {
    if (value is! Map) return null;
    final map = _asMap(value);
    final sponsoredProduct = SponsoredProductModel.fromJson(map);
    if (sponsoredProduct.hasSponsorship) {
      return sponsoredProduct.hasIdentity ? sponsoredProduct.toEntity() : null;
    }
    final product = FeaturedProductModel.fromJson(map);
    return product.hasIdentity ? product.toEntity() : null;
  }

  static Map<String, dynamic> _featuredProductToJson(
    FeaturedProductEntity product,
  ) => FeaturedProductModel.fromEntity(product).toJson();

  static FlashSaleEntity? _flashSaleFromJson(dynamic value) {
    if (value is! Map) return null;
    final sale = FlashSaleModel.fromJson(_asMap(value));
    return sale.hasIdentity ? sale.toEntity() : null;
  }

  static Map<String, dynamic> _flashSaleToJson(FlashSaleEntity sale) =>
      FlashSaleModel.fromEntity(sale).toJson();

  static RecommendationEntity? _recommendationFromJson(dynamic value) {
    if (value is! Map) return null;
    final recommendation = RecommendationModel.fromJson(_asMap(value));
    return recommendation.hasIdentity ? recommendation.toEntity() : null;
  }

  static Map<String, dynamic> _recommendationToJson(
    RecommendationEntity item,
  ) => RecommendationModel.fromEntity(item).toJson();

  static SectionEntity? _sectionFromJson(dynamic value) {
    if (value is! Map) return null;
    final map = _asMap(value);
    final type = _firstText(<dynamic>[
      map['type'],
      map['section_type'],
      map['sectionType'],
    ]).toLowerCase().replaceAll(RegExp(r'[_\-\s]'), '');
    if (type == 'trending' || type == 'trendingproducts') {
      final section = TrendingSectionModel.fromJson(map);
      return section.hasSection ? section.toEntity() : null;
    }
    var section = FeaturedSectionModel.fromJson(map);
    final metadata = Map<String, Object?>.from(section.metadata);
    final rawConfig = _asMap(
      map['config'] ?? map['settings'] ?? metadata['config'],
    );
    if (rawConfig.isNotEmpty) {
      metadata['config'] = SectionConfigModel.fromJson(rawConfig).toJson();
      section = section.copyWith(metadata: metadata);
    }
    if (section.type == SectionType.brand) {
      final brands = section.items
          .map((item) {
            if (item is Map) return BrandModel.fromJson(_asMap(item));
            if (item is String) return BrandModel.fromName(item);
            return null;
          })
          .whereType<BrandModel>()
          .where((brand) => brand.hasIdentity)
          .toList(growable: false);
      section = section.copyWith(
        items: brands.map((brand) => brand.toJson()),
        itemsCount: section.itemsCount > 0 ? section.itemsCount : brands.length,
      );
    }
    return section.hasContent ? section.toEntity() : null;
  }

  static Map<String, dynamic> _sectionToJson(SectionEntity section) {
    final model = FeaturedSectionModel.fromEntity(section);
    final metadata = Map<String, Object?>.from(model.metadata);
    final rawConfig = _asMap(metadata.remove('config'));
    var json = model.copyWith(metadata: metadata).toJson();
    if (rawConfig.isNotEmpty) {
      json['config'] = SectionConfigModel.fromJson(rawConfig).toJson();
    }
    if (section.type == SectionType.trending) {
      final trending = TrendingSectionModel.fromEntity(section: section);
      json = <String, dynamic>{...json, ...trending.toJson()};
    }
    if (section.type == SectionType.brand) {
      var brandSection = FeaturedSectionModel.fromEntity(section);
      final brands = model.items
          .map((item) {
            if (item is Map) return BrandModel.fromJson(_asMap(item));
            if (item is String) return BrandModel.fromName(item);
            return null;
          })
          .whereType<BrandModel>()
          .where((brand) => brand.hasIdentity)
          .toList(growable: false);
      brandSection = brandSection.copyWith(
        items: brands.map((brand) => brand.toJson()),
        itemsCount: section.itemsCount > 0 ? section.itemsCount : brands.length,
      );
      json = <String, dynamic>{...json, ...brandSection.toJson()};
    }
    return json;
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, entry) => MapEntry(key.toString(), entry));
    }
    return <String, dynamic>{};
  }

  static String _firstText(List<dynamic> values, {String fallback = ''}) {
    for (final value in values) {
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isNotEmpty && text != 'null') return text;
    }
    return fallback;
  }

  static String? _textOrNull(dynamic value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty || text == 'null' ? null : text;
  }

  static bool _asBool(dynamic value, {bool fallback = false}) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      switch (value.toLowerCase()) {
        case 'true':
        case '1':
        case 'yes':
          return true;
        case 'false':
        case '0':
        case 'no':
          return false;
      }
    }
    return fallback;
  }

  static DateTime? _dateTime(dynamic value) {
    if (value is DateTime) return value;
    if (value is String && value.trim().isNotEmpty) {
      return DateTime.tryParse(value.trim());
    }
    return null;
  }

  static String _slugify(String value) => value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');

  static String _titleFromSlug(String value) => value
      .split(RegExp(r'[-_]+'))
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}
