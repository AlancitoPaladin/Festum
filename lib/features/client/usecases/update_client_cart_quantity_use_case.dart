import 'package:festum/features/client/models/client_cart_item.dart';
import 'package:festum/features/client/repositories/client_cart_repository.dart';

class UpdateClientCartQuantityUseCase {
  const UpdateClientCartQuantityUseCase(this._repository);

  final ClientCartRepository _repository;

  Future<ClientCartItem?> call({required String id, required int quantity}) {
    return _repository.updateQuantity(id: id, quantity: quantity);
  }
}
