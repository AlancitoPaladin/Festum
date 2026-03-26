import 'package:festum/features/client/models/client_cart_item.dart';
import 'package:festum/features/client/repositories/client_cart_repository.dart';

class MockClientCartRepository implements ClientCartRepository {
  final List<ClientCartItem> _items = <ClientCartItem>[
    const ClientCartItem(
      id: 'hall-aurora',
      name: 'Salón Aurora',
      quantity: 1,
      unitPriceCents: 4120000,
    ),
    const ClientCartItem(
      id: 'furn-led',
      name: 'Pista y Periqueras LED',
      quantity: 1,
      unitPriceCents: 1460000,
    ),
    const ClientCartItem(
      id: 'banq-sweet',
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
  Future<bool> containsService(String serviceId) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return _items.any((ClientCartItem item) => item.id == serviceId);
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
    await Future<void>.delayed(const Duration(milliseconds: 160));
    if (_items.any((ClientCartItem item) => item.id == serviceId)) {
      return false;
    }
    _items.add(
      ClientCartItem(
        id: serviceId,
        name: name,
        quantity: 1,
        unitPriceCents: unitPriceCents,
        serviceName: name,
        productId: productId,
        productName: productName,
        selectedProductIds: selectedProductIds ?? const <String>[],
      ),
    );
    return true;
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
  Future<void> restoreItem({
    required ClientCartItem item,
    required int index,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    if (_items.any((ClientCartItem current) => current.id == item.id)) {
      return;
    }
    final int safeIndex = index.clamp(0, _items.length);
    _items.insert(
      safeIndex,
      ClientCartItem(
        id: item.id,
        name: item.name,
        quantity: 1,
        unitPriceCents: item.unitPriceCents,
        serviceName: item.serviceName,
        productId: item.productId,
        productName: item.productName,
        selectedProductIds: item.selectedProductIds,
      ),
    );
  }

  @override
  Future<void> clear() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    _items.clear();
  }
}
