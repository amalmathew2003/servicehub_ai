import 'package:equatable/equatable.dart';

import '../../domain/entities/staff_service.dart';

abstract class StaffServiceState extends Equatable {
  const StaffServiceState();

  @override
  List<Object?> get props => [];
}

class StaffServiceInitial extends StaffServiceState {
  const StaffServiceInitial();
}

class StaffServiceLoading extends StaffServiceState {
  const StaffServiceLoading();
}

class StaffServicesLoaded extends StaffServiceState {
  final List<StaffService> services;

  const StaffServicesLoaded({
    required this.services,
  });

  @override
  List<Object?> get props => [services];
}

class StaffServiceAdded extends StaffServiceState {
  const StaffServiceAdded();
}

class StaffServiceError extends StaffServiceState {
  final String message;

  const StaffServiceError({
    required this.message,
  });

  @override
  List<Object?> get props => [message];
}