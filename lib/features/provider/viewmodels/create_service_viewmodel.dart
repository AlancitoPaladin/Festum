import 'package:festum/features/provider/models/service_category.dart';
import 'package:festum/features/provider/models/service_form_data.dart';
import 'package:stacked/stacked.dart';

class CreateServiceViewModel extends BaseViewModel {
  final ServiceFormData _formData = ServiceFormData();
  
  ServiceFormData get formData => _formData;
  ServiceCategory? get selectedCategory => _formData.category;

  void updateName(String value) {
    _formData.name = value;
    notifyListeners();
  }

  void setCategory(ServiceCategory? category) {
    _formData.category = category;
    notifyListeners();
  }

  void updateDescription(String value) {
    _formData.description = value;
    notifyListeners();
  }

  void addPhoto() {
    // Lógica para añadir fotos
  }

  Future<void> saveService() async {
    setBusy(true);
    // Simular guardado
    await Future.delayed(const Duration(seconds: 2));
    setBusy(false);
    // Lógica de éxito o navegación
  }
}
