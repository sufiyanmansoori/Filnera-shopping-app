import 'dart:convert';

import '../../../../core/network/api_client.dart';
import '../../domain/entities/home_data_entity.dart';

/// Loads and normalizes category navigation data for the home storefront.
class CategoryHomeDataSource {
  CategoryHomeDataSource({
    ApiClient? apiClient,
    this._cacheDuration = const Duration(minutes: 10),
    int maximumCacheEntries = 20,
  }) : _apiClient = apiClient ?? ApiClient(),
       _maximumCacheEntries = maximumCacheEntries < 1 ? 1 : maximumCacheEntries;

  final ApiClient _apiClient;
  final Duration _cacheDuration;
  final int _maximumCacheEntries;
  final Map<String, _CategoryCacheEntry> _cache = {};
  final Map<String, Future<List<HomeCategoryEntity>>> _inFlight = {};

  Future<List<HomeCategoryEntity>> fetchCategories({
    bool forceRefresh = false,
    bool activeOnly = true,
    String? searchQuery,
    String? parentId,
    int page = 1,
    int pageSize = 50,
    String? locale,
    String? country,
  }) async {
    final safePage = page < 1 ? 1 : page;
    final safePageSize = pageSize.clamp(1, 100);
    final key = jsonEncode(<Object?>[
      activeOnly,
      searchQuery?.trim().toLowerCase() ?? '',
      parentId?.trim() ?? '',
      safePage,
      safePageSize,
      locale ?? 'en_IN',
      country ?? 'IN',
    ]);

    if (!forceRefresh) {
      final cached = _readCache(key);
      if (cached != null) return cached;
      final pending = _inFlight[key];
      if (pending != null) {
        return List<HomeCategoryEntity>.of(await pending);
      }
    }

    final request = _loadCategories(
      activeOnly: activeOnly,
      searchQuery: searchQuery,
      parentId: parentId,
      page: safePage,
      pageSize: safePageSize,
      locale: locale,
      country: country,
    );
    if (!forceRefresh) _inFlight[key] = request;

    try {
      final categories = await request;
      if (!forceRefresh) _writeCache(key, categories);
      return List<HomeCategoryEntity>.of(categories);
    } finally {
      if (!forceRefresh) _inFlight.remove(key);
    }
  }

  Future<HomeCategoryEntity?> fetchCategoryById(String categoryId) async {
    final id = categoryId.trim().toLowerCase();
    if (id.isEmpty) {
      throw const FormatException('Category id cannot be empty');
    }

    final categories = await fetchCategories(pageSize: 100);
    for (final category in categories) {
      if (category.id.toLowerCase() == id ||
          category.slug.toLowerCase() == id) {
        return category;
      }
    }
    return null;
  }

  Future<List<HomeCategoryEntity>> fetchSubcategories({
    required String parentId,
    bool forceRefresh = false,
    int page = 1,
    int pageSize = 50,
  }) {
    if (parentId.trim().isEmpty) {
      throw const FormatException('Parent category id cannot be empty');
    }
    return fetchCategories(
      forceRefresh: forceRefresh,
      parentId: parentId,
      page: page,
      pageSize: pageSize,
    );
  }

  void clearCache() {
    _cache.clear();
  }

