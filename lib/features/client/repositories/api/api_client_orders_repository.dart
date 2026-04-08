import 'package:dio/dio.dart';
import 'package:festum/core/network/api_client.dart';
import 'package:festum/features/client/models/client_cart_item.dart';
import 'package:festum/features/client/data/dto/client_order_item_dto.dart';
import 'package:festum/features/client/models/client_order_item.dart';
import 'package:festum/features/client/repositories/client_orders_repository.dart';
import 'package:festum/features/client/services/client_query_cache_service.dart';

class ApiClientOrdersRepository implements ClientOrdersRepository {
  ApiClientOrdersRepository(this._apiClient, this._cache);

  final ApiClient _apiClient;
  final ClientQueryCacheService _cache;

  static const String _ordersCacheKey = 'client_orders/items';
  static const String _ordersWithItemsCacheKey = 'client_orders/items_full';
  static const String _activeServiceIdsCacheKey =
      'client_orders/active_service_ids';
  static const String _cartItemsCacheKey = 'client_cart/items';
  static const Duration _ordersTtl = Duration(seconds: 4);
  static const Duration _orderDetailTtl = Duration(seconds: 8);
  static const Duration _activeServiceIdsTtl = Duration(seconds: 8);

  @override
  Future<List<ClientOrderItem>> getOrders({bool includeItems = false}) async {
    try {
      return _cache.getOrLoad<List<ClientOrderItem>>(
        key: includeItems ? _ordersWithItemsCacheKey : _ordersCacheKey,
        ttl: _ordersTtl,
        loader: () async {
          final List<Map<String, dynamic>> payload = await _apiClient
              .getClientOrders(includeItems: includeItems);
          return payload
              .map(ClientOrderItemDto.fromJson)
              .map((ClientOrderItemDto dto) => dto.toDomain())
              .toList();
        },
      );
    } on DioException {
      rethrow;
    } on FormatException {
      rethrow;
    }
  }

  @override
  Future<ClientOrderItem?> getOrderById(String orderId) async {
    final String normalizedOrderId = orderId.trim();
    if (normalizedOrderId.isEmpty) {
      return null;
    }
    return _cache.getOrLoad<ClientOrderItem?>(
      key: 'client_orders/detail/$normalizedOrderId',
      ttl: _orderDetailTtl,
      loader: () async {
        final Map<String, dynamic>? payload = await _apiClient
            .getClientOrderById(orderId: normalizedOrderId);
        if (payload == null) {
          return null;
        }
        return ClientOrderItemDto.fromJson(payload).toDomain();
      },
    );
  }

  @override
  Future<Set<String>> getActiveServiceIds() {
    return _cache.getOrLoad<Set<String>>(
      key: _activeServiceIdsCacheKey,
      ttl: _activeServiceIdsTtl,
      loader: () => _apiClient.getClientActiveOrderServiceIds(),
    );
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
    _cache.invalidate(_ordersCacheKey);
    _cache.invalidate(_ordersWithItemsCacheKey);
    _cache.invalidate(_activeServiceIdsCacheKey);
    return ClientOrderItemDto.fromJson(payload).toDomain();
  }

  @override
  Future<ClientOrderItem> checkoutCart() async {
    final Map<String, dynamic> payload = await _apiClient.checkoutClientOrder();
    _cache.invalidate(_ordersCacheKey);
    _cache.invalidate(_ordersWithItemsCacheKey);
    _cache.invalidate(_activeServiceIdsCacheKey);
    _cache.invalidate(_cartItemsCacheKey);
    _cache.invalidatePrefix('client_orders/detail/');
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
      _cache.invalidate(_ordersCacheKey);
      _cache.invalidate(_ordersWithItemsCacheKey);
      _cache.invalidate(_activeServiceIdsCacheKey);
      _cache.invalidate(_cartItemsCacheKey);
      _cache.invalidatePrefix('client_orders/detail/');
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
  }) async {
    await _apiClient.updateClientOrderStatus(
      orderId: orderId,
      status: status.apiValue,
    );
    _cache.invalidate(_ordersCacheKey);
    _cache.invalidate(_ordersWithItemsCacheKey);
    _cache.invalidate(_activeServiceIdsCacheKey);
    _cache.invalidatePrefix('client_orders/detail/');
  }
}
