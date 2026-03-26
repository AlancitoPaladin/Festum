class ClientCartItem {
  const ClientCartItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unitPriceCents,
    this.serviceName,
    this.productId,
    this.productName,
    this.selectedProductIds = const <String>[],
  });

  final String id;
  final String name;
  final int quantity;
  final int unitPriceCents;
  final String? serviceName;
  final String? productId;
  final String? productName;
  final List<String> selectedProductIds;

  String get resolvedServiceName {
    final String explicit = (serviceName ?? '').trim();
    if (explicit.isNotEmpty) {
      return explicit;
    }
    final String fallback = name.trim();
    if (fallback.contains(' · ')) {
      return fallback.split(' · ').first.trim();
    }
    return fallback.isEmpty ? 'Servicio' : fallback;
  }

  String? get resolvedProductName {
    final String explicit = (productName ?? '').trim();
    if (explicit.isNotEmpty) {
      return explicit;
    }
    final String fallback = name.trim();
    if (!fallback.contains(' · ')) {
      return null;
    }
    final List<String> parts = fallback.split(' · ');
    if (parts.length < 2) {
      return null;
    }
    final String joined = parts.sublist(1).join(' · ').trim();
    return joined.isEmpty ? null : joined;
  }
}
