import 'package:equatable/equatable.dart';

import '../../domain/entities/staff_profile.dart';

abstract class StaffProfileState extends Equatable {
  const StaffProfileState();

  @override
  List<Object?> get props => [];
}

class StaffProfileInitial extends StaffProfileState {
  const StaffProfileInitial();
}

class StaffProfileLoading extends StaffProfileState {
  const StaffProfileLoading();
}

class StaffProfileLoaded extends StaffProfileState {
  final StaffProfile profile;

  const StaffProfileLoaded({
    required this.profile,
  });

  @override
  List<Object?> get props => [profile];
}

class StaffProfileUpdated extends StaffProfileState {
  const StaffProfileUpdated();
}

class StaffProfileError extends StaffProfileState {
  final String message;

  const StaffProfileError({
    required this.message,
  });

  @override
  List<Object?> get props => [message];
}