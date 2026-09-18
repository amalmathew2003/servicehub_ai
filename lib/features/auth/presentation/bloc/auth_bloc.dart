import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/google_login.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/logout_user.dart';
import '../../domain/usecases/register_user.dart';

import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final RegisterUser registerUser;
  final LoginUser loginUser;
  final GoogleLogin googleLogin;
  final LogoutUser logoutUser;
  final GetCurrentUser getCurrentUser;

  AuthBloc({
    required this.registerUser,
    required this.loginUser,
    required this.googleLogin,
    required this.logoutUser,
    required this.getCurrentUser,
  }) : super(const AuthInitial()) {
    on<CheckAuthStatus>(_checkAuthStatus);

    on<RegisterRequested>(_register);

    on<LoginRequested>(_login);

    on<GoogleLoginRequested>(_googleLogin);

    on<LogoutRequested>(_logout);
  }

  // ==========================================
  // CHECK AUTH STATUS
  // ==========================================

  Future<void> _checkAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final user = await getCurrentUser();

      if (user != null) {
        emit(
          AuthAuthenticated(user: user),
        );
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(
        AuthError(
          message: e.toString(),
        ),
      );
    }
  }

  // ==========================================
  // REGISTER
  // ==========================================

  Future<void> _register(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final user = await registerUser(
        name: event.name,
        email: event.email,
        password: event.password,
        role: event.role,
      );

      emit(
        AuthAuthenticated(user: user),
      );
    } catch (e) {
      emit(
        AuthError(
          message: _getErrorMessage(e),
        ),
      );
    }
  }

  // ==========================================
  // LOGIN
  // ==========================================

  Future<void> _login(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final user = await loginUser(
        email: event.email,
        password: event.password,
      );

      emit(
        AuthAuthenticated(user: user),
      );
    } catch (e) {
      emit(
        AuthError(
          message: _getErrorMessage(e),
        ),
      );
    }
  }

  // ==========================================
  // GOOGLE LOGIN
  // ==========================================

  Future<void> _googleLogin(
    GoogleLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final user = await googleLogin(
        role: event.role,
      );

      emit(
        AuthAuthenticated(user: user),
      );
    } catch (e) {
      emit(
        AuthError(
          message: _getErrorMessage(e),
        ),
      );
    }
  }

  // ==========================================
  // LOGOUT
  // ==========================================

  Future<void> _logout(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      await logoutUser();

      emit(
        const AuthUnauthenticated(),
      );
    } catch (e) {
      emit(
        AuthError(
          message: _getErrorMessage(e),
        ),
      );
    }
  }

  // ==========================================
  // FIREBASE ERROR MESSAGE
  // ==========================================

  String _getErrorMessage(Object error) {
    final message = error.toString();

    if (message.contains('email-already-in-use')) {
      return 'This email is already registered.';
    }

    if (message.contains('invalid-email')) {
      return 'Please enter a valid email.';
    }

    if (message.contains('weak-password')) {
      return 'Password must be at least 6 characters.';
    }

    if (message.contains('user-not-found')) {
      return 'No account found with this email.';
    }

    if (message.contains('wrong-password') ||
        message.contains('invalid-credential')) {
      return 'Invalid email or password.';
    }

    if (message.contains('network-request-failed')) {
      return 'Please check your internet connection.';
    }

    if (message.contains('Google sign-in cancelled')) {
      return 'Google sign-in was cancelled.';
    }

    // Firestore permission errors
    if (message.contains('permission-denied') ||
        message.contains('PERMISSION_DENIED') ||
        message.contains('Missing or insufficient permissions')) {
      return 'Database access denied. Please contact support.';
    }

    if (message.contains('unavailable') || message.contains('UNAVAILABLE')) {
      return 'Service temporarily unavailable. Please try again.';
    }

    return 'Something went wrong: $message';
  }
}