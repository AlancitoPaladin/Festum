import 'package:festum/features/client/models/client_order_item.dart';
import 'package:festum/features/client/repositories/client_orders_repository.dart';

class GetClientOrdersUseCase {
  const GetClientOrdersUseCase(this._repository);

  final ClientOrdersRepository _repository;

  Future<List<ClientOrderItem>> call({bool includeItems = false}) {
    return _repository.getOrders(includeItems: includeItems);
  }
}
