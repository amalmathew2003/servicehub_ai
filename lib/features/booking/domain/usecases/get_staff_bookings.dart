import '../entities/booking.dart';
import '../repositories/booking_repository.dart';

class GetStaffBookings {
  final BookingRepository repository;

  GetStaffBookings(this.repository);

  Future<List<Booking>> call({
    required String staffId,
  }) {
    return repository.getStaffBookings(
      staffId: staffId,
    );
  }
}