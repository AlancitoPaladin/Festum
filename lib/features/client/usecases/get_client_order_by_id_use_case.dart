import 'package:festum/features/client/models/client_order_item.dart';
import 'package:festum/features/client/repositories/client_orders_repository.dart';

class GetClientOrderByIdUseCase {
  const GetClientOrderByIdUseCase(this._repository);

  final ClientOrdersRepository _repository;

  Future<ClientOrderItem?> call(String orderId) {
    return _repository.getOrderById(orderId);
  }
}
