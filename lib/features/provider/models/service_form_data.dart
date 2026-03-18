import 'package:festum/features/provider/models/service_category.dart';

class ServiceFormData {
  String name;
  ServiceCategory? category;
  String description;
  List<String> imageUrls;

  ServiceFormData({
    this.name = '',
    this.category,
    this.description = '',
    this.imageUrls = const [],
  });
}
