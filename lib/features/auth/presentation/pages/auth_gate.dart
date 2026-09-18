import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../features/staff/presentation/pages/staff_main_page.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'home_placeholder_page.dart';
import 'login_page.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();

    context.read<AuthBloc>().add(
          const CheckAuthStatus(),
        );
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

          // DEBUG: Remove this after confirming roles work
          debugPrint('🔐 AuthGate — user: ${state.user.email}, role: "$role"');

          if (role == 'staff') {
            return const StaffMainPage();
          }

          return const HomePlaceholderPage();
        }

        return const LoginPage();
      },
    );
  }
}