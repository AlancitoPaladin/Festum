import 'package:dio/dio.dart';
import 'package:festum/core/network/api_client.dart';
import 'package:festum/features/client/models/client_cart_item.dart';
import 'package:festum/features/client/data/dto/client_order_item_dto.dart';
import 'package:festum/features/client/models/client_order_item.dart';
import 'package:festum/features/client/repositories/client_orders_repository.dart';

class ApiClientOrdersRepository implements ClientOrdersRepository {
  ApiClientOrdersRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<ClientOrderItem>> getOrders() async {
    try {
      final List<Map<String, dynamic>> payload = await _apiClient
          .getClientOrders();
      return payload
          .map(ClientOrderItemDto.fromJson)
          .map((ClientOrderItemDto dto) => dto.toDomain())
          .toList();
    } on DioException {
      rethrow;
    } on FormatException {
      rethrow;
    }
  }

  @override
  Future<ClientOrderItem> createOrder({
    required String title,
    required ClientOrderStatus status,
    required String totalLabel,
  }) async {
    final ClientOrderItemDto requestDto = ClientOrderItemDto(
      id: '',
      title: title,
      status: status.apiValue,
      totalLabel: totalLabel,
    );
    final Map<String, dynamic> payload = await _apiClient.createClientOrder(
      payload: requestDto.toJson(),
    );
    return ClientOrderItemDto.fromJson(payload).toDomain();
  }

  @override
  Future<ClientOrderItem> checkoutCart() async {
    final Map<String, dynamic> payload = await _apiClient.checkoutClientOrder();
    final dynamic orderPayload = payload['order'];
    if (orderPayload is Map<String, dynamic>) {
      return ClientOrderItemDto.fromJson(orderPayload).toDomain();
    }
    if (orderPayload is Map) {
      return ClientOrderItemDto.fromJson(
        Map<String, dynamic>.from(orderPayload),
      ).toDomain();
    }
    return ClientOrderItemDto.fromJson(payload).toDomain();
  }

  @override
  Future<ClientOrderItem> submitOrderRequest({
    required List<ClientCartItem> items,
    required DateTime eventDate,
    String? notes,
  }) async {
    final Map<String, dynamic> payload = <String, dynamic>{
      'event_date': eventDate.toIso8601String().split('T').first,
      if ((notes ?? '').trim().isNotEmpty) 'notes': notes!.trim(),
      'items': items
          .map(
            (ClientCartItem item) => <String, dynamic>{
              'service_id': item.id,
              if (item.selectedProductIds.isNotEmpty)
                'selected_product_ids': item.selectedProductIds,
              if (item.productId != null && item.productId!.trim().isNotEmpty)
                'product_id': item.productId,
              if (item.productName != null &&
                  item.productName!.trim().isNotEmpty)
                'product_name': item.productName,
              if (item.serviceName != null &&
                  item.serviceName!.trim().isNotEmpty)
                'service_name': item.serviceName,
            },
          )
          .toList(),
    };

    try {
      final Map<String, dynamic> response = await _apiClient
          .submitClientOrderRequest(payload: payload);
      final dynamic orderPayload = response['order'];
      if (orderPayload is Map<String, dynamic>) {
        return ClientOrderItemDto.fromJson(orderPayload).toDomain();
      }
      if (orderPayload is Map) {
        return ClientOrderItemDto.fromJson(
          Map<String, dynamic>.from(orderPayload),
        ).toDomain();
      }
      return ClientOrderItemDto.fromJson(response).toDomain();
    } on DioException catch (error) {
      final int? status = error.response?.statusCode;
      if (status == 404 || status == 405 || status == 501) {
        return checkoutCart();
      }
      rethrow;
    }
  }

  @override
  Future<void> updateOrderStatus({
    required String orderId,
    required ClientOrderStatus status,
  }) {
    return _apiClient.updateClientOrderStatus(
      orderId: orderId,
      status: status.apiValue,
    );
  }
}
