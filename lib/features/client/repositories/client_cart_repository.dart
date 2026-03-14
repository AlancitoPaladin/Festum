import 'package:festum/features/client/models/client_cart_item.dart';

abstract class ClientCartRepository {
  Future<List<ClientCartItem>> getCartItems();

  Future<ClientCartItem?> removeItem(String id);

  Future<ClientCartItem?> updateQuantity({
    required String id,
    required int quantity,
  });

  Future<void> restoreItem({required ClientCartItem item, required int index});
}
