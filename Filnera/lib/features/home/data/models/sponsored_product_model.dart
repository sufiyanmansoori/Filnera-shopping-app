import '../../domain/entities/featured_product_entity.dart';
import 'featured_product_model.dart';

class SponsoredProductModel {
  SponsoredProductModel({
    required this.product,
    this.adId,
    this.campaignId,
    this.advertiserId,
    this.advertiserName,
    this.placement,
    this.sponsorLabel = 'Sponsored',
    this.bidAmount = 0,
    this.startsAt,
    this.endsAt,
    this.isActive = true,
    this.impressions = 0,
    this.clicks = 0,
    Map<String, Object?> metadata = const <String, Object?>{},
    this.isSponsored = true,
  }) : metadata = Map<String, Object?>.unmodifiable(metadata);

  final FeaturedProductModel product;
  final String? adId;
  final String? campaignId;
  final String? advertiserId;
  final String? advertiserName;
  final String? placement;
  final String sponsorLabel;
  final double bidAmount;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final bool isActive;
  final int impressions;
  final int clicks;
  final Map<String, Object?> metadata;
  final bool isSponsored;

  String get productId => product.id;
  String get title => product.title;
  String get campaignLabel => campaignId ?? adId ?? 'sponsored-$productId';
  bool get hasIdentity => product.hasIdentity;
  bool get hasSponsorship =>
      isSponsored ||
      _hasText(adId) ||
      _hasText(campaignId) ||
      _hasText(advertiserId);

  double? get clickThroughRate {
    if (impressions <= 0) return null;
    return clicks / impressions;
  }

  bool isEligibleAt([DateTime? dateTime]) {
    final now = dateTime ?? DateTime.now();
    return hasIdentity &&
        hasSponsorship &&
        isActive &&
        product.stockStatus != StockStatus.outOfStock &&
        (startsAt == null || !now.isBefore(startsAt!)) &&
        (endsAt == null || !now.isAfter(endsAt!));
  }

  factory SponsoredProductModel.fromJson(Map<String, dynamic> json) {
    final source = _unwrapSponsor(json);
    final ad = _sponsorMap(source['ad'] ?? source['sponsorship']);
    final campaign = _sponsorMap(source['campaign']);
    final rawProduct = _sponsorMap(source['product'] ?? source['item']);
    final hasNestedProduct = rawProduct.isNotEmpty;
    final productPayload = hasNestedProduct
        ? <String, dynamic>{
            ...rawProduct,
            'id': _sponsorText(<dynamic>[
              rawProduct['id'],
              rawProduct['product_id'],
              rawProduct['productId'],
              rawProduct['sku'],
              source['product_id'],
              source['productId'],
            ]),
            'is_sponsored': true,
          }
        : source;
    final adId = _sponsorOptionalText(<dynamic>[
      source['ad_id'],
      source['adId'],
      ad['id'],
      ad['ad_id'],
    ]);
    final campaignId = _sponsorOptionalText(<dynamic>[
      source['campaign_id'],
      source['campaignId'],
      campaign['id'],
      campaign['campaign_id'],
      ad['campaign_id'],
    ]);
    final advertiserId = _sponsorOptionalText(<dynamic>[
      source['advertiser_id'],
      source['advertiserId'],
      source['sponsor_id'],
      ad['advertiser_id'],
      campaign['advertiser_id'],
    ]);
    final sponsoredFlag = _sponsorBool(
      source['is_sponsored'] ??
          source['isSponsored'] ??
          source['sponsored'] ??
          ad['is_sponsored'],
      fallback: adId != null || campaignId != null || advertiserId != null,
    );
    final product = FeaturedProductModel.fromJson(productPayload);

    return SponsoredProductModel(
      product: product.copyWith(isSponsored: sponsoredFlag),
      adId: adId,
      campaignId: campaignId,
      advertiserId: advertiserId,
      advertiserName: _sponsorOptionalText(<dynamic>[
        source['advertiser_name'],
        source['advertiserName'],
        source['sponsor_name'],
        ad['advertiser_name'],
        campaign['advertiserName'],
        campaign['advertiser_name'],
      ]),
      placement: _sponsorOptionalText(<dynamic>[
        source['placement'],
        source['ad_placement'],
        source['adPlacement'],
        ad['placement'],
      ]),
      sponsorLabel: _sponsorText(<dynamic>[
        source['sponsor_label'],
        source['sponsorLabel'],
        source['disclosure_label'],
        ad['label'],
      ], fallback: 'Sponsored'),
      bidAmount: _sponsorNumber(
        source['bid_amount'] ??
            source['bidAmount'] ??
            source['cpc'] ??
            ad['bid_amount'],
      ),
      startsAt: _sponsorDate(
        source['starts_at'] ??
            source['startsAt'] ??
            source['start_at'] ??
            source['startAt'] ??
            campaign['startsAt'] ??
            campaign['starts_at'],
      ),
      endsAt: _sponsorDate(
        source['ends_at'] ??
            source['endsAt'] ??
            source['end_at'] ??
            source['endAt'] ??
            campaign['endsAt'] ??
            campaign['ends_at'],
      ),
      isActive: _sponsorBool(
        source['is_active'] ??
            source['isActive'] ??
            source['active'] ??
            ad['is_active'],
        fallback: true,
      ),
      impressions: _sponsorInt(
        source['impressions'] ??
            source['impression_count'] ??
            ad['impressions'],
      ),
      clicks: _sponsorInt(
        source['clicks'] ?? source['click_count'] ?? ad['clicks'],
      ),
      metadata: _sponsorMap(source['metadata'] ?? ad['metadata'])
          .cast<String, Object?>(),
      isSponsored: sponsoredFlag,
    );
  }

