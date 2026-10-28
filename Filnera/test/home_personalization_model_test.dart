import 'package:flutter_test/flutter_test.dart';
import 'package:filnera/features/home/data/models/home_personalization_model.dart';

void main() {
  group('HomePersonalizationModel', () {
    test('parses wrapped payloads and common API field aliases', () {
      final model = HomePersonalizationModel.fromJson({
        'data': {
          'personalization': {
            'customerId': ' customer-7 ',
            'localeCode': 'hi_IN',
            'currencyCode': 'inr',
            'country': 'in',
            'deviceType': 'ANDROID',
            'pincode': 110001,
            'recently_viewed': ['sku-1', 'sku-1', ' ', 'sku-2'],
            'favoriteCategories': 'fashion, home',
            'isGuest': false,
          },
        },
      });

      expect(model.userId, 'customer-7');
      expect(model.locale, 'hi_IN');
      expect(model.currency, 'INR');
      expect(model.countryCode, 'IN');
      expect(model.deviceType, 'android');
      expect(model.deliveryPin, '110001');
      expect(model.recentlyViewedProductIds, ['sku-1', 'sku-2']);
      expect(model.favoriteCategoryIds, ['fashion', 'home']);
      expect(model.isGuest, isFalse);
    });

    test(
      'applies safe defaults and omits guest identity in API parameters',
      () {
        final model = HomePersonalizationModel.fromJson(const {});

        expect(model.locale, 'en');
        expect(model.currency, 'INR');
        expect(model.countryCode, 'IN');
        expect(model.deviceType, 'mobile');
        expect(model.isGuest, isTrue);
        expect(model.toQueryParameters(), {
          'locale': 'en',
          'currency': 'INR',
          'country': 'IN',
          'device_type': 'mobile',
        });
      },
    );

    test(
      'round trips JSON, bounds signals, and allows nullable values to clear',
      () {
        final products = List<String>.generate(105, (index) => 'p$index');
        final model = HomePersonalizationModel.fromJson({
          'user_id': 'u-1',
          'app_version': '1.2.3',
          'location_name': 'Delhi',
          'delivery_pin': '110001',
          'recently_viewed_product_ids': products,
          'favorite_category_ids': ['books'],
          'is_guest': false,
        });
        final roundTrip = HomePersonalizationModel.fromJson(model.toJson());
        final cleared = model.copyWith(
          appVersion: null,
          locationName: null,
          deliveryPin: null,
          userId: null,
        );

        expect(model.recentlyViewedProductIds, hasLength(100));
        expect(roundTrip, model);
        expect(roundTrip.toQueryParameters()['user_id'], 'u-1');
        expect(cleared.userId, isNull);
        expect(cleared.appVersion, isNull);
        expect(cleared.locationName, isNull);
        expect(cleared.deliveryPin, isNull);
      },
    );
  });
}
