import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

// Check if user is already logged in
class CheckAuthStatus extends AuthEvent {
  const CheckAuthStatus();
}

// Register with email/password
class RegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String role;

  const RegisterRequested({
    required this.name,
    required this.email,
    required this.password,
    required this.role,
  });

  @override
  List<Object?> get props => [
        name,
        email,
        password,
        role,
      ];
}

// Login with email/password
class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [
        email,
        password,
      ];
}

// Login with Google
class GoogleLoginRequested extends AuthEvent {
  final String role;

  const GoogleLoginRequested({
    required this.role,
  });

  @override
  List<Object?> get props => [role];
}

// Logout
class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}