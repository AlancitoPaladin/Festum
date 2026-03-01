import 'package:festum/core/di/app_locator.dart';
import 'package:festum/core/network/api_client.dart';
import 'package:stacked/stacked.dart';

class HomeViewModel extends BaseViewModel {
  final ApiClient _apiClient = locator<ApiClient>();

  String statusMessage = 'Arquitectura base inicializada.';

  Future<void> checkApi() async {
    setBusy(true);
    try {
      await _apiClient.healthCheck();
      statusMessage = 'Conexión API disponible.';
    } catch (_) {
      statusMessage = 'Sin conexión API por ahora (configuración base).';
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }
}
