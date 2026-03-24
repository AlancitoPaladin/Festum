import 'package:festum/features/client/models/client_order_item.dart';
import 'package:festum/features/client/repositories/client_orders_repository.dart';

class MockClientOrdersRepository implements ClientOrdersRepository {
  final List<ClientOrderItem> _orders = <ClientOrderItem>[
    const ClientOrderItem(
      id: 'FST-2109',
      title: 'Banquete Signature',
      status: ClientOrderStatus.inProgress,
      totalLabel: '\$18,000 MXN',
    ),
    const ClientOrderItem(
      id: 'FST-2110',
      title: 'Salón Norte Imperial',
      status: ClientOrderStatus.confirmed,
      totalLabel: '\$22,200 MXN',
    ),
    const ClientOrderItem(
      id: 'FST-2114',
      title: 'Set Lounge Moderno',
      status: ClientOrderStatus.pendingPayment,
      totalLabel: '\$15,300 MXN',
    ),
  ];

  @override
  Future<List<ClientOrderItem>> getOrders() async {
    await Future<void>.delayed(const Duration(milliseconds: 320));
    return List<ClientOrderItem>.from(_orders);
  }

  @override
  Future<ClientOrderItem> createOrder({
    required String title,
    required ClientOrderStatus status,
    required String totalLabel,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    final int sequence = 2200 + _orders.length + 1;
    final ClientOrderItem created = ClientOrderItem(
      id: 'FST-$sequence',
      title: title,
      status: status,
      totalLabel: totalLabel,
    );
    _orders.insert(0, created);
    return created;
  }

  @override
  Future<void> updateOrderStatus({
    required String orderId,
    required ClientOrderStatus status,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    final int index = _orders.indexWhere(
      (ClientOrderItem item) => item.id == orderId,
    );
    if (index == -1) {
      return;
    }
    _orders[index] = _orders[index].copyWith(status: status);
  }
}
