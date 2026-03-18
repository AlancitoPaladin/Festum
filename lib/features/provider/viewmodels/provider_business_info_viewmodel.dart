import 'package:festum/features/provider/models/business_info.dart';
import 'package:stacked/stacked.dart';

class ProviderBusinessInfoViewModel extends BaseViewModel {
  BusinessInfo _businessInfo = BusinessInfo();
  BusinessInfo get businessInfo => _businessInfo;

  void updateName(String value) {
    _businessInfo.name = value;
    notifyListeners();
  }

  void updateLocation(String value) {
    _businessInfo.location = value;
    notifyListeners();
  }

  void updateCoverageArea(String value) {
    _businessInfo.coverageArea = value;
    notifyListeners();
  }

  void updateContactNumber(String value) {
    _businessInfo.contactNumber = value;
    notifyListeners();
  }

  void updateWhatsapp(String value) {
    _businessInfo.whatsapp = value;
    notifyListeners();
  }

  void updateInstagram(String value) {
    _businessInfo.instagram = value;
    notifyListeners();
  }

  void updateFacebook(String value) {
    _businessInfo.facebook = value;
    notifyListeners();
  }

  void updateWebsite(String value) {
    _businessInfo.website = value;
    notifyListeners();
  }

  Future<void> saveProfile() async {
    setBusy(true);
    // Simular guardado en API/Firebase
    await Future.delayed(const Duration(seconds: 2));
    setBusy(false);
  }

  void pickLogo() {
    // Lógica para seleccionar imagen del logo
  }

  void addPhoto() {
    // Lógica para añadir fotos al carrusel
  }
}
