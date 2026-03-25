import 'package:festum/features/client/models/client_product_availability.dart';
import 'package:festum/features/client/repositories/client_availability_repository.dart';

class GetClientProductAvailabilityUseCase {
  const GetClientProductAvailabilityUseCase(this._repository);

  final ClientAvailabilityRepository _repository;

  Future<ClientProductAvailabilityResponse> call({
    required String productId,
    required int year,
    required int month,
  }) {
    return _repository.fetchMonth(
      productId: productId,
      year: year,
      month: month,
    );
  }
}
