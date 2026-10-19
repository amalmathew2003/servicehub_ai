import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:service_hub_ai/core/notification/notification_service.dart';
import 'package:service_hub_ai/core/service/service_locator.dart';

import '../../../../features/staff/presentation/pages/staff_main_page.dart';
import '../../../../features/user/presentation/pages/user_main_page.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'login_page.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  String? _registeredStaffId;

  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(const CheckAuthStatus());
  }

  Future<void> _registerStaffNotifications() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) {
      debugPrint('Cannot register staff notifications: no Firebase user.');
      return;
    }

    // Avoid registering the same user repeatedly during rebuilds.
    if (_registeredStaffId == firebaseUser.uid) {
      return;
    }

    _registeredStaffId = firebaseUser.uid;

    try {
      // TEMPORARY: Get the Firebase ID token for Swagger testing.
      final idToken = await firebaseUser.getIdToken();

      if (idToken != null && idToken.isNotEmpty) {
        debugPrint('FIREBASE_ID_TOKEN: $idToken');
      } else {
        debugPrint('Could not obtain Firebase ID token.');
      }

      // Register the staff device's FCM token.
      await sl<NotificationService>().registerStaffToken(
        staffId: firebaseUser.uid,
      );

      debugPrint('Staff notification registration completed.');
    } catch (e, stackTrace) {
      // Notification setup should not block the dashboard.
      debugPrint('Staff notification registration failed: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading || state is AuthInitial) {
          return const Scaffold(
            backgroundColor: Color(0xFF161618),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFFE92E5F)),
            ),
          );
        }

        if (state is AuthAuthenticated) {
          final role = state.user.role;

          debugPrint('AuthGate — user: ${state.user.email}, role: "$role"');

          if (role == 'staff') {
            // Register the token without delaying dashboard display.
            _registerStaffNotifications();

            return const StaffMainPage();
          }

          return const UserMainPage();
        }

        return const LoginPage();
      },
    );
  }
}
