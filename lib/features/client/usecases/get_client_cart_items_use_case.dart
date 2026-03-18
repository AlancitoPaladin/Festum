import 'package:festum/features/client/models/client_cart_item.dart';
import 'package:festum/features/client/repositories/client_cart_repository.dart';

class GetClientCartItemsUseCase {
  const GetClientCartItemsUseCase(this._repository);

  final ClientCartRepository _repository;

  Future<List<ClientCartItem>> call() {
    return _repository.getCartItems();
  }
}
