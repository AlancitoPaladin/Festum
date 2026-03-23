import 'package:dio/dio.dart';
import 'package:festum/core/network/api_client.dart';
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
