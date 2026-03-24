import 'package:festum/features/provider/models/service_category.dart';

class ReservationBookingSummary {
  const ReservationBookingSummary({
    required this.id,
    required this.customerName,
    required this.customerImageUrl,
    required this.date,
    required this.status,
  });

  final String id;
  final String customerName;
  final String customerImageUrl;
  final DateTime date;
  final String status;

  factory ReservationBookingSummary.fromJson(Map<String, dynamic> json) {
    return ReservationBookingSummary(
      id: (json['booking_id'] ?? '').toString(),
      customerName: (json['customer_name'] ?? '').toString(),
      customerImageUrl: (json['customer_image_url'] ?? '').toString(),
      date: DateTime.tryParse((json['date'] ?? '').toString()) ?? DateTime.now(),
      status: (json['status'] ?? '').toString(),
    );
  }
}

class ProductReservationSummary {
  const ProductReservationSummary({
    required this.id,
    required this.serviceId,
    required this.productName,
    required this.category,
    required this.imageUrl,
    required this.nextBooking,
  });

  final String id;
  final String serviceId;
  final String productName;
  final ServiceCategory category;
  final String imageUrl;
  final ReservationBookingSummary? nextBooking;

  factory ProductReservationSummary.fromJson(Map<String, dynamic> json) {
    return ProductReservationSummary(
      id: (json['id'] ?? '').toString(),
      serviceId: (json['service_id'] ?? '').toString(),
      productName: (json['product_name'] ?? '').toString(),
      category: ServiceCategory.values.firstWhere(
        (ServiceCategory item) => item.name == json['category'],
        orElse: () => ServiceCategory.dj,
      ),
      imageUrl: (json['image_url'] ?? '').toString(),
      nextBooking: json['next_booking'] is Map<String, dynamic>
          ? ReservationBookingSummary.fromJson(
              Map<String, dynamic>.from(json['next_booking'] as Map),
            )
          : null,
    );
  }
}

class ProductReservationsResponse {
  const ProductReservationsResponse({
    required this.items,
    required this.total,
  });

  final List<ProductReservationSummary> items;
  final int total;

  factory ProductReservationsResponse.fromJson(Map<String, dynamic> json) {
    return ProductReservationsResponse(
      items:
          ((json['items'] as List<dynamic>? ?? <dynamic>[])
              .whereType<Map<dynamic, dynamic>>()
              .map(
                (Map<dynamic, dynamic> item) =>
                    ProductReservationSummary.fromJson(
                      Map<String, dynamic>.from(item),
                    ),
              )
              .toList()),
      total: _toInt(json['total']),
    );
  }
}

int _toInt(Object? value) {
  if (value is int) {
    return value;
  }

  return int.tryParse(value?.toString() ?? '') ?? 0;
}
