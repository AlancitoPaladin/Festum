class ClientQueryCacheService {
  final Map<String, _CacheEntry> _entries = <String, _CacheEntry>{};
  final Map<String, Future<dynamic>> _inFlight = <String, Future<dynamic>>{};

  T? getIfFresh<T>(String key) {
    final _CacheEntry? entry = _entries[key];
    if (entry == null) {
      return null;
    }
    if (DateTime.now().isAfter(entry.expiresAt)) {
      _entries.remove(key);
      return null;
    }
    final dynamic value = entry.value;
    if (value is! T) {
      return null;
    }
    return value;
  }

  T? getIfPresent<T>(String key) {
    final _CacheEntry? entry = _entries[key];
    if (entry == null) {
      return null;
    }
    final dynamic value = entry.value;
    if (value is! T) {
      return null;
    }
    return value;
  }

  Future<T> getOrLoad<T>({
    required String key,
    required Duration ttl,
    required Future<T> Function() loader,
  }) async {
    final T? cached = getIfFresh<T>(key);
    if (cached != null) {
      return cached;
    }

    final Future<dynamic>? pending = _inFlight[key];
    if (pending != null) {
      return await pending as T;
    }

    final Future<T> request = loader();
    _inFlight[key] = request;
    try {
      final T value = await request;
      _entries[key] = _CacheEntry(
        value: value,
        expiresAt: DateTime.now().add(ttl),
      );
      return value;
    } finally {
      _inFlight.remove(key);
    }
  }

  void invalidate(String key) {
    _entries.remove(key);
    _inFlight.remove(key);
  }

  void invalidatePrefix(String prefix) {
    final Iterable<String> keys = _entries.keys.where(
      (String key) => key.startsWith(prefix),
    );
    for (final String key in keys.toList()) {
      _entries.remove(key);
    }
    final Iterable<String> pendingKeys = _inFlight.keys.where(
      (String key) => key.startsWith(prefix),
    );
    for (final String key in pendingKeys.toList()) {
      _inFlight.remove(key);
    }
  }
}

class _CacheEntry {
  const _CacheEntry({required this.value, required this.expiresAt});

  final dynamic value;
  final DateTime expiresAt;
}
