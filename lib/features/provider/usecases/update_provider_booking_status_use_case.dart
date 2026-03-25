import 'package:festum/features/provider/models/booking.dart';
import 'package:festum/features/provider/repositories/provider_bookings_repository.dart';

class UpdateProviderBookingStatusUseCase {
  const UpdateProviderBookingStatusUseCase(this._repository);

  final ProviderBookingsRepository _repository;

  Future<Booking> call({
    required String bookingId,
    required String status,
  }) {
    return _repository.updateBookingStatus(bookingId, status);
  }
}
