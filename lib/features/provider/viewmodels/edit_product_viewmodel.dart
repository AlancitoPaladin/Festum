import 'package:festum/features/provider/models/product_form_data.dart';
import 'package:festum/features/provider/models/service_category.dart';
import 'package:stacked/stacked.dart';

class EditProductViewModel extends BaseViewModel {
  final ServiceCategory category;
  final String productId;
  late ProductFormData formData;

  EditProductViewModel({required this.category, required this.productId}) {
    // Aquí cargaríamos los datos reales del producto desde un repositorio
    _loadInitialData();
  }

  void _loadInitialData() {
    // Simulamos carga de datos existentes
    formData = ProductFormData(
      name: 'Paquete DJ Básico (Editado)',
      price: 2500,
      description: 'Descripción cargada del producto...',
      // ... otros campos según categoría
    );
    notifyListeners();
  }

  // Métodos de actualización (reutilizados del concepto de Add)
  void updateName(String value) { formData.name = value; notifyListeners(); }
  void updatePrice(String value) { formData.price = double.tryParse(value) ?? 0; notifyListeners(); }
  void updateDescription(String value) { formData.description = value; notifyListeners(); }
  
  void toggleInclusion(String key) {
    formData.inclusions[key] = !(formData.inclusions[key] ?? false);
    notifyListeners();
  }

  Future<void> updateProduct() async {
    setBusy(true);
    await Future.delayed(const Duration(seconds: 2));
    setBusy(false);
    // Navegar atrás
  }
}
