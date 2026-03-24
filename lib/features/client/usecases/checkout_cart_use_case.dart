import 'package:festum/features/client/models/client_order_item.dart';
import 'package:festum/features/client/repositories/client_cart_repository.dart';
import 'package:festum/features/client/repositories/client_orders_repository.dart';

class CheckoutCartUseCase {
  const CheckoutCartUseCase(this._cartRepository, this._ordersRepository);

  final ClientCartRepository _cartRepository;
  final ClientOrdersRepository _ordersRepository;

  Future<ClientOrderItem?> call() async {
    final cartItems = await _cartRepository.getCartItems();
    if (cartItems.isEmpty) {
      return null;
    }

    final int subtotal = cartItems.fold<int>(
      0,
      (int sum, item) => sum + item.unitPriceCents,
    );
    final int serviceFee = (subtotal * 0.05).round();
    final int tax = ((subtotal + serviceFee) * 0.16).round();
    final int total = subtotal + serviceFee + tax;

    final String title;
    if (cartItems.length == 1) {
      title = cartItems.first.name;
    } else {
      title = '${cartItems.first.name} +${cartItems.length - 1} servicios';
    }

    final ClientOrderItem created = await _ordersRepository.createOrder(
      title: title,
      status: ClientOrderStatus.pendingPayment,
      totalLabel: _formatCurrency(total),
    );

    await _cartRepository.clear();
    return created;
  }

  String _formatCurrency(int cents) {
    final int pesos = (cents / 100).round();
    final String raw = pesos.toString();
    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < raw.length; i++) {
      final int position = raw.length - i;
      buffer.write(raw[i]);
      if (position > 1 && position % 3 == 1) {
        buffer.write(',');
      }
    }
    return '\$${buffer.toString()} MXN';
  }
}
