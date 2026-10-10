class CacheStorage { final Map<String, Object?> _cache = <String, Object?>{}; void save(String key, Object? value) => _cache[key] = value; T? read<T>(String key) => _cache[key] as T?; }
