import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

import 'package:service_hub_ai/features/location/domain/usecases/get_current_location.dart';
import 'package:service_hub_ai/features/location/domain/usecases/get_location_name.dart';
import 'package:service_hub_ai/features/location/domain/usecases/get_location_stream.dart';
import 'package:service_hub_ai/features/staff/domain/entities/staff_profile.dart';

import '../../domain/usecases/get_staff_profile.dart';
import '../../domain/usecases/update_staff_profile.dart';
import 'staff_profile_event.dart';
import 'staff_profile_state.dart';

class StaffProfileBloc
    extends Bloc<StaffProfileEvent, StaffProfileState> {
  final GetStaffProfile getStaffProfile;
  final UpdateStaffProfile updateStaffProfile;
  final GetCurrentLocation getCurrentLocation;
  final GetLocationName getLocationName;
  final GetLocationStream getLocationStream;

  StreamSubscription<Position>? _locationSubscription;

  StaffProfileBloc({
    required this.getStaffProfile,
    required this.updateStaffProfile,
    required this.getCurrentLocation,
    required this.getLocationName,
    required this.getLocationStream,
  }) : super(const StaffProfileInitial()) {
    on<LoadStaffProfile>(_loadProfile);
    on<UpdateStaffProfileRequested>(_updateProfile);
    on<UpdateStaffLocationRequested>(_updateLocation);
    on<StaffLocationStreamUpdated>(_locationStreamUpdated);
  }

  // ============================================================
  // LOAD PROFILE
  // ============================================================

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

      // If staff was already online, start tracking.
      if (profile.isOnline) {
        _startLocationTracking(profile.uid);
      }
    } catch (e) {
      emit(
        StaffProfileError(
          message: e.toString(),
        ),
      );
    }
  }

  // ============================================================
  // UPDATE PROFILE
  // ============================================================

  Future<void> _updateProfile(
    UpdateStaffProfileRequested event,
    Emitter<StaffProfileState> emit,
  ) async {
    if (event.isSilent) {
      emit(
        StaffProfileLoaded(
          profile: event.profile,
        ),
      );
    } else {
      emit(const StaffProfileLoading());
    }

    try {
      await updateStaffProfile(
        staffUid: event.staffUid,
        profile: event.profile,
      );

      // ONLINE → START LOCATION TRACKING
      if (event.profile.isOnline) {
        _startLocationTracking(event.staffUid);
      }

      // OFFLINE → STOP LOCATION TRACKING
      if (!event.profile.isOnline) {
        await _stopLocationTracking();
      }

      if (!event.isSilent) {
        emit(const StaffProfileUpdated());

        emit(
          StaffProfileLoaded(
            profile: event.profile,
          ),
        );
      }
    } catch (e) {
      emit(
        StaffProfileError(
          message: e.toString(),
        ),
      );
    }
  }

  // ============================================================
  // UPDATE CURRENT LOCATION
  // ============================================================

  Future<void> _updateLocation(
    UpdateStaffLocationRequested event,
    Emitter<StaffProfileState> emit,
  ) async {
    try {
      final position = await getCurrentLocation();

      final locationName = await getLocationName(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      final currentProfile = await getStaffProfile(
        staffUid: event.staffUid,
      );

      if (currentProfile == null) {
        emit(
          const StaffProfileError(
            message: 'Staff profile not found',
          ),
        );
        return;
      }

      final updatedProfile = StaffProfile(
        uid: currentProfile.uid,
        name: currentProfile.name,
        email: currentProfile.email,
        phone: currentProfile.phone,
        profileImage: currentProfile.profileImage,
        latitude: position.latitude,
        longitude: position.longitude,
        locationName: locationName,
        isOnline: currentProfile.isOnline,
      );

      await updateStaffProfile(
        staffUid: event.staffUid,
        profile: updatedProfile,
      );

      emit(
        StaffProfileLoaded(
          profile: updatedProfile,
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

  // ============================================================
  // START LOCATION TRACKING
  // ============================================================

  void _startLocationTracking(String staffUid) {
    // Prevent multiple subscriptions.
    if (_locationSubscription != null) {
      return;
    }

    _locationSubscription = getLocationStream().listen(
      (position) {
        add(
          StaffLocationStreamUpdated(
            staffUid: staffUid,
            latitude: position.latitude,
            longitude: position.longitude,
          ),
        );
      },
      onError: (error) {
        // Location stream error
        // We don't stop the app because of a GPS stream error.
      },
    );
  }

  // ============================================================
  // LOCATION STREAM UPDATED
  // ============================================================

  Future<void> _locationStreamUpdated(
    StaffLocationStreamUpdated event,
    Emitter<StaffProfileState> emit,
  ) async {
    try {
      StaffProfile? currentProfile;

      if (state is StaffProfileLoaded) {
        currentProfile =
            (state as StaffProfileLoaded).profile;
      }

      currentProfile ??= await getStaffProfile(
        staffUid: event.staffUid,
      );

      if (currentProfile == null) {
        return;
      }

      final updatedProfile = StaffProfile(
        uid: currentProfile.uid,
        name: currentProfile.name,
        email: currentProfile.email,
        phone: currentProfile.phone,
        profileImage: currentProfile.profileImage,

        // NEW GPS LOCATION
        latitude: event.latitude,
        longitude: event.longitude,

        // Keep existing location name for now.
        locationName: currentProfile.locationName,

        isOnline: currentProfile.isOnline,
      );

      await updateStaffProfile(
        staffUid: event.staffUid,
        profile: updatedProfile,
      );

      emit(
        StaffProfileLoaded(
          profile: updatedProfile,
        ),
      );
    } catch (e) {
      // Ignore individual GPS update errors.
    }
  }

  // ============================================================
  // STOP LOCATION TRACKING
  // ============================================================

  Future<void> _stopLocationTracking() async {
    await _locationSubscription?.cancel();
    _locationSubscription = null;
  }

  // ============================================================
  // CLOSE BLOC
  // ============================================================

  @override
  Future<void> close() async {
    await _stopLocationTracking();
    return super.close();
  }
}