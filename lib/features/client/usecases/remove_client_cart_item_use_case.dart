import 'package:festum/features/client/models/client_cart_item.dart';
import 'package:festum/features/client/repositories/client_cart_repository.dart';

class RemoveClientCartItemUseCase {
  const RemoveClientCartItemUseCase(this._repository);

  final ClientCartRepository _repository;

  Future<ClientCartItem?> call(String id) {
    return _repository.removeItem(id);
  }
}
