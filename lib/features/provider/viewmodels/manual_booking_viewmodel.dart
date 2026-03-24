import 'package:stacked/stacked.dart';
import 'package:flutter/material.dart';

class ManualBookingViewModel extends BaseViewModel {
  String customerName = '';
  DateTime? selectedDate;
  bool hasSpecificSchedule = false;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  String eventType = '';
  int guests = 0;
  String contactPhone = '';
  String contactEmail = '';
  String eventLocation = '';
  String paymentDetails = '';
  String notes = '';

  void setDate(DateTime date) {
    selectedDate = date;
    notifyListeners();
  }

  void toggleSpecificSchedule(bool value) {
    hasSpecificSchedule = value;

    if (!value) {
      startTime = null;
      endTime = null;
    }
    notifyListeners();
  }

  void setStartTime(TimeOfDay time) {
    startTime = time;
    notifyListeners();
  }

  void setEndTime(TimeOfDay time) {
    endTime = time;
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
