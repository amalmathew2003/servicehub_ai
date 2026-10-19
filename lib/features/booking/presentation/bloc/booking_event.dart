import 'package:equatable/equatable.dart';

import '../../domain/entities/booking.dart';

abstract class BookingEvent extends Equatable {
  const BookingEvent();

  @override
  List<Object?> get props => [];
}

class CreateBookingRequested extends BookingEvent {
  final Booking booking;

  const CreateBookingRequested({
    required this.booking,
  });

  @override
  List<Object?> get props => [booking];
}

class LoadStaffBookingsRequested extends BookingEvent {
  final String staffId;

  const LoadStaffBookingsRequested({
    required this.staffId,
  });

  @override
  List<Object?> get props => [staffId];
}

class UpdateBookingStatusRequested extends BookingEvent {
  final String bookingId;
  final String status;

  const UpdateBookingStatusRequested({
    required this.bookingId,
    required this.status,
  });

  @override
  List<Object?> get props => [
        bookingId,
        status,
      ];
}