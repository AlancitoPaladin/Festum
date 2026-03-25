import 'package:festum/features/provider/models/booking.dart';
import 'package:festum/features/provider/repositories/provider_bookings_repository.dart';

class GetProviderBookingDetailUseCase {
  const GetProviderBookingDetailUseCase(this._repository);

  final ProviderBookingsRepository _repository;

  Future<Booking> call(String bookingId) {
    return _repository.fetchBookingDetail(bookingId);
  }
}
