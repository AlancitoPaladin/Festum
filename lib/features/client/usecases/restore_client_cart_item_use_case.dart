import 'package:festum/features/client/models/client_cart_item.dart';
import 'package:festum/features/client/repositories/client_cart_repository.dart';

class RestoreClientCartItemUseCase {
  const RestoreClientCartItemUseCase(this._repository);

  final ClientCartRepository _repository;

  Future<void> call({required ClientCartItem item, required int index}) {
    return _repository.restoreItem(item: item, index: index);
  }
}
