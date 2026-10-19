
import 'package:equatable/equatable.dart';

import '../../domain/entities/staff_service.dart';

abstract class StaffServiceEvent extends Equatable {
  const StaffServiceEvent();

  @override
  List<Object?> get props => [];
}

class LoadStaffServices extends StaffServiceEvent {
  final String staffUid;

  const LoadStaffServices({required this.staffUid});

  @override
  List<Object?> get props => [staffUid];
}

class AddStaffServiceRequested extends StaffServiceEvent {
  final String staffUid;
  final StaffService service;

  const AddStaffServiceRequested({
    required this.staffUid,
    required this.service,
  });

  @override
  List<Object?> get props => [staffUid, service];
}

class FetchServiceSuggestionsRequested extends StaffServiceEvent {
  final String serviceText;

  const FetchServiceSuggestionsRequested({
    required this.serviceText,
  });

  @override
  List<Object?> get props => [serviceText];
}

class AddMultipleStaffServicesRequested extends StaffServiceEvent {
  final String staffUid;
  final List<StaffService> services;

  const AddMultipleStaffServicesRequested({
    required this.staffUid,
    required this.services,
  });

  @override
  List<Object?> get props => [staffUid, services];
}