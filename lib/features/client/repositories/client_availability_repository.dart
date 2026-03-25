import 'package:festum/features/client/models/client_product_availability.dart';

abstract class ClientAvailabilityRepository {
  Future<ClientProductAvailabilityResponse> fetchMonth({
    required String productId,
    required int year,
    required int month,
  });
}
