import 'package:festum/features/provider/viewmodels/add_service_viewmodel.dart';
import 'package:stacked/stacked.dart';

class CreateServiceViewModel extends BaseViewModel {
  ServiceCategory? _selectedCategory;
  ServiceCategory? get selectedCategory => _selectedCategory;

  void setCategory(ServiceCategory? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void saveService() {
    setBusy(true);
    // Simular guardado
    Future.delayed(const Duration(seconds: 2), () {
      setBusy(false);
      // Navegación o lógica de éxito
    });
  }
}
