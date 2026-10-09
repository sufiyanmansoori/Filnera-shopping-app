enum SectionLayout { list, grid, carousel, rail, hero, banner, custom }

class SectionConfigModel {
  SectionConfigModel({
    this.layout = SectionLayout.carousel,
    this.columns = 2,
    this.mobileColumns = 2,
    this.itemLimit = 12,
    this.pageSize = 12,
    this.aspectRatio = 1,
    this.horizontalSpacing = 12,
    this.verticalSpacing = 12,
    this.imageFit = 'cover',
    this.productCardStyle = 'standard',
    this.backgroundColor,
    this.showTitle = true,
    this.showSubtitle = true,
    this.showViewAll = true,
    this.showPrice = true,
    this.showRating = true,
    this.showBadges = true,
    this.autoplay = false,
    this.autoplayIntervalSeconds = 5,
    this.scrollable = true,
    Map<String, Object?> options = const <String, Object?>{},
  }) : options = Map<String, Object?>.unmodifiable(options);

  final SectionLayout layout;
  final int columns;
  final int mobileColumns;
  final int itemLimit;
  final int pageSize;
  final double aspectRatio;
  final double horizontalSpacing;
  final double verticalSpacing;
  final String imageFit;
  final String productCardStyle;
  final String? backgroundColor;
  final bool showTitle;
  final bool showSubtitle;
  final bool showViewAll;
  final bool showPrice;
  final bool showRating;
  final bool showBadges;
  final bool autoplay;
  final int autoplayIntervalSeconds;
  final bool scrollable;
  final Map<String, Object?> options;

  bool get hasCustomOptions => options.isNotEmpty;

  factory SectionConfigModel.fromJson(Map<String, dynamic> json) {
    final source = _unwrapConfig(json);
    final knownKeys = <String>{
      'layout',
      'display_type',
      'displayType',
      'columns',
      'column_count',
      'columnCount',
      'mobile_columns',
      'mobileColumns',
      'item_limit',
      'itemLimit',
      'limit',
      'page_size',
      'pageSize',
      'aspect_ratio',
      'aspectRatio',
      'horizontal_spacing',
      'horizontalSpacing',
      'vertical_spacing',
      'verticalSpacing',
      'image_fit',
      'imageFit',
      'product_card_style',
      'productCardStyle',
      'background_color',
      'backgroundColor',
      'show_title',
      'showTitle',
      'show_subtitle',
      'showSubtitle',
      'show_view_all',
      'showViewAll',
      'show_price',
      'showPrice',
      'show_rating',
      'showRating',
      'show_badges',
      'showBadges',
      'autoplay',
      'auto_play',
      'autoPlay',
      'autoplay_interval_seconds',
      'autoplayIntervalSeconds',
      'scrollable',
      'options',
    };
    final nestedOptions = _configMap(source['options']);
    final extras = Map<String, Object?>.fromEntries(
      source.entries
          .where((entry) => !knownKeys.contains(entry.key))
          .map((entry) => MapEntry(entry.key, entry.value)),
    )..addAll(nestedOptions.cast<String, Object?>());
    final layout = _sectionLayout(
      source['layout'] ?? source['display_type'] ?? source['displayType'],
    );

    return SectionConfigModel(
      layout: layout,
      columns: _configInt(
        source['columns'] ?? source['column_count'] ?? source['columnCount'],
        fallback: layout == SectionLayout.grid ? 2 : 1,
        minimum: 1,
        maximum: 8,
      ),
      mobileColumns: _configInt(
        source['mobile_columns'] ?? source['mobileColumns'],
        fallback: 2,
        minimum: 1,
        maximum: 4,
      ),
      itemLimit: _configInt(
        source['item_limit'] ?? source['itemLimit'] ?? source['limit'],
        fallback: 12,
        minimum: 1,
        maximum: 100,
      ),
      pageSize: _configInt(
        source['page_size'] ?? source['pageSize'],
        fallback: 12,
        minimum: 1,
        maximum: 100,
      ),
      aspectRatio: _configDouble(
        source['aspect_ratio'] ?? source['aspectRatio'],
        fallback: 1,
        minimum: 0.4,
        maximum: 3,
      ),
      horizontalSpacing: _configDouble(
        source['horizontal_spacing'] ?? source['horizontalSpacing'],
        fallback: 12,
        minimum: 0,
        maximum: 64,
      ),
      verticalSpacing: _configDouble(
        source['vertical_spacing'] ?? source['verticalSpacing'],
        fallback: 12,
        minimum: 0,
        maximum: 64,
      ),
      imageFit: _imageFit(source['image_fit'] ?? source['imageFit']),
      productCardStyle: _safeString(
        source['product_card_style'] ?? source['productCardStyle'],
        fallback: 'standard',
        allowed: const <String>{'standard', 'compact', 'editorial', 'minimal'},
      ),
      backgroundColor: _optionalColor(
        source['background_color'] ?? source['backgroundColor'],
      ),
      showTitle: _configBool(
        source['show_title'] ?? source['showTitle'],
        fallback: true,
      ),
      showSubtitle: _configBool(
        source['show_subtitle'] ?? source['showSubtitle'],
        fallback: true,
      ),
      showViewAll: _configBool(
        source['show_view_all'] ?? source['showViewAll'],
        fallback: true,
      ),
      showPrice: _configBool(
        source['show_price'] ?? source['showPrice'],
        fallback: true,
      ),
      showRating: _configBool(
        source['show_rating'] ?? source['showRating'],
        fallback: true,
      ),
      showBadges: _configBool(
        source['show_badges'] ?? source['showBadges'],
        fallback: true,
      ),
      autoplay: _configBool(
        source['autoplay'] ?? source['auto_play'] ?? source['autoPlay'],
        fallback: false,
      ),
      autoplayIntervalSeconds: _configInt(
        source['autoplay_interval_seconds'] ??
            source['autoplayIntervalSeconds'],
        fallback: 5,
        minimum: 1,
        maximum: 120,
      ),
      scrollable: _configBool(source['scrollable'], fallback: true),
      options: extras,
    );
  }

