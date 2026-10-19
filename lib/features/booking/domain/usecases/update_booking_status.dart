import '../repositories/booking_repository.dart';

class UpdateBookingStatus {
  final BookingRepository repository;

  UpdateBookingStatus(this.repository);

  Future<void> call({
    required String bookingId,
    required String status,
  }) {
    return repository.updateBookingStatus(
      bookingId: bookingId,
      status: status,
    );
  }
}