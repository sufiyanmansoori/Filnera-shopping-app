import '../../domain/entities/featured_product_entity.dart';
import '../../domain/entities/section_entity.dart';
import 'featured_product_model.dart';
import 'featured_section_model.dart';

class TrendingSectionModel {
  TrendingSectionModel({
    required this.section,
    Iterable<FeaturedProductEntity> products = const <FeaturedProductEntity>[],
  }) : products = List<FeaturedProductEntity>.unmodifiable(products);

  final FeaturedSectionModel section;
  final List<FeaturedProductEntity> products;

  String get id => section.id;
  String get key => section.key;
  String get title => section.title;
  String? get subtitle => section.subtitle;
  bool get enabled => section.enabled;
  int get sortOrder => section.sortOrder;
  String? get viewAllRoute => section.viewAllRoute;
  bool get hasSection => id.isNotEmpty || title != 'Section';
  bool get hasProducts => products.isNotEmpty;

  factory TrendingSectionModel.fromJson(Map<String, dynamic> json) {
    final root = _unwrapTrendingSection(json);
    final rawSection = root['section'];
    final sectionJson = rawSection is Map ? _trendingMap(rawSection) : root;
    final section = FeaturedSectionModel.fromJson(sectionJson);
    final rawProducts = _firstTrendingValue(<dynamic>[
      root['trending_products'],
      root['trendingProducts'],
      root['products'],
      root['items'],
      sectionJson['trending_products'],
      sectionJson['trendingProducts'],
      sectionJson['products'],
      sectionJson['items'],
    ]);
    final products = _extractTrendingProducts(rawProducts)
        .whereType<Map>()
        .map((item) => FeaturedProductModel.fromJson(_trendingMap(item)))
        .where((product) => product.hasIdentity)
        .map((product) => product.toEntity())
        .toList(growable: false);
    final trendingSection = section.copyWith(
      type: SectionType.trending,
      items: products.map(
        (product) => FeaturedProductModel.fromEntity(product).toJson(),
      ),
      itemsCount: section.itemsCount > 0 ? section.itemsCount : products.length,
    );

    return TrendingSectionModel(section: trendingSection, products: products);
  }

  factory TrendingSectionModel.fromEntity({
    required SectionEntity section,
    Iterable<FeaturedProductEntity> products = const <FeaturedProductEntity>[],
  }) {
    final sectionModel = FeaturedSectionModel.fromEntity(section);
    final productList = products.isNotEmpty
        ? List<FeaturedProductEntity>.of(products)
        : sectionModel.items
              .whereType<Map>()
              .map((item) => FeaturedProductModel.fromJson(_trendingMap(item)))
              .where((product) => product.hasIdentity)
              .map((product) => product.toEntity())
              .toList(growable: false);
    return TrendingSectionModel(
      section: sectionModel.copyWith(
        type: SectionType.trending,
        items: productList.map(
          (product) => FeaturedProductModel.fromEntity(product).toJson(),
        ),
        itemsCount: section.itemsCount > 0
            ? section.itemsCount
            : productList.length,
      ),
      products: productList,
    );
  }

  SectionEntity toEntity() => section.toEntity();

  TrendingSectionModel copyWith({
    FeaturedSectionModel? section,
    Iterable<FeaturedProductEntity>? products,
  }) => TrendingSectionModel(
    section: section ?? this.section,
    products: products ?? this.products,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    ...section.toJson(),
    'type': SectionType.trending.name,
    'products': products
        .map((product) => FeaturedProductModel.fromEntity(product).toJson())
        .toList(growable: false),
  };
}

Map<String, dynamic> _unwrapTrendingSection(Map<String, dynamic> source) {
  var value = source;
  for (var depth = 0; depth < 4; depth++) {
    final nested = value['trending_section'] ?? value['trendingSection'];
    if (nested is Map) {
      value = _trendingMap(nested);
      continue;
    }
    final data = value['data'];
    if (data is Map && !_looksLikeTrendingSection(value)) {
      value = _trendingMap(data);
      continue;
    }
    break;
  }
  return value;
}

bool _looksLikeTrendingSection(Map<String, dynamic> value) =>
    value.containsKey('section') ||
    value.containsKey('id') ||
    value.containsKey('section_id') ||
    value.containsKey('title') ||
    value.containsKey('products') ||
    value.containsKey('trending_products');

Map<String, dynamic> _trendingMap(dynamic value) {
  if (value is! Map) return const <String, dynamic>{};
  return value.map((key, value) => MapEntry(key.toString(), value));
}

dynamic _firstTrendingValue(Iterable<dynamic> values) {
  for (final value in values) {
    if (value != null) return value;
  }
  return null;
}

List<dynamic> _extractTrendingProducts(dynamic value, [int depth = 0]) {
  if (depth > 4) return const <dynamic>[];
  if (value is List) return value;
  if (value is! Map) return const <dynamic>[];
  final map = _trendingMap(value);
  for (final key in const <String>['items', 'products', 'results', 'data']) {
    final nested = map[key];
    if (nested is List) return nested;
    if (nested is Map) {
      final values = _extractTrendingProducts(nested, depth + 1);
      if (values.isNotEmpty) return values;
    }
  }
  return const <dynamic>[];
}
