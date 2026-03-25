import 'package:festum/features/client/models/client_product_availability.dart';
import 'package:festum/features/client/repositories/client_availability_repository.dart';

class MockClientAvailabilityRepository implements ClientAvailabilityRepository {
  @override
  Future<ClientProductAvailabilityResponse> fetchMonth({
    required String productId,
    required int year,
    required int month,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    return ClientProductAvailabilityResponse(
      productId: productId,
      year: year,
      month: month,
      days: const <ClientAvailabilityDay>[],
    );
  }
}
