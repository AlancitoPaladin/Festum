import 'package:festum/features/provider/models/booking.dart';

enum ProductAvailabilityStatus { available, reserved, blocked }

class ProviderAvailabilityDay {
  const ProviderAvailabilityDay({
    required this.date,
    required this.status,
    required this.booking,
  });

  final DateTime date;
  final ProductAvailabilityStatus status;
  final Booking? booking;

  factory ProviderAvailabilityDay.fromJson(Map<String, dynamic> json) {
    return ProviderAvailabilityDay(
      date: DateTime.tryParse((json['date'] ?? '').toString()) ?? DateTime.now(),
      status: _statusFromJson(json['status']),
      booking: json['booking'] is Map
          ? Booking.fromJson(Map<String, dynamic>.from(json['booking'] as Map))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'date': date.toIso8601String(),
      'status': status.name,
      'booking': booking?.toJson(),
    };
  }
}

class ProviderProductAvailabilityMonthResponse {
  const ProviderProductAvailabilityMonthResponse({
    required this.productId,
    required this.productName,
    required this.year,
    required this.month,
    required this.days,
  });

  final String productId;
  final String productName;
  final int year;
  final int month;
  final List<ProviderAvailabilityDay> days;

  factory ProviderProductAvailabilityMonthResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return ProviderProductAvailabilityMonthResponse(
      productId: (json['product_id'] ?? '').toString(),
      productName: (json['product_name'] ?? '').toString(),
      year: _toInt(json['year']),
      month: _toInt(json['month']),
      days: ((json['days'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map<dynamic, dynamic>>()
          .map(
            (Map<dynamic, dynamic> item) => ProviderAvailabilityDay.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList()),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'product_id': productId,
      'product_name': productName,
      'year': year,
      'month': month,
      'days': days.map((ProviderAvailabilityDay day) => day.toJson()).toList(),
    };
  }
}

ProductAvailabilityStatus _statusFromJson(Object? value) {
  final String normalized = (value ?? 'available').toString().trim().toLowerCase();
  switch (normalized) {
    case 'reserved':
      return ProductAvailabilityStatus.reserved;
    case 'blocked':
      return ProductAvailabilityStatus.blocked;
    default:
      return ProductAvailabilityStatus.available;
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
