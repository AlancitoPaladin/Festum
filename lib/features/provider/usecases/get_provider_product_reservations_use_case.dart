import 'package:festum/features/provider/models/product_reservations_response.dart';
import 'package:festum/features/provider/repositories/provider_reservations_repository.dart';

class GetProviderProductReservationsUseCase {
  const GetProviderProductReservationsUseCase(this._repository);

  final ProviderReservationsRepository _repository;

  Future<List<ProductReservationSummary>> call() {
    return _repository.fetchReservationsProducts();
  }
}
