class ProviderRequestError {
  const ProviderRequestError({
    required this.message,
    this.fieldErrors = const <String, String>{},
  });

  final String message;
  final Map<String, String> fieldErrors;

  bool get hasFieldErrors => fieldErrors.isNotEmpty;
}
