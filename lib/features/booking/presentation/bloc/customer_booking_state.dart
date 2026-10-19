import 'package:equatable/equatable.dart';

import '../../../user/domain/entities/user_profile.dart';

abstract class CustomerBookingState extends Equatable {
  const CustomerBookingState();

  @override
  List<Object?> get props => [];
}

class CustomerBookingInitial extends CustomerBookingState {
  const CustomerBookingInitial();
}

class CustomerBookingLoading extends CustomerBookingState {
  const CustomerBookingLoading();
}

class CustomerProfileLoaded extends CustomerBookingState {
  final UserProfile profile;

  const CustomerProfileLoaded({
    required this.profile,
  });

  @override
  List<Object?> get props => [profile];
}

class CustomerBookingSuccess extends CustomerBookingState {
  const CustomerBookingSuccess();
}

class CustomerBookingFailure extends CustomerBookingState {
  final String message;

  const CustomerBookingFailure({
    required this.message,
  });

  @override
  List<Object?> get props => [message];
}