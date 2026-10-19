import '../entities/booking.dart';
import '../repositories/booking_repository.dart';

class CreateBooking {
  final BookingRepository repository;

  CreateBooking(this.repository);

  Future<void> call({
    required Booking booking,
  }) {
    return repository.createBooking(
      booking: booking,
    );
  }
}