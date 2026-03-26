import 'package:festum/features/client/models/client_order_item.dart';

class ClientOrderItemDto {
  const ClientOrderItemDto({
    required this.id,
    required this.title,
    required this.status,
    required this.totalLabel,
    this.totalCents,
    this.subtotalCents,
    this.serviceFeeCents,
    this.taxCents,
    this.currency,
    this.items = const <ClientOrderLineItemDto>[],
  });

  final String id;
  final String title;
  final String status;
  final String totalLabel;
  final int? totalCents;
  final int? subtotalCents;
  final int? serviceFeeCents;
  final int? taxCents;
  final String? currency;
  final List<ClientOrderLineItemDto> items;

  factory ClientOrderItemDto.fromJson(Map<String, dynamic> json) {
    final String rawTitle = _readFirstString(json, const <String>[
      'title',
      'name',
      'service_name',
    ]);
    final String rawStatus = _readFirstString(json, const <String>[
      'status',
      'request_status',
    ]);
    final String rawTotalLabel = _resolveTotalLabel(json);

    final int resolvedTotalCents = _readInt(json, const <String>[
      'total_cents',
      'total_amount_cents',
      'total_price_cents',
      'amount_cents',
    ]);
    final int resolvedSubtotalCents = _readInt(json, const <String>[
      'subtotal_cents',
    ]);
    final int resolvedServiceFeeCents = _readInt(json, const <String>[
      'service_fee_cents',
      'fee_cents',
    ]);
    final int resolvedTaxCents = _readInt(json, const <String>['tax_cents']);
    final String resolvedCurrency = _readFirstString(json, const <String>[
      'currency',
    ]);
    final List<ClientOrderLineItemDto> resolvedItems = _readItems(json);

    return ClientOrderItemDto(
      id: _readFirstString(json, const <String>['id', 'order_id']),
      title: rawTitle,
      status: rawStatus.isEmpty ? 'pending_payment' : rawStatus,
      totalLabel: rawTotalLabel,
      totalCents: resolvedTotalCents > 0 ? resolvedTotalCents : null,
      subtotalCents: resolvedSubtotalCents > 0 ? resolvedSubtotalCents : null,
      serviceFeeCents: resolvedServiceFeeCents > 0
          ? resolvedServiceFeeCents
          : null,
      taxCents: resolvedTaxCents > 0 ? resolvedTaxCents : null,
      currency: resolvedCurrency.isEmpty ? null : resolvedCurrency,
      items: resolvedItems,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'status': status,
      'total_label': totalLabel,
      if (totalCents != null) 'total_cents': totalCents,
      if (subtotalCents != null) 'subtotal_cents': subtotalCents,
      if (serviceFeeCents != null) 'service_fee_cents': serviceFeeCents,
      if (taxCents != null) 'tax_cents': taxCents,
      if (currency != null) 'currency': currency,
      if (items.isNotEmpty)
        'items': items
            .map((ClientOrderLineItemDto item) => item.toJson())
            .toList(),
    };
  }

  ClientOrderItem toDomain() {
    return ClientOrderItem(
      id: id,
      title: title,
      status: ClientOrderStatusApi.fromApi(status),
      totalLabel: totalLabel,
      totalCents: totalCents,
      subtotalCents: subtotalCents,
      serviceFeeCents: serviceFeeCents,
      taxCents: taxCents,
      currency: currency,
      items: items
          .map((ClientOrderLineItemDto item) => item.toDomain())
          .toList(),
    );
  }

  factory ClientOrderItemDto.fromDomain(ClientOrderItem domain) {
    return ClientOrderItemDto(
      id: domain.id,
      title: domain.title,
      status: domain.status.apiValue,
      totalLabel: domain.totalLabel,
      totalCents: domain.totalCents,
      subtotalCents: domain.subtotalCents,
      serviceFeeCents: domain.serviceFeeCents,
      taxCents: domain.taxCents,
      currency: domain.currency,
      items: domain.items
          .map(
            (ClientOrderLineItem item) =>
                ClientOrderLineItemDto.fromDomain(item),
          )
          .toList(),
    );
  }

