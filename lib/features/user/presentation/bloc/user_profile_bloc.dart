import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../location/domain/usecases/get_current_location.dart';
import '../../../location/domain/usecases/get_location_name.dart';

import '../../domain/usecases/get_user_profile.dart';
import '../../domain/usecases/update_user_profile.dart';

import 'user_profile_event.dart';
import 'user_profile_state.dart';

class UserProfileBloc
    extends Bloc<UserProfileEvent, UserProfileState> {
  final GetUserProfile getUserProfile;
  final UpdateUserProfile updateUserProfile;

  // Location use cases
  final GetCurrentLocation getCurrentLocation;
  final GetLocationName getLocationName;

  UserProfileBloc({
    required this.getUserProfile,
    required this.updateUserProfile,
    required this.getCurrentLocation,
    required this.getLocationName,
  }) : super(const UserProfileInitial()) {
    on<LoadUserProfile>(_loadProfile);
    on<UpdateUserProfileRequested>(_updateProfile);
    on<UpdateUserLocationRequested>(_updateLocation);
  }

  // ============================================================
  // LOAD PROFILE
  // ============================================================

  Future<void> _loadProfile(
    LoadUserProfile event,
    Emitter<UserProfileState> emit,
  ) async {
    emit(const UserProfileLoading());

    try {
      final profile = await getUserProfile(
        userUid: event.userUid,
      );

      if (profile == null) {
        emit(
          const UserProfileError(
            message: 'User profile not found',
          ),
        );
        return;
      }

      emit(
        UserProfileLoaded(
          profile: profile,
        ),
      );
    } catch (e) {
      emit(
        UserProfileError(
          message: e.toString(),
        ),
      );
    }
  }

  // ============================================================
  // UPDATE PROFILE
  // ============================================================

  Future<void> _updateProfile(
    UpdateUserProfileRequested event,
    Emitter<UserProfileState> emit,
  ) async {
    emit(const UserProfileLoading());

    try {
      await updateUserProfile(
        userUid: event.userUid,
        profile: event.profile,
      );

      emit(const UserProfileUpdated());

      emit(
        UserProfileLoaded(
          profile: event.profile,
        ),
      );
    } catch (e) {
      emit(
        UserProfileError(
          message: e.toString(),
        ),
      );
    }
  }

  // ============================================================
  // UPDATE USER LOCATION
  // ============================================================

  Future<void> _updateLocation(
    UpdateUserLocationRequested event,
    Emitter<UserProfileState> emit,
  ) async {
    emit(const UserProfileLoading());

    try {
      // ----------------------------------------------------------
      // 1. Get current GPS location
      // ----------------------------------------------------------

      final position = await getCurrentLocation();

      // ----------------------------------------------------------
      // 2. Convert coordinates to location name
      // ----------------------------------------------------------

      final locationName = await getLocationName(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      // ----------------------------------------------------------
      // 3. Get existing user profile
      // ----------------------------------------------------------

      final currentProfile = await getUserProfile(
        userUid: event.userUid,
      );

      if (currentProfile == null) {
        emit(
          const UserProfileError(
            message: 'User profile not found',
          ),
        );
        return;
      }

      // ----------------------------------------------------------
      // 4. Create updated profile
      // ----------------------------------------------------------

      final updatedProfile = currentProfile.copyWith(
        latitude: position.latitude,
        longitude: position.longitude,
        locationName: locationName,
      );

      // ----------------------------------------------------------
      // 5. Save location to Firestore
      // ----------------------------------------------------------

      await updateUserProfile(
        userUid: event.userUid,
        profile: updatedProfile,
      );

      // ----------------------------------------------------------
      // 6. Update UI
      // ----------------------------------------------------------

      emit(
        UserProfileLoaded(
          profile: updatedProfile,
        ),
      );
    } catch (e) {
      emit(
        UserProfileError(
          message: e.toString(),
        ),
      );
    }
  }
}