import 'package:festum/features/provider/viewmodels/add_service_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class AddProductViewModel extends BaseViewModel {
  final ServiceCategory category;
  
  AddProductViewModel(this.category) {
    _initializeInclusions();
  }

  // Campos comunes
  String productName = '';
  double price = 0;
  String pricingUnit = 'Por evento';
  String description = '';
  int stock = 1;

  // Campos específicos de Banquete
  String banquetType = 'Buffet';
  int minGuests = 10;
  int maxGuests = 100;
  String menuDescription = '';

  // Campos específicos de DJ/Música
  String minDuration = '1 hora';
  bool extraHourAllowed = false;

  // Campos específicos de Salón
  String venueCapacity = '';
  bool pricePerHour = false;

  // Campos específicos de Decoración
  String decorationTheme = 'Boda';

  // Inclusiones dinámicas según categoría
  Map<String, bool> inclusions = {};

  void _initializeInclusions() {
    switch (category) {
      case ServiceCategory.dj:
      case ServiceCategory.entertainment:
        inclusions = {'Bocinas': false, 'Luces': false, 'Micrófono': false, 'DJ Booth': false};
        break;
      case ServiceCategory.venue:
        inclusions = {'Mesas': false, 'Sillas': false, 'Iluminación': false, 'Estacionamiento': false};
        break;
      case ServiceCategory.decoration:
        inclusions = {'Flores': false, 'Globos': false, 'Backdrop': false, 'Mesa principal': false};
        break;
      default:
        inclusions = {'Transporte': false, 'Montaje': false, 'Limpieza': false};
    }
  }

  void toggleInclusion(String key) {
    inclusions[key] = !(inclusions[key] ?? false);
    notifyListeners();
  }

  void setPricingUnit(String? unit) {
    if (unit != null) {
      pricingUnit = unit;
      notifyListeners();
    }
  }

  void setBanquetType(String? type) {
    if (type != null) {
      banquetType = type;
      notifyListeners();
    }
  }

  void setDecorationTheme(String? theme) {
    if (theme != null) {
      decorationTheme = theme;
      notifyListeners();
    }
  }

  void saveProduct() {
    setBusy(true);
    Future.delayed(const Duration(seconds: 1), () {
      setBusy(false);
    });
  }
}
