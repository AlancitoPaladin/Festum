import 'package:festum/core/network/api_client.dart';
import 'package:festum/core/network/image_json_resolver.dart';
import 'package:festum/features/client/data/dto/client_service_item_dto.dart';
import 'package:festum/features/client/models/client_home_bootstrap.dart';
import 'package:festum/features/client/models/client_service_catalog.dart';
import 'package:festum/features/client/repositories/client_services_repository.dart';
import 'package:festum/features/client/services/client_query_cache_service.dart';

class ApiClientServicesRepository implements ClientServicesRepository {
  ApiClientServicesRepository(this._apiClient, this._cache);

  final ApiClient _apiClient;
  final ClientQueryCacheService _cache;

  static const Duration _homeTtl = Duration(seconds: 20);
  static const Duration _categoryTtl = Duration(seconds: 20);
  static const Duration _detailTtl = Duration(seconds: 20);
  static const Duration _bootstrapTtl = Duration(seconds: 10);

  @override
  Future<ClientHomeBootstrap> getHomeBootstrap() {
    return _cache.getOrLoad<ClientHomeBootstrap>(
      key: 'client_bootstrap/home',
      ttl: _bootstrapTtl,
      loader: () async {
        final Map<String, dynamic> payload = await _apiClient
            .getClientBootstrap();
        final Map<String, dynamic> homePayload =
            _asMap(payload['home']) ?? payload;
        final Map<ClientServiceCategory, List<ClientServiceItem>> sections =
            _mapHomeSectionsFromPayload(homePayload);
        final int cartCount = _readInt(_asMap(payload['cart']), const <String>[
          'count',
          'total',
        ]);
        final Set<String> cartServiceIds = _readStringSet(
          _asMap(payload['cart']),
          const <String>['service_ids', 'cart_service_ids'],
        );
        final int ordersCount = _readInt(
          _asMap(payload['orders']),
          const <String>['count', 'total'],
        );
        final Set<String> activeServiceIds = _readStringSet(
          _asMap(payload['locks']),
          const <String>['active_service_ids', 'service_ids'],
        );
        return ClientHomeBootstrap(
          sections: sections,
          cartCount: cartCount < 0 ? 0 : cartCount,
          cartServiceIds: cartServiceIds,
          ordersCount: ordersCount < 0 ? 0 : ordersCount,
          activeServiceIds: activeServiceIds,
        );
      },
    );
  }

  @override
  Future<Map<ClientServiceCategory, List<ClientServiceItem>>>
  getHomeSections() async {
    return _cache
        .getOrLoad<Map<ClientServiceCategory, List<ClientServiceItem>>>(
          key: 'client_services/home',
          ttl: _homeTtl,
          loader: () async {
            final Map<String, List<Map<String, dynamic>>> payload =
                await _apiClient.getClientServicesHome();
            final Map<String, dynamic> normalized = <String, dynamic>{
              for (final MapEntry<String, List<Map<String, dynamic>>> entry
                  in payload.entries)
                entry.key: entry.value,
            };
            return _mapHomeSectionsFromPayload(normalized);
          },
        );
  }

  @override
  Future<List<ClientServiceItem>> getServicesByCategory(
    ClientServiceCategory category,
  ) async {
    return _cache.getOrLoad<List<ClientServiceItem>>(
      key: 'client_services/category/${category.slug}',
      ttl: _categoryTtl,
      loader: () async {
        final List<Map<String, dynamic>> payload = await _apiClient
            .getClientServicesByCategory(category: category.slug);
        return payload
            .map(
              (Map<String, dynamic> item) => ClientServiceItemDto.fromJson(
                item,
                imageUseCase: ResolvedImageUseCase.list,
                productImageUseCase: ResolvedImageUseCase.list,
              ),
            )
            .map((ClientServiceItemDto dto) => dto.toDomain())
            .toList();
      },
    );
  }

  @override
  Future<ClientServiceItem?> getServiceById({
    required ClientServiceCategory category,
    required String serviceId,
  }) async {
    return _cache.getOrLoad<ClientServiceItem?>(
      key: 'client_services/detail/${category.slug}/$serviceId',
      ttl: _detailTtl,
      loader: () async {
        final Map<String, dynamic>? payload = await _apiClient
            .getClientServiceById(
              category: category.slug,
              serviceId: serviceId,
            );
        if (payload == null) {
          return null;
        }
        return ClientServiceItemDto.fromJson(
          payload,
          imageUseCase: ResolvedImageUseCase.detail,
          productImageUseCase: ResolvedImageUseCase.list,
        ).toDomain();
      },
    );
  }

  Map<ClientServiceCategory, List<ClientServiceItem>>
  _mapHomeSectionsFromPayload(Map<String, dynamic> payload) {
    final Map<ClientServiceCategory, List<ClientServiceItem>> sections =
        <ClientServiceCategory, List<ClientServiceItem>>{
          for (final ClientServiceCategory category
              in ClientServiceCategory.values)
            category: <ClientServiceItem>[],
        };

    final List<ClientServiceItem> uncategorizedItems = <ClientServiceItem>[];
    for (final MapEntry<String, dynamic> entry in payload.entries) {
      if (ClientServiceCategory.fromSlug(entry.key) != null) {
        continue;
      }
      final List<Map<String, dynamic>> raw = _extractItemsList(entry.value);
      uncategorizedItems.addAll(
        raw
            .map(
              (Map<String, dynamic> item) => ClientServiceItemDto.fromJson(
                item,
                imageUseCase: ResolvedImageUseCase.list,
                productImageUseCase: ResolvedImageUseCase.list,
              ),
            )
            .map((ClientServiceItemDto dto) => dto.toDomain()),
      );
    }

    for (final ClientServiceCategory category in ClientServiceCategory.values) {
      final List<Map<String, dynamic>> raw = _extractItemsList(
        payload[category.slug],
      );
      final List<ClientServiceItem> mapped = raw
          .map(
            (Map<String, dynamic> item) => ClientServiceItemDto.fromJson(
              item,
              imageUseCase: ResolvedImageUseCase.list,
              productImageUseCase: ResolvedImageUseCase.list,
            ),
          )
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

  static List<Map<String, dynamic>> _extractItemsList(dynamic value) {
    if (value is List) {
      return value
          .whereType<Map>()
          .map((Map<dynamic, dynamic> item) => Map<String, dynamic>.from(item))
          .toList();
    }
    return const <Map<String, dynamic>>[];
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return null;
  }

  static int _readInt(Map<String, dynamic>? source, List<String> keys) {
    if (source == null) {
      return 0;
    }
    for (final String key in keys) {
      final dynamic value = source[key];
      if (value is int) {
        return value;
      }
      if (value is num) {
        return value.toInt();
      }
      if (value != null) {
        final int? parsed = int.tryParse(value.toString().trim());
        if (parsed != null) {
          return parsed;
        }
      }
    }
    return 0;
  }

  static Set<String> _readStringSet(
    Map<String, dynamic>? source,
    List<String> keys,
  ) {
    if (source == null) {
      return <String>{};
    }
    for (final String key in keys) {
      final dynamic raw = source[key];
      if (raw is List) {
        return raw
            .map((dynamic value) => value.toString().trim())
            .where((String value) => value.isNotEmpty)
            .toSet();
      }
    }
    return <String>{};
  }
}
