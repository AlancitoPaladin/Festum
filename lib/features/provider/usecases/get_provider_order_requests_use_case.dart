import 'package:festum/features/provider/models/provider_order_request.dart';
import 'package:festum/features/provider/repositories/provider_reservations_repository.dart';

class GetProviderOrderRequestsUseCase {
  const GetProviderOrderRequestsUseCase(this._repository);

  final ProviderReservationsRepository _repository;

  Future<List<ProviderOrderRequest>> call() {
    return _repository.fetchPendingOrderRequests();
  }
}
