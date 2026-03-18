import 'package:stacked/stacked.dart';
import 'package:flutter/material.dart';

class ManualBookingViewModel extends BaseViewModel {
  String customerName = '';
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  String eventType = '';
  int guests = 0;
  String notes = '';

  void setDate(DateTime date) {
    selectedDate = date;
    notifyListeners();
  }

  void setTime(TimeOfDay time) {
    selectedTime = time;
    notifyListeners();
  }

  void saveBooking() {
    setBusy(true);
    // Simular guardado
    Future.delayed(const Duration(seconds: 1), () {
      setBusy(false);
      // Navegar de regreso
    });
  }
}
