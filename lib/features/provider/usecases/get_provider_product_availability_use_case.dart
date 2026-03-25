import 'package:festum/features/provider/models/provider_product_availability.dart';
import 'package:festum/features/provider/repositories/provider_availability_repository.dart';

class GetProviderProductAvailabilityUseCase {
  const GetProviderProductAvailabilityUseCase(this._repository);

  final ProviderAvailabilityRepository _repository;

  Future<ProviderProductAvailabilityMonthResponse> call({
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
