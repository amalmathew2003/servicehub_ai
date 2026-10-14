
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:service_hub_ai/features/ai/domain/usecases/identify_service.dart';
import 'package:service_hub_ai/features/ai/domain/usecases/search_nearby_staff.dart';
import 'package:service_hub_ai/features/ai/domain/usecases/submit_service_request.dart';

import 'ai_event.dart';
import 'ai_state.dart';

class AiBloc extends Bloc<AiEvent, AiState> {
  final IdentifyService identifyService;
  final SearchNearbyStaff searchNearbyStaff;
  final SubmitServiceRequest submitServiceRequest;

  AiBloc({
    required this.identifyService,
    required this.searchNearbyStaff,
    required this.submitServiceRequest,
  }) : super(const AiInitial()) {
    on<IdentifyServiceRequested>(_onIdentifyServiceRequested);
    on<ConfirmServiceRequested>(_onConfirmServiceRequested);
    on<SubmitServiceRequestRequested>(_onSubmitServiceRequestRequested);
  }

  Future<void> _onIdentifyServiceRequested(
    IdentifyServiceRequested event,
    Emitter<AiState> emit,
  ) async {
    final message = event.message.trim();

    if (message.isEmpty) {
      emit(const AiError('Please describe your problem.'));
      return;
    }

    emit(const AiLoading());

    try {
      final response = await identifyService(message);

      final reply = response['reply']?.toString() ??
          'I could not identify the service.';

      final rawServiceName = response['service_name'];
      final serviceName = rawServiceName is String &&
              rawServiceName.trim().isNotEmpty
          ? rawServiceName.trim()
          : null;

      final rawRequestedService = response['requested_service'];
      final requestedService =
          rawRequestedService is String &&
                  rawRequestedService.trim().isNotEmpty
              ? rawRequestedService.trim()
              : message;

      emit(
        ServiceIdentified(
          reply: reply,
          serviceName: serviceName,
          requiresConfirmation:
              response['requires_confirmation'] == true,
          intent: response['intent']?.toString() ?? 'unclear',
          requestedService: requestedService,
          canRequestService:
              response['can_request_service'] == true,
        ),
      );
    } catch (e) {
      emit(
        const AiError(
          'Unable to identify the service. Please try again.',
        ),
      );
    }
  }

  Future<void> _onConfirmServiceRequested(
    ConfirmServiceRequested event,
    Emitter<AiState> emit,
  ) async {
    if (event.serviceName.trim().isEmpty) {
      emit(const AiError('Please select a valid service.'));
      return;
    }

    emit(const AiLoading());

    try {
      final response = await searchNearbyStaff(
        latitude: event.latitude,
        longitude: event.longitude,
        serviceName: event.serviceName.trim(),
        radiusKm: event.radiusKm,
      );

      emit(NearbyStaffLoaded(response));
    } catch (e) {
      emit(
        const AiError(
          'Unable to find nearby staff. Please try again.',
        ),
      );
    }
  }

  Future<void> _onSubmitServiceRequestRequested(
    SubmitServiceRequestRequested event,
    Emitter<AiState> emit,
  ) async {
    final requestedService = event.requestedService.trim();

    if (requestedService.isEmpty) {
      emit(const AiError('Please provide a service name.'));
      return;
    }

    emit(const ServiceRequestSubmitting());

    try {
      final response = await submitServiceRequest(
        requestedService: requestedService,
        description: event.description.trim(),
      );

      if (response['success'] != true) {
        emit(
          const AiError(
            'The service request could not be submitted. Please try again.',
          ),
        );
        return;
      }

      emit(
        ServiceRequestSubmitted(
          requestId: response['request_id']?.toString() ?? '',
          requestedService: response['requested_service']?.toString() ??
              requestedService,
          message: response['message']?.toString() ??
              'Your service request has been submitted successfully.',
        ),
      );
    } catch (e) {
      emit(
        const AiError(
          'Unable to submit your service request. Please try again.',
        ),
      );
    }
  }
}
