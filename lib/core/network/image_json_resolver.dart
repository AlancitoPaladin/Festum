import 'package:festum/core/network/asset_url_safety.dart';

enum ResolvedImageUseCase { list, detail, original }

Map<String, dynamic>? asStringDynamicMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  return null;
}

String resolveImageUrlFromJson(
  Map<String, dynamic> json, {
  List<String> directKeys = const <String>[
    'main_image_url',
    'image_url',
    'logo_url',
    'asset_url',
    'avatar_url',
    'url',
  ],
  List<String> objectKeys = const <String>[
    'main_image',
    'image',
    'logo',
    'asset',
    'avatar',
  ],
  List<String> listKeys = const <String>[
    'images',
    'image_urls',
    'photos',
    'photo_urls',
  ],
}) {
  for (final String key in directKeys) {
    final String value = _normalizeImageUrl(json[key]);
    if (value.isNotEmpty) {
      return value;
    }
  }

  for (final String key in objectKeys) {
    final Map<String, dynamic>? payload = asStringDynamicMap(json[key]);
    if (payload == null) {
      continue;
    }
    final String value = resolveImageUrlFromJson(
      payload,
      directKeys: const <String>[
        'url',
        'image_url',
        'main_image_url',
        'asset_url',
        'logo_url',
        'avatar_url',
      ],
      objectKeys: const <String>['image', 'asset', 'main_image', 'logo'],
      listKeys: const <String>['images', 'image_urls', 'photos', 'photo_urls'],
    );
    if (value.isNotEmpty) {
      return value;
    }
  }

  for (final String key in listKeys) {
    final List<String> values = resolveImageUrlsFromJson(
      json,
      listKeys: <String>[key],
    );
    if (values.isNotEmpty) {
      return values.first;
    }
  }

  return '';
}

String resolveImageUrlForUseCaseFromJson(
  Map<String, dynamic> json, {
  required ResolvedImageUseCase useCase,
  List<String> directKeys = const <String>[
    'main_image_url',
    'image_url',
    'logo_url',
    'asset_url',
    'avatar_url',
    'url',
  ],
  List<String> objectKeys = const <String>[
    'main_image',
    'image',
    'logo',
    'asset',
    'avatar',
  ],
  List<String> listKeys = const <String>[
    'images',
    'image_urls',
    'photos',
    'photo_urls',
  ],
}) {
  for (final String key in objectKeys) {
    final Map<String, dynamic>? payload = asStringDynamicMap(json[key]);
    if (payload == null) {
      continue;
    }
    final String value = _resolveVariantUrlFromAssetPayload(
      payload,
      useCase: useCase,
    );
    if (value.isNotEmpty) {
      return value;
    }
  }

  for (final String key in directKeys) {
    final String value = _normalizeImageUrl(json[key]);
    if (value.isNotEmpty) {
      return value;
    }
  }

  final List<String> urls = resolveImageUrlsForUseCaseFromJson(
    json,
    useCase: useCase,
    listKeys: listKeys,
  );
  if (urls.isNotEmpty) {
    return urls.first;
  }

  return '';
}

List<String> resolveImageUrlsForUseCaseFromJson(
  Map<String, dynamic> json, {
  required ResolvedImageUseCase useCase,
  List<String> listKeys = const <String>[
    'images',
    'image_urls',
    'photos',
    'photo_urls',
  ],
}) {
  final List<String> resolved = <String>[];
  for (final String key in listKeys) {
    final dynamic rawList = json[key];
    if (rawList is! List) {
      continue;
    }
    for (final dynamic item in rawList) {
      if (item is String) {
        final String value = _normalizeImageUrl(item);
        if (value.isNotEmpty) {
          resolved.add(value);
        }
        continue;
      }
      final Map<String, dynamic>? payload = asStringDynamicMap(item);
      if (payload == null) {
        continue;
      }
      final String value = _resolveVariantUrlFromAssetPayload(
        payload,
        useCase: useCase,
      );
      if (value.isNotEmpty) {
        resolved.add(value);
      }
    }
  }
  return resolved;
}

List<String> resolveImageUrlsFromJson(
  Map<String, dynamic> json, {
  List<String> listKeys = const <String>[
    'images',
    'image_urls',
    'photos',
    'photo_urls',
  ],
}) {
  final List<String> resolved = <String>[];

  for (final String key in listKeys) {
    final dynamic rawList = json[key];
    if (rawList is! List) {
      continue;
    }

    for (final dynamic item in rawList) {
      if (item is String) {
        final String value = _normalizeImageUrl(item);
        if (value.isNotEmpty) {
          resolved.add(value);
        }
        continue;
      }

      final Map<String, dynamic>? payload = asStringDynamicMap(item);
      if (payload == null) {
        continue;
      }

      final String value = resolveImageUrlFromJson(
        payload,
        directKeys: const <String>[
          'url',
          'image_url',
          'main_image_url',
          'asset_url',
          'logo_url',
          'avatar_url',
        ],
        objectKeys: const <String>['image', 'asset', 'main_image', 'logo'],
        listKeys: const <String>[],
      );
      if (value.isNotEmpty) {
        resolved.add(value);
      }
    }
  }

  return resolved;
}

String _resolveVariantUrlFromAssetPayload(
  Map<String, dynamic> payload, {
  required ResolvedImageUseCase useCase,
}) {
  String urlFrom(dynamic value) {
    if (value == null) {
      return '';
    }
    if (value is String) {
      return _normalizeImageUrl(value);
    }
    if (value is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(value);
      return _normalizeImageUrl(
        map['url'] ?? map['image_url'] ?? map['asset_url'],
      );
    }
    return '';
  }

  final String base = urlFrom(payload);
  final String thumb = urlFrom(payload['thumb']);
  final String medium = urlFrom(payload['medium']);
  final String original = urlFrom(payload['original']);

  List<String> ordered;
  switch (useCase) {
    case ResolvedImageUseCase.list:
      ordered = <String>[thumb, medium, base, original];
      break;
    case ResolvedImageUseCase.detail:
      ordered = <String>[medium, base, original, thumb];
      break;
    case ResolvedImageUseCase.original:
      ordered = <String>[original, medium, base, thumb];
      break;
  }
  for (final String candidate in ordered) {
    if (candidate.isNotEmpty) {
      return candidate;
    }
  }
  return '';
}

String _normalizeImageUrl(dynamic value) {
  final String raw = (value ?? '').toString().trim();
  if (raw.isEmpty) {
    return '';
  }
  return sanitizeAssetUrl(raw);
}