  factory SponsoredProductModel.fromEntity(FeaturedProductEntity entity) =>
      SponsoredProductModel(
        product: FeaturedProductModel.fromEntity(entity),
        isSponsored: entity.isSponsored,
      );

  FeaturedProductEntity toEntity() =>
      product.entity.copyWith(isSponsored: isSponsored || product.isSponsored);

  SponsoredProductModel copyWith({
    FeaturedProductModel? product,
    String? adId,
    String? campaignId,
    String? advertiserId,
    String? advertiserName,
    String? placement,
    String? sponsorLabel,
    double? bidAmount,
    DateTime? startsAt,
    DateTime? endsAt,
    bool? isActive,
    int? impressions,
    int? clicks,
    Map<String, Object?>? metadata,
    bool? isSponsored,
  }) => SponsoredProductModel(
    product: product ?? this.product,
    adId: adId ?? this.adId,
    campaignId: campaignId ?? this.campaignId,
    advertiserId: advertiserId ?? this.advertiserId,
    advertiserName: advertiserName ?? this.advertiserName,
    placement: placement ?? this.placement,
    sponsorLabel: sponsorLabel ?? this.sponsorLabel,
    bidAmount: bidAmount ?? this.bidAmount,
    startsAt: startsAt ?? this.startsAt,
    endsAt: endsAt ?? this.endsAt,
    isActive: isActive ?? this.isActive,
    impressions: impressions ?? this.impressions,
    clicks: clicks ?? this.clicks,
    metadata: metadata ?? this.metadata,
    isSponsored: isSponsored ?? this.isSponsored,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    ...product.toJson(),
    'is_sponsored': isSponsored,
    if (adId != null) 'ad_id': adId,
    if (campaignId != null) 'campaign_id': campaignId,
    if (advertiserId != null) 'advertiser_id': advertiserId,
    if (advertiserName != null) 'advertiser_name': advertiserName,
    if (placement != null) 'placement': placement,
    'sponsor_label': sponsorLabel,
    'bid_amount': bidAmount,
    'starts_at': startsAt?.toUtc().toIso8601String(),
    'ends_at': endsAt?.toUtc().toIso8601String(),
    'is_active': isActive,
    'impressions': impressions,
    'clicks': clicks,
    'metadata': metadata,
  };
}

Map<String, dynamic> _unwrapSponsor(Map<String, dynamic> source) {
  var value = source;
  for (var depth = 0; depth < 4; depth++) {
    final nested =
        value['sponsored_product'] ?? value['sponsoredProduct'] ?? value['ad'];
    if (nested is Map) {
      value = _sponsorMap(nested);
      continue;
    }
    final data = value['data'];
    if (data is Map && !_looksLikeSponsoredProduct(value)) {
      value = _sponsorMap(data);
      continue;
    }
    break;
  }
  return value;
}

bool _looksLikeSponsoredProduct(Map<String, dynamic> value) =>
    value.containsKey('product') ||
    value.containsKey('product_id') ||
    value.containsKey('productId') ||
    value.containsKey('id') ||
    value.containsKey('campaign_id') ||
    value.containsKey('campaignId');

Map<String, dynamic> _sponsorMap(dynamic value) {
  if (value is! Map) return const <String, dynamic>{};
  return value.map((key, value) => MapEntry(key.toString(), value));
}

String _sponsorText(Iterable<dynamic> values, {String fallback = ''}) {
  for (final value in values) {
    if (value == null) continue;
    final text = value.toString().trim();
    if (text.isNotEmpty && text != 'null') return text;
  }
  return fallback;
}

String? _sponsorOptionalText(Iterable<dynamic> values) {
  final text = _sponsorText(values);
  return text.isEmpty ? null : text;
}

double _sponsorNumber(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is Map) {
    return _sponsorNumber(value['amount'] ?? value['value'] ?? value['price']);
  }
  final normalized = value?.toString().replaceAll(',', '').trim() ?? '';
  final match = RegExp(r'-?\d+(?:\.\d+)?').firstMatch(normalized);
  return match == null ? 0 : double.tryParse(match.group(0)!) ?? 0;
}

int _sponsorInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

bool _sponsorBool(dynamic value, {required bool fallback}) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    switch (value.trim().toLowerCase()) {
      case 'true':
      case '1':
      case 'yes':
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

DateTime? _sponsorDate(dynamic value) {
  if (value is DateTime) return value;
  if (value is int) {
    return DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);
  }
  if (value is String) {
    final text = value.trim();
    if (text.isEmpty) return null;
    final epoch = int.tryParse(text);
    if (epoch != null) {
      return DateTime.fromMillisecondsSinceEpoch(epoch, isUtc: true);
    }
    return DateTime.tryParse(text);
  }
  return null;
}

bool _hasText(String? value) => value != null && value.trim().isNotEmpty;
