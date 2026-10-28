import 'package:flutter_test/flutter_test.dart';
import 'package:filnera/features/products/data/datasources/storefront_product_fallback_data_source.dart';

void main() {
  group('StorefrontProductFallbackDataSource', () {
    final dataSource = StorefrontProductFallbackDataSource();

    test('provides product details for storefront products', () {
      final product = dataSource.findById('p1');

      expect(product, isNotNull);
      expect(product!.name, 'AeroSmart Watch');
      expect(product.description, isNotEmpty);
      expect(product.images, hasLength(3));
      expect(product.price, 4999);
      expect(product.tags, contains('AMOLED display'));
    });

    test('provides details for generated category products', () {
      final product = dataSource.findById('mobiles-01');

      expect(product, isNotNull);
      expect(product!.category, 'Mobiles');
      expect(product.images, isNotEmpty);
    });

    test('returns null for unknown product IDs', () {
      expect(dataSource.findById('missing-product'), isNull);
    });
  });
}
