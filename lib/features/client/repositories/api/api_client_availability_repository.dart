import 'package:festum/core/network/api_client.dart';
import 'package:festum/features/client/models/client_product_availability.dart';
import 'package:festum/features/client/repositories/client_availability_repository.dart';

class ApiClientAvailabilityRepository implements ClientAvailabilityRepository {
  ApiClientAvailabilityRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<ClientProductAvailabilityResponse> fetchMonth({
    required String productId,
    required int year,
    required int month,
  }) async {
    final Map<String, dynamic> response = await _apiClient
        .getClientProductAvailability(
          productId: productId,
          year: year,
          month: month,
        );
    return ClientProductAvailabilityResponse.fromJson(response);
  }
}
