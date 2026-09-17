import 'package:equatable/equatable.dart';

import '../../domain/entities/app_user.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

// Initial
class AuthInitial extends AuthState {
  const AuthInitial();
}

// Loading
class AuthLoading extends AuthState {
  const AuthLoading();
}

// User is logged in
class AuthAuthenticated extends AuthState {
  final AppUser user;

  const AuthAuthenticated({
    required this.user,
  });

  @override
  List<Object?> get props => [user.uid];
}

// User is not logged in
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

// Error
class AuthError extends AuthState {
  final String message;

  const AuthError({
    required this.message,
  });

  @override
  List<Object?> get props => [message];
}