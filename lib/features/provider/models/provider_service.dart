import 'package:festum/features/provider/models/service_category.dart';

class ProviderService {
  final String id;
  final String name;
  final ServiceCategory category;
  bool isActive;

  ProviderService({
    required this.id,
    required this.name,
    required this.category,
    this.isActive = true,
  });
}