  static List<ClientOrderLineItemDto> _readItems(Map<String, dynamic> json) {
    final dynamic raw = json['items'];
    if (raw is! List) {
      return const <ClientOrderLineItemDto>[];
    }
    return raw.whereType<Map>().map((Map<dynamic, dynamic> value) {
      return ClientOrderLineItemDto.fromJson(Map<String, dynamic>.from(value));
    }).toList();
  }

  static String _readFirstString(Map<String, dynamic> json, List<String> keys) {
    for (final String key in keys) {
      final String value = (json[key] ?? '').toString().trim();
      if (value.isNotEmpty) {
        return value;
      }
    }
    return '';
  }

  static int _readInt(Map<String, dynamic> json, List<String> keys) {
    for (final String key in keys) {
      final dynamic value = json[key];
      if (value == null) {
        continue;
      }
      if (value is int) {
        return value;
      }
      if (value is num) {
        return value.toInt();
      }
      final int? parsed = int.tryParse(value.toString().trim());
      if (parsed != null) {
        return parsed;
      }
    }
    return 0;
  }

  static double _readDouble(Map<String, dynamic> json, List<String> keys) {
    for (final String key in keys) {
      final dynamic value = json[key];
      if (value == null) {
        continue;
      }
      if (value is num) {
        return value.toDouble();
      }
      final String raw = value.toString().trim().replaceAll(',', '.');
      final double? parsed = double.tryParse(raw);
      if (parsed != null) {
        return parsed;
      }
    }
    return 0;
  }

  static String _resolveTotalLabel(Map<String, dynamic> json) {
    final String explicit = _readFirstString(json, const <String>[
      'total_label',
      'totalLabel',
    ]);
    if (explicit.isNotEmpty && !_looksZeroTotalLabel(explicit)) {
      return explicit;
    }

    final int cents = _readInt(json, const <String>[
      'total_cents',
      'total_amount_cents',
      'total_price_cents',
      'amount_cents',
    ]);
    if (cents > 0) {
      return _formatCurrency(cents);
    }

    final double amount = _readDouble(json, const <String>[
      'total_amount',
      'total_price',
      'total',
    ]);
    if (amount > 0) {
      return _formatCurrency((amount * 100).round());
    }

    return explicit.isNotEmpty ? explicit : '-';
  }

  static bool _looksZeroTotalLabel(String value) {
    final String normalized = value.trim().toLowerCase();
    if (normalized.isEmpty) {
      return true;
    }
    return normalized == '-' ||
        normalized == '0' ||
        normalized == '\$0' ||
        normalized == '\$0 mxn' ||
        normalized == '\$0.00 mxn' ||
        normalized == '0 mxn';
  }

  static String _formatCurrency(int cents) {
    final int pesos = (cents / 100).round();
    final String raw = pesos.toString();
    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < raw.length; i++) {
      final int position = raw.length - i;
      buffer.write(raw[i]);
      if (position > 1 && position % 3 == 1) {
        buffer.write(',');
      }
    }
    return '\$${buffer.toString()} MXN';
  }
}

class ClientOrderLineItemDto {
  const ClientOrderLineItemDto({
    required this.serviceId,
    required this.serviceName,
    this.productId,
    this.productName,
    this.unitPriceCents,
    this.totalItemCents,
    this.selectedProductIds = const <String>[],
    this.selectedProducts = const <ClientOrderSelectedProductDto>[],
  });

  final String serviceId;
  final String serviceName;
  final String? productId;
  final String? productName;
  final int? unitPriceCents;
  final int? totalItemCents;
  final List<String> selectedProductIds;
  final List<ClientOrderSelectedProductDto> selectedProducts;

