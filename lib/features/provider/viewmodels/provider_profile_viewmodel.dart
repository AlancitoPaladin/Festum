import 'package:festum/core/services/auth_state_service.dart';
import 'package:festum/core/services/provider_branding_service.dart';
import 'package:festum/core/services/provider_business_info_state_service.dart';
import 'package:festum/core/services/provider_reactivity_service.dart';
import 'package:stacked/stacked.dart';

class ProviderProfileViewModel extends BaseViewModel {
  ProviderProfileViewModel(
    this._authStateService,
    this._providerBusinessInfoStateService,
    this._providerBrandingService,
    this._providerReactivityService,
  );

  final AuthStateService _authStateService;
  final ProviderBusinessInfoStateService _providerBusinessInfoStateService;
  final ProviderBrandingService _providerBrandingService;
  final ProviderReactivityService _providerReactivityService;

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
    await _providerBrandingService.clear();
    await _providerReactivityService.clear();
    await _authStateService.signOut();
  }
}
