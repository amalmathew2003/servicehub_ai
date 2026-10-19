import 'package:equatable/equatable.dart';

import '../../domain/entities/booking.dart';

abstract class BookingState extends Equatable {
  const BookingState();

  @override
  List<Object?> get props => [];
}

class BookingInitial extends BookingState {
  const BookingInitial();
}

class BookingLoading extends BookingState {
  const BookingLoading();
}

class BookingCreated extends BookingState {
  const BookingCreated();
}

class StaffBookingsLoaded extends BookingState {
  final List<Booking> bookings;

  const StaffBookingsLoaded({
    required this.bookings,
  });

  @override
  List<Object?> get props => [bookings];
}

class BookingStatusUpdated extends BookingState {
  const BookingStatusUpdated();
}

class BookingError extends BookingState {
  final String message;

  const BookingError({
    required this.message,
  });

  @override
  List<Object?> get props => [message];
}