import 'package:festum/features/client/models/client_service_catalog.dart';
import 'package:festum/features/client/repositories/client_services_repository.dart';

class MockClientServicesRepository implements ClientServicesRepository {
  @override
  Future<Map<ClientServiceCategory, List<ClientServiceItem>>>
  getHomeSections() async {
    await Future<void>.delayed(const Duration(milliseconds: 280));
    return <ClientServiceCategory, List<ClientServiceItem>>{
      for (final ClientServiceCategory category in ClientServiceCategory.values)
        category: ClientServiceCatalog.servicesByCategory(category),
    };
  }

  @override
  Future<List<ClientServiceItem>> getServicesByCategory(
    ClientServiceCategory category,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 260));
    return ClientServiceCatalog.servicesByCategory(category);
  }

  @override
  Future<ClientServiceItem?> getServiceById({
    required ClientServiceCategory category,
    required String serviceId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    return ClientServiceCatalog.findService(
      category: category,
      serviceId: serviceId,
    );
  }
}
