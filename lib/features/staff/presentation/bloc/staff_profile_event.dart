import 'package:equatable/equatable.dart';

import '../../domain/entities/staff_profile.dart';

abstract class StaffProfileEvent extends Equatable {
  const StaffProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadStaffProfile extends StaffProfileEvent {
  final String staffUid;

  const LoadStaffProfile({required this.staffUid});

  @override
  List<Object?> get props => [staffUid];
}

class UpdateStaffProfileRequested extends StaffProfileEvent {
  final String staffUid;
  final StaffProfile profile;
  final bool isSilent;

  const UpdateStaffProfileRequested({
    required this.staffUid,
    required this.profile,
    this.isSilent = false,
  });

  @override
  List<Object?> get props => [staffUid, profile, isSilent];
}

class UpdateStaffLocationRequested extends StaffProfileEvent {
  final String staffUid;
  const UpdateStaffLocationRequested({required this.staffUid});
  @override
  List<Object?> get props => [staffUid];
}



class StaffLocationStreamUpdated extends StaffProfileEvent {
  final String staffUid;
  final double latitude;
  final double longitude;

  const StaffLocationStreamUpdated({
    required this.staffUid,
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [
        staffUid,
        latitude,
        longitude,
      ];
}