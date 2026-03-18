import 'package:festum/features/client/models/client_order_item.dart';
import 'package:festum/features/client/repositories/client_orders_repository.dart';

class MockClientOrdersRepository implements ClientOrdersRepository {
  @override
  Future<List<ClientOrderItem>> getOrders() async {
    await Future<void>.delayed(const Duration(milliseconds: 320));
    return const <ClientOrderItem>[
      ClientOrderItem(
        id: 'FST-2109',
        title: 'Banquete Signature',
        status: 'En proceso',
        totalLabel: '\$18,000 MXN',
      ),
      ClientOrderItem(
        id: 'FST-2110',
        title: 'Salón Norte Imperial',
        status: 'Confirmada',
        totalLabel: '\$22,200 MXN',
      ),
      ClientOrderItem(
        id: 'FST-2114',
        title: 'Set Lounge Moderno',
        status: 'Pendiente de pago',
        totalLabel: '\$15,300 MXN',
      ),
    ];
  }
}
