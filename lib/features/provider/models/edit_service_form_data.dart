import 'package:festum/features/provider/models/service_category.dart';

class EditServiceFormData {
  String name;
  ServiceCategory? category;
  String description;
  List<String> imageUrls;

  EditServiceFormData({
    this.name = '',
    this.category,
    this.description = '',
    this.imageUrls = const [],
  });
}
