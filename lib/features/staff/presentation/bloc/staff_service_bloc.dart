import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:service_hub_ai/features/staff/domain/entities/staff_service.dart';

import '../../domain/usecases/add_staff_service.dart';
import '../../domain/usecases/get_staff_services.dart';
import 'staff_service_event.dart';
import 'staff_service_state.dart';

class StaffServiceBloc
    extends Bloc<StaffServiceEvent, StaffServiceState> {
  final AddStaffService addStaffService;
  final GetStaffServices getStaffServices;

  StaffServiceBloc({
    required this.addStaffService,
    required this.getStaffServices,
  }) : super(const StaffServiceInitial()) {
    on<LoadStaffServices>(_loadServices);
    on<AddStaffServiceRequested>(_addService);
  }

  // ─── Load services ────────────────────────────────────────────
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

  // ─── Add service ──────────────────────────────────────────────
  Future<void> _addService(
    AddStaffServiceRequested event,
    Emitter<StaffServiceState> emit,
  ) async {
    // Optimistic UI update
    List<StaffService> previousServices = [];
    if (state is StaffServicesLoaded) {
      previousServices = (state as StaffServicesLoaded).services;
      emit(StaffServicesLoaded(
        services: [event.service, ...previousServices],
      ));
    }

    try {
      await addStaffService(
        staffUid: event.staffUid,
        service: event.service,
      );

      // Fetch latest quietly in the background to ensure consistency
      final services = await getStaffServices(staffUid: event.staffUid);
      emit(StaffServicesLoaded(services: services));
    } catch (e) {
      // Revert if it fails
      emit(StaffServicesLoaded(services: previousServices));
      emit(StaffServiceError(message: e.toString()));
    }
  }
}