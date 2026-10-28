import '../../domain/entities/personalization_entity.dart';

const Object _unsetPersonalizationValue = Object();
const int _maximumPersonalizationIds = 100;

/// Data-layer adapter for the user's homepage personalization context.
///
/// The model accepts common API naming conventions but writes one canonical
/// snake-case shape. The resulting query parameters are compatible with the
/// home recommendation endpoints.
class HomePersonalizationModel {
  const HomePersonalizationModel({required this.entity});

  final PersonalizationEntity entity;

  String? get userId => entity.userId;
  String get locale => entity.locale;
  String get currency => entity.currency;
  String get countryCode => entity.countryCode;
  String get deviceType => entity.deviceType;
  String? get appVersion => entity.appVersion;
  String? get locationName => entity.locationName;
  String? get deliveryPin => entity.deliveryPin;
  List<String> get recentlyViewedProductIds => entity.recentlyViewedProductIds;
  List<String> get favoriteCategoryIds => entity.favoriteCategoryIds;
  bool get isGuest => entity.isGuest;

  bool get hasUserIdentity => userId != null && userId!.isNotEmpty;
  bool get hasDeliveryLocation => locationName != null || deliveryPin != null;
  bool get hasPersonalizedSignals =>
      recentlyViewedProductIds.isNotEmpty || favoriteCategoryIds.isNotEmpty;

  factory HomePersonalizationModel.fromEntity(PersonalizationEntity entity) =>
      HomePersonalizationModel(entity: entity);

  factory HomePersonalizationModel.fromJson(Map<String, dynamic> json) {
    final root = _unwrapPersonalization(json);
    final preferences = _asMap(
      root['preferences'] ?? root['preference'] ?? root['profile'],
    );
    final location = _asMap(
      root['delivery_location'] ?? root['deliveryLocation'] ?? root['location'],
    );
    final userId = _optionalText(<dynamic>[
      root['user_id'],
      root['userId'],
      root['customer_id'],
      root['customerId'],
      root['profile_id'],
      root['profileId'],
    ]);

    return HomePersonalizationModel(
      entity: PersonalizationEntity(
        userId: userId,
        locale: _firstText(<dynamic>[
          root['locale'],
          root['locale_code'],
          root['localeCode'],
          preferences['locale'],
        ], fallback: 'en'),
        currency: _firstText(<dynamic>[
          root['currency'],
          root['currency_code'],
          root['currencyCode'],
          preferences['currency'],
        ], fallback: 'INR').toUpperCase(),
        countryCode: _firstText(<dynamic>[
          root['country_code'],
          root['countryCode'],
          root['country'],
          preferences['country_code'],
          preferences['countryCode'],
        ], fallback: 'IN').toUpperCase(),
        deviceType: _firstText(<dynamic>[
          root['device_type'],
          root['deviceType'],
          root['platform'],
        ], fallback: 'mobile').toLowerCase(),
        appVersion: _optionalText(<dynamic>[
          root['app_version'],
          root['appVersion'],
          root['version'],
        ]),
        locationName: _optionalText(<dynamic>[
          root['location_name'],
          root['locationName'],
          root['city'],
          location['name'],
          location['city'],
        ]),
        deliveryPin: _optionalText(<dynamic>[
          root['delivery_pin'],
          root['deliveryPin'],
          root['pincode'],
          root['pin_code'],
          root['postal_code'],
          root['postalCode'],
          location['pin'],
          location['pincode'],
          location['postal_code'],
        ]),
        recentlyViewedProductIds: _stringList(
          root['recently_viewed_product_ids'] ??
              root['recentlyViewedProductIds'] ??
              root['recently_viewed'] ??
              root['recentlyViewed'] ??
              preferences['recently_viewed'],
        ),
        favoriteCategoryIds: _stringList(
          root['favorite_category_ids'] ??
              root['favoriteCategoryIds'] ??
              root['favorite_categories'] ??
              root['favoriteCategories'] ??
              preferences['favorite_categories'],
        ),
        isGuest: _boolean(
          root['is_guest'] ?? root['isGuest'] ?? root['guest'],
          fallback: true,
        ),
      ),
    );
  }

  PersonalizationEntity toEntity() => entity;

  /// Builds the supported recommendation request parameters.
  ///
  /// Identity is intentionally omitted for guests and blank IDs to avoid
  /// sending invalid identifiers to the backend.
  Map<String, dynamic> toQueryParameters() => <String, dynamic>{
    'locale': locale,
    'currency': currency,
    'country': countryCode,
    'device_type': deviceType,
    if (!isGuest && hasUserIdentity) 'user_id': userId,
    if (recentlyViewedProductIds.isNotEmpty)
      'recently_viewed': recentlyViewedProductIds.join(','),
    if (favoriteCategoryIds.isNotEmpty)
      'favorite_categories': favoriteCategoryIds.join(','),
  };

