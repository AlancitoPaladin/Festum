import 'package:festum/core/services/auth_state_service.dart';
import 'package:stacked/stacked.dart';

class ProviderProfileViewModel extends BaseViewModel {
  ProviderProfileViewModel(this._authStateService);

  final AuthStateService _authStateService;

  String get userName => 'Jair';
  String get userEmail => 'jair.provider@festum.com';
  String get businessName => 'Salón Imperial & Eventos';

  void editBusinessInfo() {
    // Navegación a ProviderBusinessInfoView
  }

  void generateReports() {
    // Navegación a la pantalla de reportes (pendiente)
  }

  Future<void> logout() async {
    await _authStateService.signOut();
  }
}
