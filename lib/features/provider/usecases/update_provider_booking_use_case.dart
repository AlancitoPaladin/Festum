import 'package:festum/features/provider/models/booking.dart';
import 'package:festum/features/provider/models/update_booking_request.dart';
import 'package:festum/features/provider/repositories/provider_bookings_repository.dart';

class UpdateProviderBookingUseCase {
  const UpdateProviderBookingUseCase(this._repository);

  final ProviderBookingsRepository _repository;

  Future<Booking> call(String bookingId, UpdateBookingRequest request) {
    return _repository.updateBooking(bookingId, request);
  }
}
