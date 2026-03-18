import 'package:festum/features/provider/models/booking.dart';
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
    DateTime(DateTime.now().year, DateTime.now().month, 5): DayStatus.reserved,
  };

  // Simulación de datos de reserva para el BottomSheet
  final Map<DateTime, Booking> _bookings = {
    DateTime(2025, 6, 12): Booking(
      id: '1',
      customerName: 'Maria Lopez',
      customerImageUrl: 'https://i.pravatar.cc/150?u=maria',
      customerPhone: '123456789',
      date: DateTime(2025, 6, 12),
      time: '14:00',
      eventType: 'Boda',
      guests: 180,
      totalAmount: 5000,
      paidAmount: 2500,
      status: 'Confirmada',
    ),
    DateTime(DateTime.now().year, DateTime.now().month, 5): Booking(
      id: '2',
      customerName: 'Juan Perez',
      customerImageUrl: 'https://i.pravatar.cc/150?u=juan',
      customerPhone: '987654321',
      date: DateTime(DateTime.now().year, DateTime.now().month, 5),
      time: '18:00',
      eventType: 'XV Años',
      guests: 100,
      totalAmount: 3000,
      paidAmount: 3000,
      status: 'Pagado',
    ),
  };

  DayStatus getStatus(DateTime date) {
    final cleanDate = DateTime(date.year, date.month, date.day);
    return _calendarData[cleanDate] ?? DayStatus.available;
  }

  Booking? getBooking(DateTime date) {
    final cleanDate = DateTime(date.year, date.month, date.day);
    return _bookings[cleanDate];
  }

  void nextMonth() {
    _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
    notifyListeners();
  }

  void previousMonth() {
    _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
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
