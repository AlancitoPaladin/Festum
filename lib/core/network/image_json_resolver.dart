import 'package:festum/core/network/asset_url_safety.dart';

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

String _normalizeImageUrl(dynamic value) {
  final String raw = (value ?? '').toString().trim();
  if (raw.isEmpty) {
    return '';
  }
  return sanitizeAssetUrl(raw);
}
