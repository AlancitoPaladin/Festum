import 'package:festum/features/provider/models/booking.dart';
import 'package:stacked/stacked.dart';

class BookingDetailViewModel extends BaseViewModel {
  final Booking booking;

  BookingDetailViewModel(this.booking);

  void contactCustomer() {
    // Lógica para abrir WhatsApp o llamar
  }

  void cancelBooking() {
    setBusy(true);
    // Simular cancelación
    Future.delayed(const Duration(seconds: 1), () {
      setBusy(false);
    });
  }

  void modifyBooking() {
    // Navegar a la pantalla de edición
  }
}