  SectionConfigModel copyWith({
    SectionLayout? layout,
    int? columns,
    int? mobileColumns,
    int? itemLimit,
    int? pageSize,
    double? aspectRatio,
    double? horizontalSpacing,
    double? verticalSpacing,
    String? imageFit,
    String? productCardStyle,
    String? backgroundColor,
    bool? showTitle,
    bool? showSubtitle,
    bool? showViewAll,
    bool? showPrice,
    bool? showRating,
    bool? showBadges,
    bool? autoplay,
    int? autoplayIntervalSeconds,
    bool? scrollable,
    Map<String, Object?>? options,
  }) => SectionConfigModel(
    layout: layout ?? this.layout,
    columns: columns ?? this.columns,
    mobileColumns: mobileColumns ?? this.mobileColumns,
    itemLimit: itemLimit ?? this.itemLimit,
    pageSize: pageSize ?? this.pageSize,
    aspectRatio: aspectRatio ?? this.aspectRatio,
    horizontalSpacing: horizontalSpacing ?? this.horizontalSpacing,
    verticalSpacing: verticalSpacing ?? this.verticalSpacing,
    imageFit: imageFit ?? this.imageFit,
    productCardStyle: productCardStyle ?? this.productCardStyle,
    backgroundColor: backgroundColor ?? this.backgroundColor,
    showTitle: showTitle ?? this.showTitle,
    showSubtitle: showSubtitle ?? this.showSubtitle,
    showViewAll: showViewAll ?? this.showViewAll,
    showPrice: showPrice ?? this.showPrice,
    showRating: showRating ?? this.showRating,
    showBadges: showBadges ?? this.showBadges,
    autoplay: autoplay ?? this.autoplay,
    autoplayIntervalSeconds:
        autoplayIntervalSeconds ?? this.autoplayIntervalSeconds,
    scrollable: scrollable ?? this.scrollable,
    options: options ?? this.options,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'layout': layout.name,
    'columns': columns,
    'mobile_columns': mobileColumns,
    'item_limit': itemLimit,
    'page_size': pageSize,
    'aspect_ratio': aspectRatio,
    'horizontal_spacing': horizontalSpacing,
    'vertical_spacing': verticalSpacing,
    'image_fit': imageFit,
    'product_card_style': productCardStyle,
    'background_color': backgroundColor,
    'show_title': showTitle,
    'show_subtitle': showSubtitle,
    'show_view_all': showViewAll,
    'show_price': showPrice,
    'show_rating': showRating,
    'show_badges': showBadges,
    'autoplay': autoplay,
    'autoplay_interval_seconds': autoplayIntervalSeconds,
    'scrollable': scrollable,
    'options': options,
  };
}

