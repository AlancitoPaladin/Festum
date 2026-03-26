import 'package:festum/core/network/image_json_resolver.dart';

class ServiceProduct {
  const ServiceProduct({
    required this.id,
    required this.serviceId,
    required this.name,
    required this.price,
    this.detail,
    this.imageUrl = '',
  });

  final String id;
  final String serviceId;
  final String name;
  final double price;
  final String? detail;
  final String imageUrl;

  factory ServiceProduct.fromJson(Map<String, dynamic> json) {
    final dynamic rawPrice = json['price'];
    final double parsedPrice = rawPrice is num
        ? rawPrice.toDouble()
        : double.tryParse(rawPrice?.toString() ?? '') ?? 0;

    return ServiceProduct(
      id: (json['id'] ?? '').toString(),
      serviceId: (json['service_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      price: parsedPrice,
      detail: (json['description'] ?? '').toString(),
      imageUrl: resolveImageUrlFromJson(
        json,
        directKeys: const <String>['main_image_url', 'image_url', 'url'],
        objectKeys: const <String>['main_image', 'image'],
        listKeys: const <String>['images', 'image_urls'],
      ),
    );
  }
}

class ProviderServiceProductsResponse {
  const ProviderServiceProductsResponse({
    required this.items,
    required this.total,
  });

  final List<ServiceProduct> items;
  final int total;

  factory ProviderServiceProductsResponse.fromJson(Map<String, dynamic> json) {
    final List<ServiceProduct> items =
        ((json['items'] as List<dynamic>? ?? <dynamic>[])
            .whereType<Map<dynamic, dynamic>>()
            .map(
              (Map<dynamic, dynamic> item) =>
                  ServiceProduct.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList());

    final dynamic rawTotal = json['total'];
    final int total = rawTotal is num
        ? rawTotal.toInt()
        : int.tryParse(rawTotal?.toString() ?? '') ?? items.length;

    return ProviderServiceProductsResponse(items: items, total: total);
  }
}
