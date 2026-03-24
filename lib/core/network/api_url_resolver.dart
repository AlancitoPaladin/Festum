import 'package:festum/core/config/app_environment.dart';

String resolveApiAssetUrl(String value) {
  final String trimmedValue = value.trim();
  if (trimmedValue.isEmpty) {
    return '';
  }

  final Uri? parsedUri = Uri.tryParse(trimmedValue);
  if (parsedUri != null && parsedUri.hasScheme && parsedUri.host.isNotEmpty) {
    return trimmedValue;
  }

  if (trimmedValue.startsWith('data:') || trimmedValue.startsWith('file:')) {
    return trimmedValue;
  }

  final String normalizedBaseUrl = AppEnvironment.apiBaseUrl.endsWith('/')
      ? AppEnvironment.apiBaseUrl.substring(
          0,
          AppEnvironment.apiBaseUrl.length - 1,
        )
      : AppEnvironment.apiBaseUrl;
  final String normalizedPath = trimmedValue.startsWith('/')
      ? trimmedValue
      : '/$trimmedValue';

  return '$normalizedBaseUrl$normalizedPath';
}
