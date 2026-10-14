
import 'package:equatable/equatable.dart';

abstract class AiState extends Equatable {
  const AiState();

  @override
  List<Object?> get props => [];
}

class AiInitial extends AiState {
  const AiInitial();
}

class AiLoading extends AiState {
  const AiLoading();
}

class ServiceIdentified extends AiState {
  final String reply;
  final String? serviceName;
  final bool requiresConfirmation;

  // New fields for unavailable service requests.
  final String intent;
  final String? requestedService;
  final bool canRequestService;

  const ServiceIdentified({
    required this.reply,
    required this.serviceName,
    required this.requiresConfirmation,
    this.intent = 'unclear',
    this.requestedService,
    this.canRequestService = false,
  });

  @override
  List<Object?> get props => [
        reply,
        serviceName,
        requiresConfirmation,
        intent,
        requestedService,
        canRequestService,
      ];
}

class ServiceRequestSubmitting extends AiState {
  const ServiceRequestSubmitting();
}

class ServiceRequestSubmitted extends AiState {
  final String requestId;
  final String requestedService;
  final String message;

  const ServiceRequestSubmitted({
    required this.requestId,
    required this.requestedService,
    required this.message,
  });

  @override
  List<Object?> get props => [
        requestId,
        requestedService,
        message,
      ];
}

class NearbyStaffLoaded extends AiState {
  final Map<String, dynamic> response;

  const NearbyStaffLoaded(this.response);

  @override
  List<Object?> get props => [response];
}

class AiError extends AiState {
  final String message;

  const AiError(this.message);

  @override
  List<Object?> get props => [message];
}
