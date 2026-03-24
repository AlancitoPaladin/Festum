import 'package:festum/core/services/auth_state_service.dart';
import 'package:festum/core/services/provider_business_info_state_service.dart';
import 'package:stacked/stacked.dart';

class ProviderProfileViewModel extends BaseViewModel {
  ProviderProfileViewModel(
    this._authStateService,
    this._providerBusinessInfoStateService,
  );

  final AuthStateService _authStateService;
  final ProviderBusinessInfoStateService _providerBusinessInfoStateService;

  String get userName => 'Jair';
  String get userEmail => 'jair.provider@festum.com';
  String get businessName => 'SalÃ³n Imperial & Eventos';

  void editBusinessInfo() {
    // NavegaciÃ³n a ProviderBusinessInfoView
  }

  void generateReports() {
    // NavegaciÃ³n a la pantalla de reportes (pendiente)
  }

  Future<void> logout() async {
    await _providerBusinessInfoStateService.resetBusinessInfoProgress();
    await _authStateService.signOut();
  }
}
