import 'package:equatable/equatable.dart';

import '../../domain/entities/user_profile.dart';

abstract class UserProfileState extends Equatable {
  const UserProfileState();

  @override
  List<Object?> get props => [];
}

class UserProfileInitial extends UserProfileState {
  const UserProfileInitial();
}

class UserProfileLoading extends UserProfileState {
  const UserProfileLoading();
}

class UserProfileLoaded extends UserProfileState {
  final UserProfile profile;

  const UserProfileLoaded({
    required this.profile,
  });

  @override
  List<Object?> get props => [profile];
}

class UserProfileUpdated extends UserProfileState {
  const UserProfileUpdated();
}

class UserProfileError extends UserProfileState {
  final String message;

  const UserProfileError({
    required this.message,
  });

  @override
  List<Object?> get props => [message];
}