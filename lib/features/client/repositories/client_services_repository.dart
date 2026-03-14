import 'package:festum/features/client/models/client_service_catalog.dart';

abstract class ClientServicesRepository {
  Future<Map<ClientServiceCategory, List<ClientServiceItem>>> getHomeSections();

  Future<List<ClientServiceItem>> getServicesByCategory(
    ClientServiceCategory category,
  );

  Future<ClientServiceItem?> getServiceById({
    required ClientServiceCategory category,
    required String serviceId,
  });
}
