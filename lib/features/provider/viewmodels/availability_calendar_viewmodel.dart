import 'package:festum/features/provider/viewmodels/reservations_viewmodel.dart';
import 'package:stacked/stacked.dart';

enum DayStatus { available, reserved, blocked }

class AvailabilityCalendarViewModel extends BaseViewModel {
  final String productId;
  final String productName;

  AvailabilityCalendarViewModel({required this.productId, required this.productName});

  DateTime _focusedDay = DateTime.now();
  DateTime get focusedDay => _focusedDay;

  // Mapa de fechas con su estado
  final Map<DateTime, DayStatus> _calendarData = {
    DateTime(2025, 6, 12): DayStatus.reserved,
    DateTime(2025, 6, 13): DayStatus.reserved,
    DateTime(2025, 6, 15): DayStatus.blocked,
    DateTime(2025, 6, 20): DayStatus.reserved,
  };

  // Simulación de datos de reserva para el BottomSheet
  final Map<DateTime, Booking> _bookings = {
    DateTime(2025, 6, 12): Booking(
      customerName: 'Maria Lopez',
      customerImageUrl: 'https://i.pravatar.cc/150?u=maria',
      date: DateTime(2025, 6, 12),
      status: 'Confirmada',
    ),
  };

  DayStatus getStatus(DateTime date) {
    // Normalizar fecha para comparar solo año, mes y día
    final cleanDate = DateTime(date.year, date.month, date.day);
    return _calendarData[cleanDate] ?? DayStatus.available;
  }

  Booking? getBooking(DateTime date) {
    final cleanDate = DateTime(date.year, date.month, date.day);
    return _bookings[cleanDate];
  }

  void onDaySelected(DateTime day) {
    _focusedDay = day;
    notifyListeners();
  }

  void blockDate(DateTime date) {
    final cleanDate = DateTime(date.year, date.month, date.day);
    _calendarData[cleanDate] = DayStatus.blocked;
    notifyListeners();
  }

  void unblockDate(DateTime date) {
    final cleanDate = DateTime(date.year, date.month, date.day);
    _calendarData.remove(cleanDate);
    notifyListeners();
  }
}
