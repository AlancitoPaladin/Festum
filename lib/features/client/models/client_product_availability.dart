enum ClientAvailabilityStatus { available, reserved, blocked }

class ClientAvailabilityDay {
  const ClientAvailabilityDay({
    required this.date,
    required this.status,
  });

  final DateTime date;
  final ClientAvailabilityStatus status;

  factory ClientAvailabilityDay.fromJson(Map<String, dynamic> json) {
    return ClientAvailabilityDay(
      date: DateTime.tryParse((json['date'] ?? '').toString()) ?? DateTime.now(),
      status: _statusFromJson(json['status']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'date': date.toIso8601String(),
      'status': status.name,
    };
  }
}

class ClientProductAvailabilityResponse {
  const ClientProductAvailabilityResponse({
    required this.productId,
    required this.year,
    required this.month,
    required this.days,
  });

  final String productId;
  final int year;
  final int month;
  final List<ClientAvailabilityDay> days;

  factory ClientProductAvailabilityResponse.fromJson(Map<String, dynamic> json) {
    return ClientProductAvailabilityResponse(
      productId: (json['product_id'] ?? '').toString(),
      year: _toInt(json['year']),
      month: _toInt(json['month']),
      days: ((json['days'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map<dynamic, dynamic>>()
          .map(
            (Map<dynamic, dynamic> item) => ClientAvailabilityDay.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList()),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'product_id': productId,
      'year': year,
      'month': month,
      'days': days.map((ClientAvailabilityDay day) => day.toJson()).toList(),
    };
  }
}

ClientAvailabilityStatus _statusFromJson(Object? value) {
  final String normalized = (value ?? 'available').toString().trim().toLowerCase();
  switch (normalized) {
    case 'reserved':
      return ClientAvailabilityStatus.reserved;
    case 'blocked':
      return ClientAvailabilityStatus.blocked;
    default:
      return ClientAvailabilityStatus.available;
  }
}

int _toInt(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse((value ?? '').toString()) ?? 0;
}
