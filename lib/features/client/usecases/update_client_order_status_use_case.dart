import 'package:festum/features/client/models/client_order_item.dart';
import 'package:festum/features/client/repositories/client_orders_repository.dart';

class UpdateClientOrderStatusUseCase {
  const UpdateClientOrderStatusUseCase(this._repository);

  final ClientOrdersRepository _repository;

  Future<void> call({
    required String orderId,
    required ClientOrderStatus status,
  }) {
    return _repository.updateOrderStatus(orderId: orderId, status: status);
  }
}
