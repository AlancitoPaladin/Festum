import 'package:festum/features/client/models/client_order_item.dart';

abstract class ClientOrdersRepository {
  Future<List<ClientOrderItem>> getOrders();
}
