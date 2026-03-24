import 'package:festum/features/provider/models/service_category.dart';

class ProviderService {
  const ProviderService({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.status,
    required this.mainImageUrl,
    required this.imageUrls,
  });

  final String id;
  final String name;
  final ServiceCategory category;
  final String description;
  final String status;
  final String mainImageUrl;
  final List<String> imageUrls;

  bool get isActive => status == 'active';

  factory ProviderService.fromJson(Map<String, dynamic> json) {
    return ProviderService(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      category: ServiceCategory.values.firstWhere(
        (ServiceCategory item) => item.name == json['category'],
        orElse: () => ServiceCategory.dj,
      ),
      description: (json['description'] ?? '').toString(),
      status: (json['status'] ?? 'inactive').toString(),
      mainImageUrl: (json['main_image_url'] ?? '').toString(),
      imageUrls:
          ((json['image_urls'] as List<dynamic>? ?? <dynamic>[])
              .map((dynamic item) => item.toString())
              .toList()),
    );
  }

  ProviderService copyWith({
    String? id,
    String? name,
    ServiceCategory? category,
    String? description,
    String? status,
    String? mainImageUrl,
    List<String>? imageUrls,
  }) {
    return ProviderService(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      status: status ?? this.status,
      mainImageUrl: mainImageUrl ?? this.mainImageUrl,
      imageUrls: imageUrls ?? this.imageUrls,
    );
  }
}

class ProviderServicesResponse {
  const ProviderServicesResponse({
    required this.items,
    required this.total,
  });

  final List<ProviderService> items;
  final int total;

  factory ProviderServicesResponse.fromJson(Map<String, dynamic> json) {
    return ProviderServicesResponse(
      items:
          ((json['items'] as List<dynamic>? ?? <dynamic>[])
              .whereType<Map<dynamic, dynamic>>()
              .map(
                (Map<dynamic, dynamic> item) =>
                    ProviderService.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList()),
      total: _toInt(json['total']),
    );
  }
}

int _toInt(Object? value) {
  if (value is int) {
    return value;
  }

  return int.tryParse(value?.toString() ?? '') ?? 0;
}
