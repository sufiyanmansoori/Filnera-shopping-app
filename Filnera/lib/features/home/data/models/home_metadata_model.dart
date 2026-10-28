class HomeMetadataModel {
  HomeMetadataModel({
    this.locale,
    this.country,
    this.region,
    this.currency,
    this.timeZone,
    this.requestId,
    this.apiVersion,
    this.source,
    this.personalizedFor,
    this.generatedAt,
    this.expiresAt,
    this.cacheHit,
    this.cacheAgeSeconds,
    this.schemaVersion,
    Map<String, Object?> experiments = const <String, Object?>{},
    Map<String, Object?> additional = const <String, Object?>{},
  }) : experiments = Map<String, Object?>.unmodifiable(experiments),
       additional = Map<String, Object?>.unmodifiable(additional);

  final String? locale;
  final String? country;
  final String? region;
  final String? currency;
  final String? timeZone;
  final String? requestId;
  final String? apiVersion;
  final String? source;
  final String? personalizedFor;
  final DateTime? generatedAt;
  final DateTime? expiresAt;
  final bool? cacheHit;
  final int? cacheAgeSeconds;
  final int? schemaVersion;
  final Map<String, Object?> experiments;
  final Map<String, Object?> additional;

  Duration? get cacheAge =>
      cacheAgeSeconds == null ? null : Duration(seconds: cacheAgeSeconds!);

  bool get hasLocalization =>
      locale != null || country != null || region != null || currency != null;

  bool get hasCacheInfo => cacheHit != null || cacheAgeSeconds != null;

  bool isExpiredAt([DateTime? dateTime]) {
    final expiry = expiresAt;
    return expiry != null && (dateTime ?? DateTime.now()).isAfter(expiry);
  }

  factory HomeMetadataModel.fromJson(Map<String, dynamic> json) {
    final root = _unwrapMetadata(json);
    final context = _metadataMap(
      root['context'] ?? root['localization'] ?? root['market'],
    );
    final cache = _metadataMap(root['cache'] ?? root['cache_info']);
    final personalization = _metadataMap(
      root['personalization'] ?? root['personalization_context'],
    );
    final experiments = _metadataMap(
      root['experiments'] ?? root['experiment_assignments'],
    );

    const knownKeys = <String>{
      'metadata',
      'meta',
      'data',
      'context',
      'localization',
      'market',
      'cache',
      'cache_info',
      'personalization',
      'personalization_context',
      'experiments',
      'experiment_assignments',
      'locale',
      'locale_code',
      'localeCode',
      'country',
      'country_code',
      'countryCode',
      'region',
      'currency',
      'currency_code',
      'currencyCode',
      'timezone',
      'time_zone',
      'timeZone',
      'request_id',
      'requestId',
      'trace_id',
      'api_version',
      'apiVersion',
      'version',
      'source',
      'personalized_for',
      'personalizedFor',
      'user_id',
      'userId',
      'generated_at',
      'generatedAt',
      'updated_at',
      'updatedAt',
      'expires_at',
      'expiresAt',
      'cache_hit',
      'cacheHit',
      'cache_age_seconds',
      'cacheAgeSeconds',
      'schema_version',
      'schemaVersion',
    };

    final additional = <String, Object?>{
      for (final entry in root.entries)
        if (!knownKeys.contains(entry.key)) entry.key: entry.value,
      for (final entry in context.entries)
        if (!_contextKeys.contains(entry.key))
          'context.${entry.key}': entry.value,
      for (final entry in cache.entries)
        if (!_cacheKeys.contains(entry.key)) 'cache.${entry.key}': entry.value,
      for (final entry in personalization.entries)
        if (!_personalizationKeys.contains(entry.key))
          'personalization.${entry.key}': entry.value,
    };

    return HomeMetadataModel(
      locale: _metadataText(<Object?>[
        root['locale'],
        root['locale_code'],
        root['localeCode'],
        context['locale'],
        context['locale_code'],
        context['localeCode'],
      ]),
      country: _metadataText(<Object?>[
        root['country'],
        root['country_code'],
        root['countryCode'],
        context['country'],
        context['country_code'],
        context['countryCode'],
      ]),
      region: _metadataText(<Object?>[root['region'], context['region']]),
      currency: _metadataText(<Object?>[
        root['currency'],
        root['currency_code'],
        root['currencyCode'],
        context['currency'],
        context['currency_code'],
        context['currencyCode'],
      ]),
      timeZone: _metadataText(<Object?>[
        root['timezone'],
        root['time_zone'],
        root['timeZone'],
        context['timezone'],
        context['time_zone'],
        context['timeZone'],
      ]),
      requestId: _metadataText(<Object?>[
        root['request_id'],
        root['requestId'],
        root['trace_id'],
      ]),
      apiVersion: _metadataText(<Object?>[
        root['api_version'],
        root['apiVersion'],
        root['version'],
      ]),
      source: _metadataText(<Object?>[root['source']]),
      personalizedFor: _metadataText(<Object?>[
        root['personalized_for'],
        root['personalizedFor'],
        root['user_id'],
        root['userId'],
        personalization['user_id'],
        personalization['userId'],
        personalization['customer_id'],
      ]),
      generatedAt: _metadataDate(
        root['generated_at'] ??
            root['generatedAt'] ??
            root['updated_at'] ??
            root['updatedAt'],
      ),
      expiresAt: _metadataDate(root['expires_at'] ?? root['expiresAt']),
      cacheHit: _metadataBool(
        root['cache_hit'] ??
            root['cacheHit'] ??
            cache['hit'] ??
            cache['is_hit'] ??
            cache['isHit'],
      ),
      cacheAgeSeconds: _metadataInt(
        root['cache_age_seconds'] ??
            root['cacheAgeSeconds'] ??
            cache['age_seconds'] ??
            cache['ageSeconds'] ??
            cache['age'],
      ),
      schemaVersion: _metadataInt(
        root['schema_version'] ?? root['schemaVersion'],
      ),
      experiments: experiments,
      additional: additional,
    );
  }
}

