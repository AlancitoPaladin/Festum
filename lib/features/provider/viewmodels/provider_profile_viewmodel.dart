import 'package:stacked/stacked.dart';

class ProviderProfileViewModel extends BaseViewModel {
  String get userName => 'Jair';
  String get userEmail => 'jair.provider@festum.com';
  String get businessName => 'Salón Imperial & Eventos';

  void editBusinessInfo() {
    // Navegación a ProviderBusinessInfoView
  }

  void generateReports() {
    // Navegación a la pantalla de reportes (pendiente)
  }

  void logout() {
    // Lógica de cerrar sesión
  }
}
