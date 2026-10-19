import '../../domain/entities/booking.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/booking_datasource.dart';
import '../models/booking_model.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingDatasource datasource;

  BookingRepositoryImpl({
    required this.datasource,
  });

  @override
  Future<void> createBooking({
    required Booking booking,
  }) async {
    final model = BookingModel(
      id: booking.id,
      customerId: booking.customerId,
      staffId: booking.staffId,
      serviceId: booking.serviceId,
      serviceName: booking.serviceName,
      customerName: booking.customerName,
      staffName: booking.staffName,
      status: booking.status,
      scheduledDate: booking.scheduledDate,
      customerLatitude: booking.customerLatitude,
      customerLongitude: booking.customerLongitude,
      staffLatitude: booking.staffLatitude,
      staffLongitude: booking.staffLongitude,
      createdAt: booking.createdAt,
      updatedAt: booking.updatedAt,
    );

    await datasource.createBooking(
      booking: model,
    );
  }

  @override
  Future<List<Booking>> getStaffBookings({
    required String staffId,
  }) async {
    return datasource.getStaffBookings(
      staffId: staffId,
    );
  }

  @override
  Future<void> updateBookingStatus({
    required String bookingId,
    required String status,
  }) async {
    await datasource.updateBookingStatus(
      bookingId: bookingId,
      status: status,
    );
  }
}