const _contextKeys = <String>{
  'locale',
  'locale_code',
  'localeCode',
  'country',
  'country_code',
  'countryCode',
  'region',
  'currency',
  'currency_code',
  'currencyCode',
  'timezone',
  'time_zone',
  'timeZone',
};

const _cacheKeys = <String>{
  'hit',
  'is_hit',
  'isHit',
  'age_seconds',
  'ageSeconds',
  'age',
};

const _personalizationKeys = <String>{'user_id', 'userId', 'customer_id'};

Map<String, dynamic> _unwrapMetadata(Map<String, dynamic> source) {
  var metadata = source;
  for (var depth = 0; depth < 3; depth++) {
    final nested = metadata['metadata'] ?? metadata['meta'];
    if (nested is Map) {
      metadata = _metadataMap(nested).cast<String, dynamic>();
      continue;
    }
    final data = metadata['data'];
    if (data is Map && !_looksLikeMetadata(metadata)) {
      metadata = _metadataMap(data).cast<String, dynamic>();
      continue;
    }
    break;
  }
  return metadata;
}

bool _looksLikeMetadata(Map<String, dynamic> value) =>
    value.containsKey('locale') ||
    value.containsKey('country') ||
    value.containsKey('currency') ||
    value.containsKey('cache_hit') ||
    value.containsKey('request_id');

Map<String, Object?> _metadataMap(dynamic value) {
  if (value is! Map) return const <String, Object?>{};
  return Map<String, Object?>.fromEntries(
    value.entries.map((entry) => MapEntry(entry.key.toString(), entry.value)),
  );
}

String? _metadataText(Iterable<Object?> values) {
  for (final value in values) {
    if (value == null || value is Map || value is List) continue;
    final text = value.toString().trim();
    if (text.isNotEmpty) return text;
  }
  return null;
}

DateTime? _metadataDate(dynamic value) {
  if (value is DateTime) return value;
  if (value is num) {
    final milliseconds = value.abs() < 100000000000 ? value * 1000 : value;
    return DateTime.fromMillisecondsSinceEpoch(
      milliseconds.toInt(),
      isUtc: true,
    );
  }
  if (value is Map) {
    return _metadataDate(value['date'] ?? value['timestamp'] ?? value['value']);
  }
  if (value is String) return DateTime.tryParse(value.trim());
  return null;
}

bool? _metadataBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) {
    if (value == 1) return true;
    if (value == 0) return false;
  }
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
  return null;
}

int? _metadataInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is Map) {
    return _metadataInt(value['seconds'] ?? value['value'] ?? value['age']);
  }
  return int.tryParse(value?.toString() ?? '');
}