  factory ClientOrderLineItemDto.fromJson(Map<String, dynamic> json) {
    final List<ClientOrderSelectedProductDto> selectedProducts =
        ((json['selected_products_snapshot'] as List<dynamic>?) ?? <dynamic>[])
            .whereType<Map>()
            .map(
              (Map<dynamic, dynamic> value) =>
                  ClientOrderSelectedProductDto.fromJson(
                    Map<String, dynamic>.from(value),
                  ),
            )
            .toList();

    return ClientOrderLineItemDto(
      serviceId: (json['service_id'] ?? '').toString(),
      serviceName: (json['service_name'] ?? json['name'] ?? '').toString(),
      productId: (json['product_id'] ?? '').toString().trim().isEmpty
          ? null
          : (json['product_id'] ?? '').toString(),
      productName: (json['product_name'] ?? '').toString().trim().isEmpty
          ? null
          : (json['product_name'] ?? '').toString(),
      unitPriceCents: _toIntOrNull(json['unit_price_cents']),
      totalItemCents: _toIntOrNull(json['total_item_cents']),
      selectedProductIds:
          ((json['selected_product_ids'] as List<dynamic>?) ?? <dynamic>[])
              .map((dynamic value) => value.toString().trim())
              .where((String value) => value.isNotEmpty)
              .toList(),
      selectedProducts: selectedProducts,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'service_id': serviceId,
      'service_name': serviceName,
      if (productId != null) 'product_id': productId,
      if (productName != null) 'product_name': productName,
      if (unitPriceCents != null) 'unit_price_cents': unitPriceCents,
      if (totalItemCents != null) 'total_item_cents': totalItemCents,
      if (selectedProductIds.isNotEmpty)
        'selected_product_ids': selectedProductIds,
      if (selectedProducts.isNotEmpty)
        'selected_products_snapshot': selectedProducts
            .map((ClientOrderSelectedProductDto item) => item.toJson())
            .toList(),
    };
  }

  ClientOrderLineItem toDomain() {
    return ClientOrderLineItem(
      serviceId: serviceId,
      serviceName: serviceName,
      productId: productId,
      productName: productName,
      unitPriceCents: unitPriceCents,
      totalItemCents: totalItemCents,
      selectedProductIds: selectedProductIds,
      selectedProducts: selectedProducts
          .map((ClientOrderSelectedProductDto item) => item.toDomain())
          .toList(),
    );
  }

  factory ClientOrderLineItemDto.fromDomain(ClientOrderLineItem domain) {
    return ClientOrderLineItemDto(
      serviceId: domain.serviceId,
      serviceName: domain.serviceName,
      productId: domain.productId,
      productName: domain.productName,
      unitPriceCents: domain.unitPriceCents,
      totalItemCents: domain.totalItemCents,
      selectedProductIds: domain.selectedProductIds,
      selectedProducts: domain.selectedProducts
          .map(
            (ClientOrderSelectedProduct item) =>
                ClientOrderSelectedProductDto.fromDomain(item),
          )
          .toList(),
    );
  }

  static int? _toIntOrNull(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value.toString().trim());
  }
}

class ClientOrderSelectedProductDto {
  const ClientOrderSelectedProductDto({
    required this.id,
    required this.name,
    this.unitPriceCents,
  });

  final String id;
  final String name;
  final int? unitPriceCents;

  factory ClientOrderSelectedProductDto.fromJson(Map<String, dynamic> json) {
    return ClientOrderSelectedProductDto(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      unitPriceCents: ClientOrderLineItemDto._toIntOrNull(
        json['unit_price_cents'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      if (unitPriceCents != null) 'unit_price_cents': unitPriceCents,
    };
  }

  ClientOrderSelectedProduct toDomain() {
    return ClientOrderSelectedProduct(
      id: id,
      name: name,
      unitPriceCents: unitPriceCents,
    );
  }

  factory ClientOrderSelectedProductDto.fromDomain(
    ClientOrderSelectedProduct domain,
  ) {
    return ClientOrderSelectedProductDto(
      id: domain.id,
      name: domain.name,
      unitPriceCents: domain.unitPriceCents,
    );
  }
}