  Future<List<HomeCategoryEntity>> _loadCategories({
    required bool activeOnly,
    required int page,
    required int pageSize,
    String? searchQuery,
    String? parentId,
    String? locale,
    String? country,
  }) async {
    var categories = <HomeCategoryEntity>[];
    try {
      final response = await _apiClient.get(
        '/categories',
        queryParameters: {
          'active_only': activeOnly,
          'page': page,
          'page_size': pageSize,
          if (parentId != null && parentId.trim().isNotEmpty)
            'parent_id': parentId.trim(),
          if (locale != null && locale.isNotEmpty) 'locale': locale,
          if (country != null && country.isNotEmpty) 'country': country,
        },
      );
      categories = _parseCategories(response.data);
    } catch (_) {
      // The homepage category list remains a viable source when this endpoint
      // is temporarily unavailable.
    }

    if (categories.isEmpty) {
      try {
        final response = await _apiClient.get(
          '/home',
          queryParameters: {
            'locale': locale ?? 'en_IN',
            'country': country ?? 'IN',
          },
        );
        categories = _parseCategories(response.data);
      } catch (_) {
        // Use the bundled catalog if both category endpoints are unavailable.
      }
    }

    if (categories.isEmpty) categories = _fallbackCategories();
    if (activeOnly) {
      categories = categories.where((category) => category.isActive).toList();
    }
    if (parentId != null && parentId.trim().isNotEmpty) {
      final requestedParent = parentId.trim().toLowerCase();
      categories = categories
          .where(
            (category) => category.parentId?.toLowerCase() == requestedParent,
          )
          .toList();
    }
    final query = searchQuery?.trim().toLowerCase() ?? '';
    if (query.isNotEmpty) {
      categories = categories.where((category) {
        return category.name.toLowerCase().contains(query) ||
            category.slug.toLowerCase().contains(query) ||
            (category.description?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    final start = (page - 1) * pageSize;
    if (start >= categories.length) return const <HomeCategoryEntity>[];
    final end = (start + pageSize).clamp(0, categories.length);
    return categories.sublist(start, end);
  }

  List<HomeCategoryEntity> _parseCategories(dynamic payload) {
    final values = _extractCategoryValues(payload);
    final categories = <HomeCategoryEntity>[];
    final seenIds = <String>{};
    for (final value in values) {
      final category = _toCategory(value);
      if (category == null || !seenIds.add(category.id.toLowerCase())) continue;
      categories.add(category);
    }
    return categories;
  }

  List<dynamic> _extractCategoryValues(dynamic payload) {
    if (payload is List) return payload;
    if (payload is! Map) return const <dynamic>[];
    final map = Map<String, dynamic>.from(payload);
    for (final key in const <String>[
      'categories',
      'items',
      'results',
      'data',
      'content',
    ]) {
      final value = map[key];
      if (value is List) return value;
      if (value is Map) {
        final nested = _extractCategoryValues(value);
        if (nested.isNotEmpty) return nested;
      }
    }
    return const <dynamic>[];
  }

  HomeCategoryEntity? _toCategory(dynamic value) {
    if (value is String) {
      final name = value.trim();
      if (name.isEmpty) return null;
      final slug = _slugify(name);
      return HomeCategoryEntity(
        id: slug,
        name: name,
        slug: slug,
        imageUrl: _imageForCategory(name),
      );
    }
    if (value is! Map) return null;

    final json = Map<String, dynamic>.from(value);
    final name = _firstText(<dynamic>[
      json['name'],
      json['title'],
      json['label'],
    ]);
    final slugValue = _firstText(<dynamic>[
      json['slug'],
      json['url_slug'],
      json['urlSlug'],
    ]);
    final id = _firstText(<dynamic>[
      json['id'],
      json['category_id'],
      json['categoryId'],
    ]);
    final slug = slugValue.isEmpty
        ? _slugify(name.isEmpty ? id : name)
        : slugValue;
    final resolvedName = name.isEmpty ? _titleFromSlug(slug) : name;
    if (resolvedName.isEmpty || slug.isEmpty) return null;

    final parent = _optionalText(<dynamic>[
      json['parent_id'],
      json['parentId'],
      json['parent_category_id'],
      json['parentCategoryId'],
    ]);
    final image = _optionalText(<dynamic>[
      json['image_url'],
      json['imageUrl'],
      json['image'],
      json['icon_url'],
      json['iconUrl'],
    ]);

    return HomeCategoryEntity(
      id: id.isEmpty ? slug : id,
      name: resolvedName,
      slug: slug,
      imageUrl: image ?? _imageForCategory(resolvedName),
      parentId: parent,
      description: _optionalText(<dynamic>[
        json['description'],
        json['subtitle'],
      ]),
      isActive: _readBool(
        json['is_active'] ?? json['isActive'] ?? json['active'],
        fallback: true,
      ),
      subcategoryCount: _firstInt(<dynamic>[
        json['subcategory_count'],
        json['subcategoryCount'],
        json['children_count'],
      ]),
    );
  }

  List<HomeCategoryEntity> _fallbackCategories() => const [
    HomeCategoryEntity(
      id: 'mobiles',
      name: 'Mobiles',
      slug: 'mobiles',
      imageUrl: 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?auto=format&fit=crop&w=800&q=80',
    ),
    HomeCategoryEntity(
      id: 'electronics',
      name: 'Electronics',
      slug: 'electronics',
      imageUrl: 'https://images.unsplash.com/photo-1518770660439-4636190af475?auto=format&fit=crop&w=800&q=80',
    ),
    HomeCategoryEntity(
      id: 'fashion',
      name: 'Fashion',
      slug: 'fashion',
      imageUrl: 'https://images.unsplash.com/photo-1521572267360-ee0c2909d518?auto=format&fit=crop&w=800&q=80',
    ),
    HomeCategoryEntity(
      id: 'shoes',
      name: 'Shoes',
      slug: 'shoes',
      imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=800&q=80',
    ),
    HomeCategoryEntity(
      id: 'home',
      name: 'Home',
      slug: 'home',
      imageUrl: 'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?auto=format&fit=crop&w=800&q=80',
    ),
    HomeCategoryEntity(
      id: 'furniture',
      name: 'Furniture',
      slug: 'furniture',
      imageUrl: 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?auto=format&fit=crop&w=800&q=80',
    ),
    HomeCategoryEntity(
      id: 'tv-appliances',
      name: 'TV & Appliances',
      slug: 'tv-appliances',
      imageUrl: 'https://images.unsplash.com/photo-1593359677879-a4bb92f829d1?auto=format&fit=crop&w=800&q=80',
    ),
    HomeCategoryEntity(
      id: 'beauty',
      name: 'Beauty',
      slug: 'beauty',
      imageUrl: 'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?auto=format&fit=crop&w=800&q=80',
    ),
    HomeCategoryEntity(id: 'toys', name: 'Toys', slug: 'toys'),
    HomeCategoryEntity(id: 'grocery', name: 'Grocery', slug: 'grocery'),
    HomeCategoryEntity(
      id: 'travel-flights',
      name: 'Travel/Flights',
      slug: 'travel-flights',
      imageUrl: 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=800&q=80',
    ),
  ];

  String _imageForCategory(String name) {
    final normalized = name.toLowerCase();
    if (normalized.contains('mobile') || normalized.contains('phone')) {
      return 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?auto=format&fit=crop&w=800&q=80';
    }
    if (normalized.contains('electronic') || normalized.contains('audio')) {
      return 'https://images.unsplash.com/photo-1518770660439-4636190af475?auto=format&fit=crop&w=800&q=80';
    }
    if (normalized.contains('fashion') || normalized.contains('shoe')) {
      return 'https://images.unsplash.com/photo-1521572267360-ee0c2909d518?auto=format&fit=crop&w=800&q=80';
    }
    if (normalized.contains('home') || normalized.contains('furniture')) {
      return 'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?auto=format&fit=crop&w=800&q=80';
    }
    if (normalized.contains('beauty')) {
      return 'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?auto=format&fit=crop&w=800&q=80';
    }
    if (normalized.contains('travel')) {
      return 'https://images.unsplash.com/photo-1491637639811-60e2756cc1c7?auto=format&fit=crop&w=800&q=80';
    }
    return '';
  }

  String _slugify(String value) => value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');

  String _titleFromSlug(String value) => value
      .split(RegExp(r'[-_]+'))
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');

  String _firstText(List<dynamic> values) {
    for (final value in values) {
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isNotEmpty && text != 'null') return text;
    }
    return '';
  }

  String? _optionalText(List<dynamic> values) {
    final value = _firstText(values);
    return value.isEmpty ? null : value;
  }

  int _firstInt(List<dynamic> values) {
    for (final value in values) {
      if (value is num) return value.toInt();
      if (value is String) {
        final parsed = int.tryParse(value);
        if (parsed != null) return parsed;
      }
    }
    return 0;
  }

  bool _readBool(dynamic value, {required bool fallback}) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      switch (value.toLowerCase()) {
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

  List<HomeCategoryEntity>? _readCache(String key) {
    final entry = _cache[key];
    if (entry == null) return null;
    if (DateTime.now().isAfter(entry.expiresAt)) {
      _cache.remove(key);
      return null;
    }
    return List<HomeCategoryEntity>.of(entry.categories);
  }

  void _writeCache(String key, List<HomeCategoryEntity> categories) {
    _cache.remove(key);
    while (_cache.length >= _maximumCacheEntries) {
      _cache.remove(_cache.keys.first);
    }
    _cache[key] = _CategoryCacheEntry(
      categories: List<HomeCategoryEntity>.unmodifiable(categories),
      expiresAt: DateTime.now().add(_cacheDuration),
    );
  }
}

class _CategoryCacheEntry {
  const _CategoryCacheEntry({
    required this.categories,
    required this.expiresAt,
  });

  final List<HomeCategoryEntity> categories;
  final DateTime expiresAt;
}
