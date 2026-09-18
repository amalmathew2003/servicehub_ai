import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_staff_profile.dart';
import '../../domain/usecases/update_staff_profile.dart';
import 'staff_profile_event.dart';
import 'staff_profile_state.dart';

class StaffProfileBloc extends Bloc<StaffProfileEvent, StaffProfileState> {
  final GetStaffProfile getStaffProfile;
  final UpdateStaffProfile updateStaffProfile;

  StaffProfileBloc({
    required this.getStaffProfile,
    required this.updateStaffProfile,
  }) : super(const StaffProfileInitial()) {
    on<LoadStaffProfile>(_loadProfile);
    on<UpdateStaffProfileRequested>(_updateProfile);
  }

  Future<void> _loadProfile(
    LoadStaffProfile event,
    Emitter<StaffProfileState> emit,
  ) async {
    emit(const StaffProfileLoading());

    try {
      final profile = await getStaffProfile(
        staffUid: event.staffUid,
      );

      if (profile == null) {
        emit(
          const StaffProfileError(
            message: 'Staff profile not found',
          ),
        );
        return;
      }

      emit(
        StaffProfileLoaded(
          profile: profile,
        ),
      );
    } catch (e) {
      emit(
        StaffProfileError(
          message: e.toString(),
        ),
      );
    }
  }

  Future<void> _updateProfile(
    UpdateStaffProfileRequested event,
    Emitter<StaffProfileState> emit,
  ) async {
    emit(const StaffProfileLoading());

    try {
      await updateStaffProfile(
        staffUid: event.staffUid,
        profile: event.profile,
      );

      emit(const StaffProfileUpdated());

      emit(
        StaffProfileLoaded(
          profile: event.profile,
        ),
      );
    } catch (e) {
      emit(
        StaffProfileError(
          message: e.toString(),
        ),
      );
    }
  }
}