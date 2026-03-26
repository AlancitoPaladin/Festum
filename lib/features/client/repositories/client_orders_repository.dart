import 'package:festum/features/client/models/client_order_item.dart';
import 'package:festum/features/client/models/client_cart_item.dart';

abstract class ClientOrdersRepository {
  Future<List<ClientOrderItem>> getOrders();

  Future<ClientOrderItem> createOrder({
    required String title,
    required ClientOrderStatus status,
    required String totalLabel,
  });

  Future<ClientOrderItem> checkoutCart();

  Future<ClientOrderItem> submitOrderRequest({
    required List<ClientCartItem> items,
    required DateTime eventDate,
    String? notes,
  });

  Future<void> updateOrderStatus({
    required String orderId,
    required ClientOrderStatus status,
  });
}
