import 'package:festum/features/client/models/client_cart_item.dart';

class ClientCartItemDto {
  const ClientCartItemDto({
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

  factory ClientCartItemDto.fromJson(Map<String, dynamic> json) {
    return ClientCartItemDto(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      unitPriceCents: (json['unit_price_cents'] as num?)?.toInt() ?? 0,
      serviceName: json['service_name'] as String?,
      productId: json['product_id'] as String?,
      productName: json['product_name'] as String?,
      selectedProductIds:
          (json['selected_product_ids'] as List<dynamic>? ?? <dynamic>[])
              .map((dynamic value) => value.toString().trim())
              .where((String value) => value.isNotEmpty)
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'quantity': quantity,
      'unit_price_cents': unitPriceCents,
      if (serviceName != null) 'service_name': serviceName,
      if (productId != null) 'product_id': productId,
      if (productName != null) 'product_name': productName,
      if (selectedProductIds.isNotEmpty)
        'selected_product_ids': selectedProductIds,
    };
  }

  ClientCartItem toDomain() {
    return ClientCartItem(
      id: id,
      name: name,
      quantity: quantity,
      unitPriceCents: unitPriceCents,
      serviceName: serviceName,
      productId: productId,
      productName: productName,
      selectedProductIds: selectedProductIds,
    );
  }

  factory ClientCartItemDto.fromDomain(ClientCartItem domain) {
    return ClientCartItemDto(
      id: domain.id,
      name: domain.name,
      quantity: domain.quantity,
      unitPriceCents: domain.unitPriceCents,
      serviceName: domain.serviceName,
      productId: domain.productId,
      productName: domain.productName,
      selectedProductIds: domain.selectedProductIds,
    );
  }
}
