import 'package:festum/features/provider/repositories/provider_reservations_repository.dart';

class DecideProviderOrderRequestUseCase {
  const DecideProviderOrderRequestUseCase(this._repository);

  final ProviderReservationsRepository _repository;

  Future<void> call({required String requestId, required bool accept}) {
    return _repository.decideOrderRequest(requestId: requestId, accept: accept);
  }
}
