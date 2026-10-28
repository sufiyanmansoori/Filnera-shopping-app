import 'package:filnera/features/home/data/models/home_metadata_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HomeMetadataModel.fromJson', () {
    test('parses flat metadata fields and common API aliases', () {
      final metadata = HomeMetadataModel.fromJson({
        'localeCode': ' en-IN ',
        'country_code': 'IN',
        'currencyCode': 'INR',
        'time_zone': 'Asia/Kolkata',
        'requestId': 'req-123',
        'api_version': 2,
        'personalized_for': 'user-42',
        'generated_at': '2026-10-15T10:00:00Z',
        'expiresAt': '2026-10-16T10:00:00Z',
        'cacheHit': 'true',
        'cacheAgeSeconds': '45',
        'schemaVersion': 3,
      });

      expect(metadata.locale, 'en-IN');
      expect(metadata.country, 'IN');
      expect(metadata.currency, 'INR');
      expect(metadata.timeZone, 'Asia/Kolkata');
      expect(metadata.requestId, 'req-123');
      expect(metadata.apiVersion, '2');
      expect(metadata.personalizedFor, 'user-42');
      expect(metadata.generatedAt, DateTime.utc(2026, 10, 15, 10));
      expect(metadata.expiresAt, DateTime.utc(2026, 10, 16, 10));
      expect(metadata.cacheHit, isTrue);
      expect(metadata.cacheAge, const Duration(seconds: 45));
      expect(metadata.schemaVersion, 3);
      expect(metadata.hasLocalization, isTrue);
      expect(metadata.hasCacheInfo, isTrue);
      expect(metadata.isExpiredAt(DateTime.utc(2026, 10, 17)), isTrue);
    });

    test('reads nested metadata sections and preserves unknown values', () {
      final metadata = HomeMetadataModel.fromJson({
        'data': {
          'metadata': {
            'context': {
              'locale': 'fr-CA',
              'country': 'CA',
              'currency': 'CAD',
              'market_id': 'market-1',
            },
            'cache': {
              'isHit': 1,
              'age': {'seconds': 12},
              'node': 'edge-1',
            },
            'personalization': {
              'customer_id': 'customer-7',
              'segment': 'returning',
            },
            'experiments': {'new_home': 'variant-b'},
            'custom_flag': true,
          },
        },
      });

      expect(metadata.locale, 'fr-CA');
      expect(metadata.country, 'CA');
      expect(metadata.currency, 'CAD');
      expect(metadata.cacheHit, isTrue);
      expect(metadata.cacheAgeSeconds, 12);
      expect(metadata.personalizedFor, 'customer-7');
      expect(metadata.experiments, {'new_home': 'variant-b'});
      expect(metadata.additional, {
        'context.market_id': 'market-1',
        'cache.node': 'edge-1',
        'personalization.segment': 'returning',
        'custom_flag': true,
      });
    });

    test(
      'supports nested metadata envelopes and safely ignores malformed values',
      () {
        final metadata = HomeMetadataModel.fromJson({
          'meta': {
            'metadata': {
              'region': '  ',
              'cache_hit': 'unknown',
              'cache_age_seconds': 'not-a-number',
              'schema_version': 2.8,
              'expires_at': 'not-a-date',
              'source': ['invalid'],
            },
          },
        });

        expect(metadata.region, isNull);
        expect(metadata.cacheHit, isNull);
        expect(metadata.cacheAgeSeconds, isNull);
        expect(metadata.schemaVersion, 2);
        expect(metadata.expiresAt, isNull);
        expect(metadata.source, isNull);
        expect(metadata.hasLocalization, isFalse);
        expect(metadata.hasCacheInfo, isFalse);
        expect(metadata.isExpiredAt(DateTime.utc(2026)), isFalse);
      },
    );

    test('returns empty metadata for an empty payload', () {
      final metadata = HomeMetadataModel.fromJson({});

      expect(metadata.hasLocalization, isFalse);
      expect(metadata.hasCacheInfo, isFalse);
      expect(metadata.experiments, isEmpty);
      expect(metadata.additional, isEmpty);
    });
  });
}
