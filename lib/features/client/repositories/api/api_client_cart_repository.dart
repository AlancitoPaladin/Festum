import 'package:dio/dio.dart';
import 'package:festum/core/network/api_client.dart';
import 'package:festum/features/client/data/dto/client_cart_item_dto.dart';
import 'package:festum/features/client/models/client_cart_item.dart';
import 'package:festum/features/client/repositories/client_cart_repository.dart';
import 'package:festum/features/client/services/client_query_cache_service.dart';

class ApiClientCartRepository implements ClientCartRepository {
  ApiClientCartRepository(this._apiClient, this._cache);

  final ApiClient _apiClient;
  final ClientQueryCacheService _cache;

  static const String _cartItemsCacheKey = 'client_cart/items';
  static const Duration _cartTtl = Duration(seconds: 4);

  @override
  Future<List<ClientCartItem>> getCartItems() async {
    try {
      return _cache.getOrLoad<List<ClientCartItem>>(
        key: _cartItemsCacheKey,
        ttl: _cartTtl,
        loader: () async {
          final List<Map<String, dynamic>> payload = await _apiClient
              .getClientCartItems();
          return payload
              .map(ClientCartItemDto.fromJson)
              .map((ClientCartItemDto dto) => dto.toDomain())
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
  Future<bool> containsService(String serviceId) async {
    final List<ClientCartItem>? cached = _cache
        .getIfFresh<List<ClientCartItem>>(_cartItemsCacheKey);
    if (cached != null) {
      return cached.any((ClientCartItem item) => item.id == serviceId);
    }
    return _apiClient.containsServiceInClientCart(serviceId: serviceId);
  }

  @override
  Future<bool> addService({
    required String serviceId,
    required String name,
    required int unitPriceCents,
    String? productId,
    String? productName,
    List<String>? selectedProductIds,
  }) async {
    try {
      final bool added = await _apiClient.addServiceToClientCart(
        serviceId: serviceId,
        name: name,
        unitPriceCents: unitPriceCents,
        productId: productId,
        productName: productName,
        selectedProductIds: selectedProductIds,
      );
      _cache.invalidate(_cartItemsCacheKey);
      return added;
    } on DioException catch (error) {
      if (error.response?.statusCode == 422 &&
          selectedProductIds != null &&
          selectedProductIds.isNotEmpty) {
        final bool added = await _apiClient.addServiceToClientCart(
          serviceId: serviceId,
          name: name,
          unitPriceCents: unitPriceCents,
          productId: productId,
          productName: productName,
        );
        _cache.invalidate(_cartItemsCacheKey);
        return added;
      }
      // Duplicate service in cart should be a controlled UI case, not a hard failure.
      if (error.response?.statusCode == 409) {
        _cache.invalidate(_cartItemsCacheKey);
        return false;
      }
      rethrow;
    }
  }

  @override
  Future<ClientCartItem?> removeItem(String id) async {
    final Map<String, dynamic>? payload = await _apiClient.removeClientCartItem(
      id: id,
    );
    _cache.invalidate(_cartItemsCacheKey);
    if (payload == null) {
      return null;
    }
    return ClientCartItemDto.fromJson(payload).toDomain();
  }

  @override
  Future<void> restoreItem({required ClientCartItem item, required int index}) {
    _cache.invalidate(_cartItemsCacheKey);
    return _apiClient.restoreClientCartItem(
      item: ClientCartItemDto.fromDomain(item).toJson(),
      index: index,
    );
  }

  @override
  Future<void> clear() {
    _cache.invalidate(_cartItemsCacheKey);
    return _apiClient.clearClientCart();
  }
}
