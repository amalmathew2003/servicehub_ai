
import 'package:equatable/equatable.dart';

abstract class AiEvent extends Equatable {
  const AiEvent();

  @override
  List<Object?> get props => [];
}

class IdentifyServiceRequested extends AiEvent {
  final String message;

  const IdentifyServiceRequested(this.message);

  @override
  List<Object?> get props => [message];
}

class ConfirmServiceRequested extends AiEvent {
  final double latitude;
  final double longitude;
  final String serviceName;
  final double radiusKm;

  const ConfirmServiceRequested({
    required this.latitude,
    required this.longitude,
    required this.serviceName,
    this.radiusKm = 10,
  });

  @override
  List<Object?> get props => [
        latitude,
        longitude,
        serviceName,
        radiusKm,
      ];
}

// New event: submit a request for an unavailable service.
class SubmitServiceRequestRequested extends AiEvent {
  final String requestedService;
  final String description;

  const SubmitServiceRequestRequested({
    required this.requestedService,
    this.description = '',
  });

  @override
  List<Object?> get props => [
        requestedService,
        description,
      ];
}
