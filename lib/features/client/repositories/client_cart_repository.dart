import 'package:festum/features/client/models/client_cart_item.dart';

abstract class ClientCartRepository {
  Future<List<ClientCartItem>> getCartItems();

  Future<bool> containsService(String serviceId);

  Future<bool> addService({
    required String serviceId,
    required String name,
    required int unitPriceCents,
    String? productId,
    String? productName,
    List<String>? selectedProductIds,
  });

  Future<ClientCartItem?> removeItem(String id);

  Future<void> restoreItem({required ClientCartItem item, required int index});

  Future<void> clear();
}
