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

  const StaffServicesLoaded({required this.services});

  @override
  List<Object?> get props => [services];
}

class StaffServiceAdded extends StaffServiceState {
  const StaffServiceAdded();
}

class StaffServiceError extends StaffServiceState {
  final String message;

  const StaffServiceError({required this.message});

  @override
  List<Object?> get props => [message];
}

class ServiceSuggestionsLoading extends StaffServiceState {
  const ServiceSuggestionsLoading();
}

class ServiceSuggestionsLoaded extends StaffServiceState {
  final List<String> suggestions;

  const ServiceSuggestionsLoaded({required this.suggestions});

  @override
  List<Object?> get props => [suggestions];
}

class StaffServicesBatchSaving extends StaffServiceState {
  const StaffServicesBatchSaving();
}

class StaffServicesBatchSaved extends StaffServiceState {
  final List<StaffService> services;

  const StaffServicesBatchSaved({required this.services});

  @override
  List<Object?> get props => [services];
}