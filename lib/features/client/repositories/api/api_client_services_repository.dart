import 'package:festum/core/network/api_client.dart';
import 'package:festum/features/client/data/dto/client_service_item_dto.dart';
import 'package:festum/features/client/models/client_service_catalog.dart';
import 'package:festum/features/client/repositories/client_services_repository.dart';

class ApiClientServicesRepository implements ClientServicesRepository {
  ApiClientServicesRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<Map<ClientServiceCategory, List<ClientServiceItem>>>
  getHomeSections() async {
    final Map<String, List<Map<String, dynamic>>> payload = await _apiClient
        .getClientServicesHome();
    final Map<ClientServiceCategory, List<ClientServiceItem>> sections =
        <ClientServiceCategory, List<ClientServiceItem>>{
          for (final ClientServiceCategory category
              in ClientServiceCategory.values)
            category: <ClientServiceItem>[],
        };

    final List<ClientServiceItem> uncategorizedItems = <ClientServiceItem>[];
    for (final MapEntry<String, List<Map<String, dynamic>>> entry
        in payload.entries) {
      if (ClientServiceCategory.fromSlug(entry.key) != null) {
        continue;
      }
      uncategorizedItems.addAll(
        entry.value
            .map(ClientServiceItemDto.fromJson)
            .map((ClientServiceItemDto dto) => dto.toDomain()),
      );
    }

    for (final ClientServiceCategory category in ClientServiceCategory.values) {
      final List<Map<String, dynamic>> raw =
          payload[category.slug] ?? <Map<String, dynamic>>[];
      final List<ClientServiceItem> mapped = raw
          .map(ClientServiceItemDto.fromJson)
          .map((ClientServiceItemDto dto) => dto.toDomain())
          .toList();
      if (category == ClientServiceCategory.uncategorized &&
          uncategorizedItems.isNotEmpty) {
        sections[category] = <ClientServiceItem>[
          ...mapped,
          ...uncategorizedItems,
        ];
        continue;
      }
      sections[category] = mapped;
    }

    return sections;
  }

  @override
  Future<List<ClientServiceItem>> getServicesByCategory(
    ClientServiceCategory category,
  ) async {
    final List<Map<String, dynamic>> payload = await _apiClient
        .getClientServicesByCategory(category: category.slug);
    return payload
        .map(ClientServiceItemDto.fromJson)
        .map((ClientServiceItemDto dto) => dto.toDomain())
        .toList();
  }

  @override
  Future<ClientServiceItem?> getServiceById({
    required ClientServiceCategory category,
    required String serviceId,
  }) async {
    final Map<String, dynamic>? payload = await _apiClient.getClientServiceById(
      category: category.slug,
      serviceId: serviceId,
    );
    if (payload == null) {
      return null;
    }
    return ClientServiceItemDto.fromJson(payload).toDomain();
  }
}
