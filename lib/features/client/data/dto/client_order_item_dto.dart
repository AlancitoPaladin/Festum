import 'package:festum/features/client/models/client_order_item.dart';

class ClientOrderItemDto {
  const ClientOrderItemDto({
    required this.id,
    required this.title,
    required this.status,
    required this.totalLabel,
  });

  final String id;
  final String title;
  final String status;
  final String totalLabel;

  factory ClientOrderItemDto.fromJson(Map<String, dynamic> json) {
    return ClientOrderItemDto(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      status: json['status'] as String? ?? 'pending_payment',
      totalLabel: json['total_label'] as String? ?? '-',
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'status': status,
      'total_label': totalLabel,
    };
  }

  ClientOrderItem toDomain() {
    return ClientOrderItem(
      id: id,
      title: title,
      status: ClientOrderStatusApi.fromApi(status),
      totalLabel: totalLabel,
    );
  }

  factory ClientOrderItemDto.fromDomain(ClientOrderItem domain) {
    return ClientOrderItemDto(
      id: domain.id,
      title: domain.title,
      status: domain.status.apiValue,
      totalLabel: domain.totalLabel,
    );
  }
}
