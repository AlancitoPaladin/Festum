import 'package:festum/features/client/models/client_order_item.dart';
import 'package:festum/features/client/models/client_cart_item.dart';
import 'package:festum/features/client/repositories/client_cart_repository.dart';
import 'package:festum/features/client/repositories/client_orders_repository.dart';

class CheckoutCartUseCase {
  const CheckoutCartUseCase(this._cartRepository, this._ordersRepository);

  final ClientCartRepository _cartRepository;
  final ClientOrdersRepository _ordersRepository;

  Future<ClientOrderItem?> call({
    required DateTime eventDate,
    String? notes,
  }) async {
    final cartItems = await _cartRepository.getCartItems();
    if (cartItems.isEmpty) {
      return null;
    }

    final ClientOrderItem created = await _ordersRepository.submitOrderRequest(
      items: cartItems,
      eventDate: eventDate,
      notes: notes,
    );
    final String fallbackTitle = cartItems.length == 1
        ? cartItems.first.resolvedServiceName
        : '${cartItems.first.resolvedServiceName} +${cartItems.length - 1} servicios';
    final String fallbackTotalLabel = _estimateTotalLabel(cartItems);
    final ClientOrderItem normalized = created.copyWith(
      title: created.title.trim().isEmpty ? fallbackTitle : created.title,
      totalLabel: _looksInvalidTotalLabel(created.totalLabel)
          ? fallbackTotalLabel
          : created.totalLabel,
    );

    await _cartRepository.clear();
    return normalized;
  }

  String _estimateTotalLabel(List<ClientCartItem> cartItems) {
    final int subtotal = cartItems.fold<int>(
      0,
      (int sum, ClientCartItem item) =>
          sum + item.unitPriceCents * item.quantity,
    );
    final int serviceFee = (subtotal * 0.05).round();
    final int tax = ((subtotal + serviceFee) * 0.16).round();
    final int total = subtotal + serviceFee + tax;

    final int pesos = (total / 100).round();
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

  bool _looksInvalidTotalLabel(String value) {
    final String normalized = value.trim().toLowerCase();
    return normalized.isEmpty ||
        normalized == '-' ||
        normalized == '0' ||
        normalized == '\$0' ||
        normalized == '\$0 mxn' ||
        normalized == '\$0.00 mxn' ||
        normalized == '0 mxn';
  }
}
