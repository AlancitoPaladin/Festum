import 'package:festum/features/client/models/client_cart_item.dart';

class ClientCartItemDto {
  const ClientCartItemDto({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unitPriceCents,
  });

  final String id;
  final String name;
  final int quantity;
  final int unitPriceCents;

  factory ClientCartItemDto.fromJson(Map<String, dynamic> json) {
    return ClientCartItemDto(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      unitPriceCents: (json['unit_price_cents'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'quantity': quantity,
      'unit_price_cents': unitPriceCents,
    };
  }

  ClientCartItem toDomain() {
    return ClientCartItem(
      id: id,
      name: name,
      quantity: quantity,
      unitPriceCents: unitPriceCents,
    );
  }

  factory ClientCartItemDto.fromDomain(ClientCartItem domain) {
    return ClientCartItemDto(
      id: domain.id,
      name: domain.name,
      quantity: domain.quantity,
      unitPriceCents: domain.unitPriceCents,
    );
  }
}
