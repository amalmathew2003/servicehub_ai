import 'package:equatable/equatable.dart';

import '../../domain/entities/user_profile.dart';

abstract class UserProfileEvent extends Equatable {
  const UserProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserProfile extends UserProfileEvent {
  final String userUid;

  const LoadUserProfile({
    required this.userUid,
  });

  @override
  List<Object?> get props => [userUid];
}

class UpdateUserProfileRequested extends UserProfileEvent {
  final String userUid;
  final UserProfile profile;

  const UpdateUserProfileRequested({
    required this.userUid,
    required this.profile,
  });

  @override
  List<Object?> get props => [
        userUid,
        profile,
      ];
}

// ============================================================
// UPDATE USER LOCATION
// ============================================================

class UpdateUserLocationRequested extends UserProfileEvent {
  final String userUid;

  const UpdateUserLocationRequested({
    required this.userUid,
  });

  @override
  List<Object?> get props => [userUid];
}