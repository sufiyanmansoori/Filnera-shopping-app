import 'package:equatable/equatable.dart';

/// User-level personalization metadata used to scope home content correctly.
class PersonalizationEntity extends Equatable {
  const PersonalizationEntity({
    this.userId,
    this.locale = 'en',
    this.currency = 'INR',
    this.countryCode = 'IN',
    this.deviceType = 'mobile',
    this.appVersion,
    this.locationName,
    this.deliveryPin,
    this.recentlyViewedProductIds = const <String>[],
    this.favoriteCategoryIds = const <String>[],
    this.isGuest = true,
  });

  final String? userId;
  final String locale;
  final String currency;
  final String countryCode;
  final String deviceType;
  final String? appVersion;
  final String? locationName;
  final String? deliveryPin;
  final List<String> recentlyViewedProductIds;
  final List<String> favoriteCategoryIds;
  final bool isGuest;

  PersonalizationEntity copyWith({
    String? userId,
    String? locale,
    String? currency,
    String? countryCode,
    String? deviceType,
    String? appVersion,
    String? locationName,
    String? deliveryPin,
    List<String>? recentlyViewedProductIds,
    List<String>? favoriteCategoryIds,
    bool? isGuest,
  }) {
    return PersonalizationEntity(
      userId: userId ?? this.userId,
      locale: locale ?? this.locale,
      currency: currency ?? this.currency,
      countryCode: countryCode ?? this.countryCode,
      deviceType: deviceType ?? this.deviceType,
      appVersion: appVersion ?? this.appVersion,
      locationName: locationName ?? this.locationName,
      deliveryPin: deliveryPin ?? this.deliveryPin,
      recentlyViewedProductIds:
          recentlyViewedProductIds ?? this.recentlyViewedProductIds,
      favoriteCategoryIds: favoriteCategoryIds ?? this.favoriteCategoryIds,
      isGuest: isGuest ?? this.isGuest,
    );
  }

  @override
  List<Object?> get props => [
    userId,
    locale,
    currency,
    countryCode,
    deviceType,
    appVersion,
    locationName,
    deliveryPin,
    recentlyViewedProductIds,
    favoriteCategoryIds,
    isGuest,
  ];
}
