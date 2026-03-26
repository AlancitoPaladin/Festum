class ProviderOrderRequest {
  const ProviderOrderRequest({
    required this.id,
    required this.serviceId,
    required this.serviceName,
    required this.productId,
    required this.productName,
    required this.clientName,
    required this.eventDate,
    required this.totalLabel,
    required this.status,
    required this.notes,
  });

  final String id;
  final String serviceId;
  final String serviceName;
  final String productId;
  final String productName;
  final String clientName;
  final DateTime? eventDate;
  final String totalLabel;
  final String status;
  final String notes;

  String get resolvedServiceName {
    final String value = serviceName.trim();
    return value.isEmpty ? 'Servicio' : value;
  }

  String get resolvedClientName {
    final String value = clientName.trim();
    return value.isEmpty ? 'Cliente' : value;
  }

  String get resolvedStatus {
    final String value = status.trim().toLowerCase();
    if (value.isEmpty) {
      return 'pending_provider_approval';
    }
    return value;
  }

  String get resolvedTotalLabel {
    final String value = totalLabel.trim();
    return value.isEmpty ? '-' : value;
  }

  factory ProviderOrderRequest.fromJson(Map<String, dynamic> json) {
    final DateTime? eventDate = _parseDate(
      json['event_date'] ??
          json['requested_date'] ??
          json['date'] ??
          json['created_at'],
    );
    return ProviderOrderRequest(
      id: (json['id'] ?? '').toString(),
      serviceId: (json['service_id'] ?? '').toString(),
      serviceName: ((json['service_name'] ?? json['title']) ?? '').toString(),
      productId: (json['product_id'] ?? '').toString(),
      productName: (json['product_name'] ?? '').toString(),
      clientName: ((json['client_name'] ?? json['customer_name']) ?? '')
          .toString(),
      eventDate: eventDate,
      totalLabel: (json['total_label'] ?? '').toString(),
      status:
          ((json['status'] ?? json['request_status']) ??
                  'pending_provider_approval')
              .toString(),
      notes: (json['notes'] ?? '').toString(),
    );
  }
}

DateTime? _parseDate(Object? value) {
  final String raw = (value ?? '').toString().trim();
  if (raw.isEmpty) {
    return null;
  }
  return DateTime.tryParse(raw);
}
