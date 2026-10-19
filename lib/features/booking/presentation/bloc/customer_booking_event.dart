import 'package:equatable/equatable.dart';

abstract class CustomerBookingEvent extends Equatable {
  const CustomerBookingEvent();

  @override
  List<Object?> get props => [];
}

class LoadCustomerProfileRequested extends CustomerBookingEvent {
  final String userUid;

  const LoadCustomerProfileRequested({
    required this.userUid,
  });

  @override
  List<Object?> get props => [userUid];
}

class SubmitCustomerBookingRequested extends CustomerBookingEvent {
  final String staffId;
  final String staffName;
  final String serviceId;
  final String serviceName;
  final bool scheduleForLater;
  final DateTime? scheduledDate;

  final double? staffLatitude;
  final double? staffLongitude;

  const SubmitCustomerBookingRequested({
    required this.staffId,
    required this.staffName,
    required this.serviceId,
    required this.serviceName,
    required this.scheduleForLater,
    this.scheduledDate,
    this.staffLatitude,
    this.staffLongitude,
  });

  @override
  List<Object?> get props => [
        staffId,
        staffName,
        serviceId,
        serviceName,
        scheduleForLater,
        scheduledDate,
        staffLatitude,
        staffLongitude,
      ];
}