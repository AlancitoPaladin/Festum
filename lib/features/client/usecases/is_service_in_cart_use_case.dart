import 'package:festum/features/client/repositories/client_cart_repository.dart';

class IsServiceInCartUseCase {
  const IsServiceInCartUseCase(this._repository);

  final ClientCartRepository _repository;

  Future<bool> call(String serviceId) {
    return _repository.containsService(serviceId);
  }
}
