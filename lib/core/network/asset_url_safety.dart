String sanitizeAssetUrl(String value) {
  final String input = value.trim();
  if (input.isEmpty) {
    return '';
  }

  final Uri? uri = Uri.tryParse(input);
  if (uri == null) {
    return input;
  }

  if (!_isAmazonS3Host(uri.host)) {
    return input;
  }

  if (_hasPresignedParams(uri)) {
    return input;
  }

  // Ignore unsigned S3 URLs to avoid predictable 403s for private objects.
  return '';
}

bool _isAmazonS3Host(String host) {
  final String normalized = host.toLowerCase();
  return normalized.contains('amazonaws.com');
}

bool _hasPresignedParams(Uri uri) {
  final Map<String, String> qp = uri.queryParameters.map(
    (String key, String value) => MapEntry(key.toLowerCase(), value),
  );

  final bool hasV4 =
      qp.containsKey('x-amz-signature') && qp.containsKey('x-amz-credential');
  final bool hasLegacyV2 =
      qp.containsKey('signature') && qp.containsKey('awsaccesskeyid');
  final bool hasExpiry =
      qp.containsKey('expires') || qp.containsKey('x-amz-expires');

  return (hasV4 || hasLegacyV2) && hasExpiry;
}
