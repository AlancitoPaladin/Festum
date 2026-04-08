import 'package:festum/features/client/repositories/client_orders_repository.dart';

class GetClientActiveOrderServiceIdsUseCase {
  const GetClientActiveOrderServiceIdsUseCase(this._repository);

  final ClientOrdersRepository _repository;

  Future<Set<String>> call() {
    return _repository.getActiveServiceIds();
  }
}
