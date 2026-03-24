import 'package:dio/dio.dart';
import 'package:festum/core/network/api_client.dart';
import 'package:festum/features/client/data/dto/client_cart_item_dto.dart';
import 'package:festum/features/client/models/client_cart_item.dart';
import 'package:festum/features/client/repositories/client_cart_repository.dart';

class ApiClientCartRepository implements ClientCartRepository {
  ApiClientCartRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<ClientCartItem>> getCartItems() async {
    try {
      final List<Map<String, dynamic>> payload = await _apiClient
          .getClientCartItems();
      return payload
          .map(ClientCartItemDto.fromJson)
          .map((ClientCartItemDto dto) => dto.toDomain())
          .toList();
    } on DioException {
      rethrow;
    } on FormatException {
      rethrow;
    }
  }

  @override
  Future<bool> containsService(String serviceId) {
    return _apiClient.containsServiceInClientCart(serviceId: serviceId);
  }

  @override
  Future<bool> addService({
    required String serviceId,
    required String name,
    required int unitPriceCents,
  }) async {
    try {
      return await _apiClient.addServiceToClientCart(
        serviceId: serviceId,
        name: name,
        unitPriceCents: unitPriceCents,
      );
    } on DioException catch (error) {
      // Duplicate service in cart should be a controlled UI case, not a hard failure.
      if (error.response?.statusCode == 409) {
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
    if (payload == null) {
      return null;
    }
    return ClientCartItemDto.fromJson(payload).toDomain();
  }

  @override
  Future<void> restoreItem({required ClientCartItem item, required int index}) {
    return _apiClient.restoreClientCartItem(
      item: ClientCartItemDto.fromDomain(item).toJson(),
      index: index,
    );
  }

  @override
  Future<void> clear() {
    return _apiClient.clearClientCart();
  }
}
