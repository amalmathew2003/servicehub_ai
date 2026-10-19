import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:service_hub_ai/features/ai/data/datasources/ai_remote_datasource.dart';

import '../../domain/usecases/add_staff_service.dart';
import '../../domain/usecases/get_staff_services.dart';
import 'staff_service_event.dart';
import 'staff_service_state.dart';

class StaffServiceBloc extends Bloc<StaffServiceEvent, StaffServiceState> {
  final AddStaffService addStaffService;
  final GetStaffServices getStaffServices;
  final AiRemoteDatasource aiRemoteDatasource;

  StaffServiceBloc({
    required this.addStaffService,
    required this.getStaffServices,
    required this.aiRemoteDatasource,
  }) : super(const StaffServiceInitial()) {
    on<LoadStaffServices>(_loadServices);
    on<AddStaffServiceRequested>(_addService);
    on<FetchServiceSuggestionsRequested>(_fetchSuggestions);
    on<AddMultipleStaffServicesRequested>(_addMultipleServices);
  }

  Future<void> _loadServices(
    LoadStaffServices event,
    Emitter<StaffServiceState> emit,
  ) async {
    emit(const StaffServiceLoading());

    try {
      final services = await getStaffServices(staffUid: event.staffUid);

      emit(StaffServicesLoaded(services: services));
    } catch (e) {
      emit(StaffServiceError(message: e.toString()));
    }
  }

  Future<void> _fetchSuggestions(
    FetchServiceSuggestionsRequested event,
    Emitter<StaffServiceState> emit,
  ) async {
    final query = event.serviceText.trim();

    if (query.isEmpty) {
      emit(const ServiceSuggestionsLoaded(suggestions: []));
      return;
    }

    emit(const ServiceSuggestionsLoading());

    try {
      final suggestions = await aiRemoteDatasource.getServiceSuggestions(
        serviceText: query,
      );

      emit(ServiceSuggestionsLoaded(suggestions: suggestions));
    } catch (e) {
      emit(StaffServiceError(message: e.toString()));
    }
  }

  Future<void> _addService(
    AddStaffServiceRequested event,
    Emitter<StaffServiceState> emit,
  ) async {
    try {
      await addStaffService(staffUid: event.staffUid, service: event.service);

      final services = await getStaffServices(staffUid: event.staffUid);

      emit(StaffServicesLoaded(services: services));
    } catch (e) {
      emit(StaffServiceError(message: e.toString()));
    }
  }

  Future<void> _addMultipleServices(
    AddMultipleStaffServicesRequested event,
    Emitter<StaffServiceState> emit,
  ) async {
    if (event.services.isEmpty) {
      emit(
        const StaffServiceError(
          message: 'Please select or enter at least one service.',
        ),
      );
      return;
    }

    emit(const StaffServicesBatchSaving());

    try {
      // Check existing services before starting the batch.
      final existing = await getStaffServices(staffUid: event.staffUid);

      final existingNames = existing
          .map((service) => service.name.trim().toLowerCase())
          .toSet();

      final batchNames = <String>{};

      for (final service in event.services) {
        final normalized = service.name.trim().toLowerCase();

        if (normalized.isEmpty) {
          throw Exception('Service name cannot be empty.');
        }

        if (existingNames.contains(normalized)) {
          throw Exception('"${service.name}" is already registered.');
        }

        if (!batchNames.add(normalized)) {
          throw Exception('"${service.name}" appears more than once.');
        }
      }

      // Save through the existing Clean Architecture use case.
      for (final service in event.services) {
        await addStaffService(staffUid: event.staffUid, service: service);
      }

      final updatedServices = await getStaffServices(staffUid: event.staffUid);

      emit(StaffServicesBatchSaved(services: updatedServices));
      emit(StaffServicesLoaded(services: updatedServices));
    } catch (e) {
      emit(
        StaffServiceError(
          message: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }
}
