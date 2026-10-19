
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/booking.dart';
import '../../domain/usecases/create_booking.dart';
import '../../../user/domain/usecases/get_user_profile.dart';

import 'customer_booking_event.dart';
import 'customer_booking_state.dart';

class CustomerBookingBloc
    extends Bloc<CustomerBookingEvent, CustomerBookingState> {
  final GetUserProfile getUserProfile;
  final CreateBooking createBooking;

  CustomerBookingBloc({
    required this.getUserProfile,
    required this.createBooking,
  }) : super(const CustomerBookingInitial()) {
    on<LoadCustomerProfileRequested>(_loadCustomerProfile);
    on<SubmitCustomerBookingRequested>(_submitCustomerBooking);
  }

  dynamic _customerProfile;

  Future<void> _loadCustomerProfile(
    LoadCustomerProfileRequested event,
    Emitter<CustomerBookingState> emit,
  ) async {
    emit(const CustomerBookingLoading());

    try {
      final profile = await getUserProfile(
        userUid: event.userUid,
      );

      if (profile == null) {
        _customerProfile = null;
        emit(
          const CustomerBookingFailure(
            message:
                'Customer profile not found. Please complete your profile.',
          ),
        );
        return;
      }

      _customerProfile = profile;
      emit(CustomerProfileLoaded(profile: profile));
    } catch (e) {
      _customerProfile = null;
      emit(
        CustomerBookingFailure(
          message: 'Could not load customer profile: $e',
        ),
      );
    }
  }

  Future<void> _submitCustomerBooking(
    SubmitCustomerBookingRequested event,
    Emitter<CustomerBookingState> emit,
  ) async {
    final customer = _customerProfile;

    if (customer == null) {
      emit(
        const CustomerBookingFailure(
          message: 'Please load your customer profile before booking.',
        ),
      );
      return;
    }

    if (customer.name.trim().isEmpty) {
      emit(
        const CustomerBookingFailure(
          message: 'Please add your name to your profile before booking.',
        ),
      );
      return;
    }

    if (event.staffId.trim().isEmpty ||
        event.serviceId.trim().isEmpty) {
      emit(
        const CustomerBookingFailure(
          message: 'Staff or service information is missing.',
        ),
      );
      return;
    }

    if (event.scheduleForLater) {
      final scheduledDate = event.scheduledDate;

      if (scheduledDate == null ||
          !scheduledDate.isAfter(DateTime.now())) {
        emit(
          const CustomerBookingFailure(
            message: 'Please select a valid future date and time.',
          ),
        );
        return;
      }
    }

    emit(const CustomerBookingLoading());

    try {
      // TEMPORARY: Check the signed-in customer's Firebase token.
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        throw Exception('No authenticated Firebase user found.');
      }

      final token = await currentUser.getIdToken();

      debugPrint(
        'Customer Firebase token available: ${token != null && token.isNotEmpty}',
      );

      // Do not print or share the actual token.

      final booking = Booking(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        customerId: customer.uid,
        staffId: event.staffId,
        serviceId: event.serviceId,
        serviceName: event.serviceName,
        customerName: customer.name.trim(),
        staffName: event.staffName,
        status: 'pending',
        scheduledDate:
            event.scheduleForLater ? event.scheduledDate : null,
        customerLatitude: customer.latitude,
        customerLongitude: customer.longitude,
        staffLatitude: event.staffLatitude,
        staffLongitude: event.staffLongitude,
        createdAt: DateTime.now(),
      );

      // Existing booking flow remains unchanged for now.
      await createBooking(booking: booking);

      emit(const CustomerBookingSuccess());
    } catch (e) {
      emit(
        CustomerBookingFailure(
          message: 'Could not submit booking: $e',
        ),
      );
    }
  }
}
