import 'package:festum/features/provider/models/booking.dart';
import 'package:festum/features/provider/models/service_category.dart';

typedef ReservationBookingSummary = Booking;

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
  final Booking? nextBooking;

  factory ProductReservationSummary.fromJson(Map<String, dynamic> json) {
    return ProductReservationSummary(
      id: (json['id'] ?? '').toString(),
      serviceId: (json['service_id'] ?? '').toString(),
      productName: ((json['product_name'] ?? json['name']) ?? '').toString(),
      category: ServiceCategory.values.firstWhere(
        (ServiceCategory item) => item.name == json['category'],
        orElse: () => ServiceCategory.dj,
      ),
      imageUrl: _resolveImageUrl(
        json,
        directKeys: const <String>[
          'image_url',
          'main_image_url',
        ],
        objectKeys: const <String>['image', 'main_image'],
        listKeys: const <String>['images', 'image_urls'],
      ),
      nextBooking: json['next_booking'] is Map<String, dynamic>
          ? Booking.fromJson(
              Map<String, dynamic>.from(json['next_booking'] as Map),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'service_id': serviceId,
      'product_name': productName,
      'category': category.name,
      'image_url': imageUrl,
      'next_booking': nextBooking?.toJson(),
    };
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

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'items': items.map((ProductReservationSummary item) => item.toJson()).toList(),
      'total': total,
    };
  }
}

int _toInt(Object? value) {
  if (value is int) {
    return value;
  }

  return int.tryParse(value?.toString() ?? '') ?? 0;
}

String _resolveImageUrl(
  Map<String, dynamic> json, {
  required List<String> directKeys,
  required List<String> objectKeys,
  required List<String> listKeys,
}) {
  for (final String key in directKeys) {
    final String value = (json[key] ?? '').toString().trim();
    if (value.isNotEmpty) {
      return value;
    }
  }

  for (final String key in objectKeys) {
    final dynamic raw = json[key];
    if (raw is Map) {
      final Map<String, dynamic> object = Map<String, dynamic>.from(raw);
      final String value = (object['url'] ?? object['image_url'] ?? '')
          .toString()
          .trim();
      if (value.isNotEmpty) {
        return value;
      }
    }
  }

  for (final String key in listKeys) {
    final dynamic raw = json[key];
    if (raw is List && raw.isNotEmpty) {
      final dynamic first = raw.first;
      if (first is String) {
        final String value = first.trim();
        if (value.isNotEmpty) {
          return value;
        }
      }
      if (first is Map) {
        final Map<String, dynamic> object = Map<String, dynamic>.from(first);
        final String value = (object['url'] ?? object['image_url'] ?? '')
            .toString()
            .trim();
        if (value.isNotEmpty) {
          return value;
        }
      }
    }
  }

  return '';
}
