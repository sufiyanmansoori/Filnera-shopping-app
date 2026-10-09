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
    final _ = _metadataMap(
      root['context'] ?? root['localization'] ?? root['market'],
    );
    final _ = _metadataMap(root['cache'] ?? root['cache_info']);
    final _ = _metadataMap(
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
        final additional = Map<String, Object?>.fromEntries(
          root.entries
              .where((entry) => !knownKeys.contains(entry.key))
              .map((entry) => MapEntry(entry.key, entry.value)),
        )
          ..addAll(
            Map<String, Object?>.fromEntries(
              context.entries
                  .where(
                    (entry) =>
                        !const <String>{
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
                        }.contains(entry.key),
                  )
                  .map((entry) => MapEntry('context.${entry.key}', entry.value)),
            ),
          )
          ..addAll(
            Map<String, Object?>.fromEntries(
              cache.entries
                  .where((entry) =>
                      !const <String>{
                        'hit',
                        'is_hit',
                        'isHit',
                        'age_seconds',
                        'ageSeconds',
                        'age',
                      }.contains(entry.key))
                  .map((entry) => MapEntry('cache.${entry.key}', entry.value)),
            ),
          );

    return HomeMetadataModel(
      locale: _metadataText(<dynamic>[
        root['locale'],
        root['locale_code'],
        root['localeCode'],
        context['locale'],
        context['locale_code'],
        context['localeCode'],
      ]),
      country: _metadataText(<dynamic>[
        root['country'],
        root['country_code'],
        root['countryCode'],
        context['country'],
        context['country_code'],
        context['countryCode'],
      ]),
      region: _metadataText(<dynamic>[root['region'], context['region']]),
      currency: _metadataText(<dynamic>[
        root['currency'],
        root['currency_code'],
        root['currencyCode'],
        context['currency'],
        context['currency_code'],
        context['currencyCode'],
      ]),
      timeZone: _metadataText(<dynamic>[
        root['timezone'],
        root['time_zone'],
        root['timeZone'],
        context['timezone'],
        context['time_zone'],
        context['timeZone'],
      ]),
      requestId: _metadataText(<dynamic>[
        root['request_id'],
        root['requestId'],
        root['trace_id'],
      ]),
      apiVersion: _metadataText(<dynamic>[
        root['api_version'],
        root['apiVersion'],
        root['version'],
      ]),
      source: _metadataText(<dynamic>[root['source']]),
      personalizedFor: _metadataText(<dynamic>[
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
            cache['is_hit'],
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
      experiments: experiments.cast<String, Object?>(),
      additional: additional,
    );
  }

  HomeMetadataModel copyWith({
    String? locale,
    String? country,
    String? region,
    String? currency,
    String? timeZone,
    String? requestId,
    String? apiVersion,
    String? source,
    String? personalizedFor,
    DateTime? generatedAt,
    DateTime? expiresAt,
    bool? cacheHit,
    int? cacheAgeSeconds,
    int? schemaVersion,
    Map<String, Object?>? experiments,
    Map<String, Object?>? additional,
  }) => HomeMetadataModel(
    locale: locale ?? this.locale,
    country: country ?? this.country,
    region: region ?? this.region,
    currency: currency ?? this.currency,
    timeZone: timeZone ?? this.timeZone,
    requestId: requestId ?? this.requestId,
    apiVersion: apiVersion ?? this.apiVersion,
    source: source ?? this.source,
    personalizedFor: personalizedFor ?? this.personalizedFor,
    generatedAt: generatedAt ?? this.generatedAt,
    expiresAt: expiresAt ?? this.expiresAt,
    cacheHit: cacheHit ?? this.cacheHit,
    cacheAgeSeconds: cacheAgeSeconds ?? this.cacheAgeSeconds,
    schemaVersion: schemaVersion ?? this.schemaVersion,
    experiments: experiments ?? this.experiments,
    additional: additional ?? this.additional,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    if (locale != null) 'locale': locale,
    if (country != null) 'country': country,
    if (region != null) 'region': region,
    if (currency != null) 'currency': currency,
    if (timeZone != null) 'timezone': timeZone,
    if (requestId != null) 'request_id': requestId,
    if (apiVersion != null) 'api_version': apiVersion,
    if (source != null) 'source': source,
    if (personalizedFor != null) 'personalized_for': personalizedFor,
    if (generatedAt != null)
      'generated_at': generatedAt!.toUtc().toIso8601String(),
    if (expiresAt != null) 'expires_at': expiresAt!.toUtc().toIso8601String(),
    if (cacheHit != null) 'cache_hit': cacheHit,
    if (cacheAgeSeconds != null) 'cache_age_seconds': cacheAgeSeconds,
    if (schemaVersion != null) 'schema_version': schemaVersion,
    if (experiments.isNotEmpty) 'experiments': experiments,
    ...additional,
  };
}

Map<String, dynamic> _unwrapMetadata(Map<String, dynamic> source) {
  var metadata = source;
  for (var depth = 0; depth < 3; depth++) {
    final nested = metadata['metadata'] ?? metadata['meta'];
    if (nested is Map) {
      metadata = _metadataMap(nested);
      continue;
    }
    final data = metadata['data'];
    if (data is Map && !_looksLikeMetadata(metadata)) {
      metadata = _metadataMap(data);
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

Map<String, dynamic> _metadataMap(dynamic value) {
  if (value is! Map) return const <String, dynamic>{};
  return value.map((key, value) => MapEntry(key.toString(), value));
}

String? _metadataText(Iterable<dynamic> values) {
  for (final value in values) {
    if (value == null) continue;
    final text = value.toString().trim();
    if (text.isNotEmpty && text != 'null') return text;
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

bool? _metadataBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    switch (value.trim().toLowerCase()) {
      case 'true':
      case '1':
      case 'yes':
      case 'hit':
        return true;
      case 'false':
      case '0':
      case 'no':
      case 'miss':
        return false;
    }
  }
  return null;
}

DateTime? _metadataDate(dynamic value) {
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