Map<String, dynamic> _unwrapConfig(Map<String, dynamic> source) {
  var config = source;
  for (var depth = 0; depth < 4; depth++) {
    final nested = config['config'] ?? config['settings'];
    if (nested is Map) {
      config = _configMap(nested);
      continue;
    }
    final data = config['data'];
    if (data is Map && !_looksLikeConfig(config)) {
      config = _configMap(data);
      continue;
    }
    break;
  }
  return config;
}

bool _looksLikeConfig(Map<String, dynamic> value) =>
    value.containsKey('layout') ||
    value.containsKey('display_type') ||
    value.containsKey('columns') ||
    value.containsKey('item_limit');

Map<String, dynamic> _configMap(dynamic value) {
  if (value is! Map) return const <String, dynamic>{};
  return value.map((key, value) => MapEntry(key.toString(), value));
}

SectionLayout _sectionLayout(dynamic value) {
  switch (value?.toString().trim().toLowerCase().replaceAll(
    RegExp(r'[_\-\s]'),
    '',
  )) {
    case 'grid':
    case 'productgrid':
      return SectionLayout.grid;
    case 'list':
    case 'vertical':
      return SectionLayout.list;
    case 'rail':
    case 'horizontal':
      return SectionLayout.rail;
    case 'hero':
      return SectionLayout.hero;
    case 'banner':
      return SectionLayout.banner;
    case 'custom':
      return SectionLayout.custom;
    case 'carousel':
    case 'slider':
    default:
      return SectionLayout.carousel;
  }
}

int _configInt(
  dynamic value, {
  required int fallback,
  required int minimum,
  required int maximum,
}) {
  final parsed = value is num
      ? value.toInt()
      : int.tryParse(value?.toString() ?? '') ?? fallback;
  return parsed.clamp(minimum, maximum);
}

double _configDouble(
  dynamic value, {
  required double fallback,
  required double minimum,
  required double maximum,
}) {
  final parsed = value is num
      ? value.toDouble()
      : double.tryParse(value?.toString() ?? '') ?? fallback;
  return parsed.clamp(minimum, maximum).toDouble();
}

bool _configBool(dynamic value, {required bool fallback}) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    switch (value.trim().toLowerCase()) {
      case 'true':
      case '1':
      case 'yes':
      case 'enabled':
        return true;
      case 'false':
      case '0':
      case 'no':
      case 'disabled':
        return false;
    }
  }
  return fallback;
}

String _imageFit(dynamic value) => _safeString(
  value,
  fallback: 'cover',
  allowed: const <String>{'cover', 'contain', 'fill', 'fitwidth', 'fitheight'},
);

String _safeString(
  dynamic value, {
  required String fallback,
  required Set<String> allowed,
}) {
  final normalized = value?.toString().trim().toLowerCase() ?? '';
  return allowed.contains(normalized) ? normalized : fallback;
}

String? _optionalColor(dynamic value) {
  if (value == null) return null;
  final color = value.toString().trim();
  if (RegExp(r'^#(?:[0-9a-fA-F]{3}|[0-9a-fA-F]{6}|[0-9a-fA-F]{8})$')
      .hasMatch(color)) {
    return color.toUpperCase();
  }
  return null;
}
