import 'package:festum/features/client/models/client_cart_item.dart';
import 'package:festum/features/client/repositories/client_cart_repository.dart';

class MockClientCartRepository implements ClientCartRepository {
  final List<ClientCartItem> _items = <ClientCartItem>[
    const ClientCartItem(
      id: 'cart-1',
      name: 'Salón Aurora',
      quantity: 1,
      unitPriceCents: 4120000,
    ),
    const ClientCartItem(
      id: 'cart-2',
      name: 'Pista y Periqueras LED',
      quantity: 1,
      unitPriceCents: 1460000,
    ),
    const ClientCartItem(
      id: 'cart-3',
      name: 'Mesa Dulce y Postres',
      quantity: 1,
      unitPriceCents: 850000,
    ),
  ];

  @override
  Future<List<ClientCartItem>> getCartItems() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return List<ClientCartItem>.from(_items);
  }

  @override
  Future<ClientCartItem?> removeItem(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 140));
    final int index = _items.indexWhere((ClientCartItem item) => item.id == id);
    if (index < 0) {
      return null;
    }
    return _items.removeAt(index);
  }

  @override
  Future<ClientCartItem?> updateQuantity({
    required String id,
    required int quantity,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    final int index = _items.indexWhere((ClientCartItem item) => item.id == id);
    if (index < 0) {
      return null;
    }
    final ClientCartItem current = _items[index];
    final int nextQuantity = quantity < 1 ? 1 : quantity;
    final ClientCartItem updated = ClientCartItem(
      id: current.id,
      name: current.name,
      quantity: nextQuantity,
      unitPriceCents: current.unitPriceCents,
    );
    _items[index] = updated;
    return updated;
  }

  @override
  Future<void> restoreItem({
    required ClientCartItem item,
    required int index,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    final int safeIndex = index.clamp(0, _items.length);
    _items.insert(safeIndex, item);
  }
}
