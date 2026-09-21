import '../entities/booking.dart';

abstract class BookingRepository {
  Future<void> createBooking({
    required Booking booking,
  });

  Future<List<Booking>> getStaffBookings({
    required String staffId,
  });

  Future<void> updateBookingStatus({
    required String bookingId,
    required String status,
  });
}