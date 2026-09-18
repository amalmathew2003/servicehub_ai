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