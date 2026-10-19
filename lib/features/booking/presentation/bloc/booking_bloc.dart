import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/create_booking.dart';
import '../../domain/usecases/get_staff_bookings.dart';
import '../../domain/usecases/update_booking_status.dart';

import 'booking_event.dart';
import 'booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final CreateBooking createBooking;
  final GetStaffBookings getStaffBookings;
  final UpdateBookingStatus updateBookingStatus;

  BookingBloc({
    required this.createBooking,
    required this.getStaffBookings,
    required this.updateBookingStatus,
  }) : super(const BookingInitial()) {
    on<CreateBookingRequested>(_createBooking);
    on<LoadStaffBookingsRequested>(_loadStaffBookings);
    on<UpdateBookingStatusRequested>(_updateBookingStatus);
  }

  // ============================================================
  // CREATE BOOKING
  // ============================================================

  Future<void> _createBooking(
    CreateBookingRequested event,
    Emitter<BookingState> emit,
  ) async {
    emit(const BookingLoading());

    try {
      await createBooking(
        booking: event.booking,
      );

      emit(const BookingCreated());
    } catch (e) {
      emit(
        BookingError(
          message: e.toString(),
        ),
      );
    }
  }

  // ============================================================
  // LOAD STAFF BOOKINGS
  // ============================================================

  Future<void> _loadStaffBookings(
    LoadStaffBookingsRequested event,
    Emitter<BookingState> emit,
  ) async {
    emit(const BookingLoading());

    try {
      final bookings = await getStaffBookings(
        staffId: event.staffId,
      );

      emit(
        StaffBookingsLoaded(
          bookings: bookings,
        ),
      );
    } catch (e) {
      emit(
        BookingError(
          message: e.toString(),
        ),
      );
    }
  }

  // ============================================================
  // UPDATE BOOKING STATUS
  // ============================================================

  Future<void> _updateBookingStatus(
    UpdateBookingStatusRequested event,
    Emitter<BookingState> emit,
  ) async {
    emit(const BookingLoading());

    try {
      await updateBookingStatus(
        bookingId: event.bookingId,
        status: event.status,
      );

      emit(const BookingStatusUpdated());
    } catch (e) {
      emit(
        BookingError(
          message: e.toString(),
        ),
      );
    }
  }
}