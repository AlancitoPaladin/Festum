import 'package:festum/features/provider/models/booking.dart';
import 'package:festum/features/provider/models/service_category.dart';
import 'package:festum/core/network/image_json_resolver.dart';

typedef ReservationBookingSummary = Booking;

class ProductReservationSummary {
  const ProductReservationSummary({
    required this.id,
    required this.serviceId,
    required this.serviceName,
    required this.productName,
    required this.category,
    required this.imageUrl,
    required this.nextBooking,
    required this.reservationsCount,
  });

  final String id;
  final String serviceId;
  final String serviceName;
  final String productName;
  final ServiceCategory category;
  final String imageUrl;
  final Booking? nextBooking;
  final int reservationsCount;

  factory ProductReservationSummary.fromJson(Map<String, dynamic> json) {
    return ProductReservationSummary(
      id: (json['id'] ?? '').toString(),
      serviceId: (json['service_id'] ?? '').toString(),
      serviceName: ((json['service_name'] ?? json['service_title']) ?? '')
          .toString(),
      productName: ((json['product_name'] ?? json['name']) ?? '').toString(),
      category: ServiceCategory.fromProviderApiValue(
        (json['category'] ?? '').toString(),
      ),
      imageUrl: resolveImageUrlForUseCaseFromJson(
        json,
        useCase: ResolvedImageUseCase.list,
        directKeys: const <String>['image_url', 'main_image_url'],
        objectKeys: const <String>['image', 'main_image'],
        listKeys: const <String>['images', 'image_urls'],
      ),
      nextBooking: json['next_booking'] is Map<String, dynamic>
          ? Booking.fromJson(
              Map<String, dynamic>.from(json['next_booking'] as Map),
            )
          : null,
      reservationsCount: _toInt(
        json['reservations_count'] ??
            json['bookings_count'] ??
            json['reservations'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'service_id': serviceId,
      'service_name': serviceName,
      'product_name': productName,
      'category': category.name,
      'image_url': imageUrl,
      'next_booking': nextBooking?.toJson(),
      'reservations_count': reservationsCount,
    };
  }

  String get resolvedServiceName {
    final String explicit = serviceName.trim();
    if (explicit.isNotEmpty) {
      return explicit;
    }
    return productName.trim().isEmpty ? 'Servicio' : productName;
  }

  ProductReservationSummary copyWith({
    String? id,
    String? serviceId,
    String? serviceName,
    String? productName,
    ServiceCategory? category,
    String? imageUrl,
    Booking? nextBooking,
    int? reservationsCount,
  }) {
    return ProductReservationSummary(
      id: id ?? this.id,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      productName: productName ?? this.productName,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      nextBooking: nextBooking ?? this.nextBooking,
      reservationsCount: reservationsCount ?? this.reservationsCount,
    );
  }
}

class ProductReservationsResponse {
  const ProductReservationsResponse({required this.items, required this.total});

  final List<ProductReservationSummary> items;
  final int total;

  factory ProductReservationsResponse.fromJson(Map<String, dynamic> json) {
    return ProductReservationsResponse(
      items: ((json['items'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map<dynamic, dynamic>>()
          .map(
            (Map<dynamic, dynamic> item) => ProductReservationSummary.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList()),
      total: _toInt(json['total']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'items': items
          .map((ProductReservationSummary item) => item.toJson())
          .toList(),
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