  Map<String, dynamic> toJson() => <String, dynamic>{
    'user_id': userId,
    'locale': locale,
    'currency': currency,
    'country_code': countryCode,
    'device_type': deviceType,
    'app_version': appVersion,
    'location_name': locationName,
    'delivery_pin': deliveryPin,
    'recently_viewed_product_ids': recentlyViewedProductIds,
    'favorite_category_ids': favoriteCategoryIds,
    'is_guest': isGuest,
  };

  HomePersonalizationModel copyWith({
    Object? userId = _unsetPersonalizationValue,
    String? locale,
    String? currency,
    String? countryCode,
    String? deviceType,
    Object? appVersion = _unsetPersonalizationValue,
    Object? locationName = _unsetPersonalizationValue,
    Object? deliveryPin = _unsetPersonalizationValue,
    List<String>? recentlyViewedProductIds,
    List<String>? favoriteCategoryIds,
    bool? isGuest,
  }) {
    return HomePersonalizationModel(
      entity: PersonalizationEntity(
        userId: identical(userId, _unsetPersonalizationValue)
            ? this.userId
            : _optionalText(<dynamic>[userId]),
        locale: locale == null ? this.locale : _normalizedText(locale, 'en'),
        currency: currency == null
            ? this.currency
            : _normalizedText(currency, 'INR').toUpperCase(),
        countryCode: countryCode == null
            ? this.countryCode
            : _normalizedText(countryCode, 'IN').toUpperCase(),
        deviceType: deviceType == null
            ? this.deviceType
            : _normalizedText(deviceType, 'mobile').toLowerCase(),
        appVersion: identical(appVersion, _unsetPersonalizationValue)
            ? this.appVersion
            : _optionalText(<dynamic>[appVersion]),
        locationName: identical(locationName, _unsetPersonalizationValue)
            ? this.locationName
            : _optionalText(<dynamic>[locationName]),
        deliveryPin: identical(deliveryPin, _unsetPersonalizationValue)
            ? this.deliveryPin
            : _optionalText(<dynamic>[deliveryPin]),
        recentlyViewedProductIds: recentlyViewedProductIds == null
            ? this.recentlyViewedProductIds
            : _stringList(recentlyViewedProductIds),
        favoriteCategoryIds: favoriteCategoryIds == null
            ? this.favoriteCategoryIds
            : _stringList(favoriteCategoryIds),
        isGuest: isGuest ?? this.isGuest,
      ),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HomePersonalizationModel && entity == other.entity;

  @override
  int get hashCode => entity.hashCode;
}

Map<String, dynamic> _unwrapPersonalization(Map<String, dynamic> source) {
  var current = _asMap(source);
  const wrapperKeys = <String>[
    'data',
    'personalization',
    'personalization_context',
    'personalizationContext',
    'context',
  ];

  for (var depth = 0; depth < 5; depth++) {
    Map<String, dynamic>? nested;
    String? wrapperKey;
    for (final key in wrapperKeys) {
      final candidate = current[key];
      if (candidate is Map) {
        nested = _asMap(candidate);
        wrapperKey = key;
        break;
      }
    }
    if (nested == null || wrapperKey == null) break;
    current = <String, dynamic>{...current, ...nested}..remove(wrapperKey);
  }
  return current;
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is! Map) return <String, dynamic>{};
  return value.map((key, value) => MapEntry(key.toString(), value));
}

String _firstText(Iterable<dynamic> values, {required String fallback}) {
  for (final value in values) {
    final text = _optionalText(<dynamic>[value]);
    if (text != null) return text;
  }
  return fallback;
}

String? _optionalText(Iterable<dynamic> values) {
  for (final value in values) {
    if (value == null || value is Map || value is Iterable) continue;
    final text = value.toString().trim();
    if (text.isNotEmpty) return text;
  }
  return null;
}

String _normalizedText(String value, String fallback) {
  final normalized = value.trim();
  return normalized.isEmpty ? fallback : normalized;
}

List<String> _stringList(dynamic value) {
  final values = switch (value) {
    String text => text.split(','),
    Iterable<dynamic> iterable => iterable,
    _ => const <dynamic>[],
  };
  final normalized = <String>[];
  final seen = <String>{};
  for (final item in values) {
    if (item == null || item is Map || item is Iterable) continue;
    final text = item.toString().trim();
    if (text.isEmpty || !seen.add(text)) continue;
    normalized.add(text);
    if (normalized.length == _maximumPersonalizationIds) break;
  }
  return List<String>.unmodifiable(normalized);
}

bool _boolean(dynamic value, {required bool fallback}) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    switch (value.trim().toLowerCase()) {
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
