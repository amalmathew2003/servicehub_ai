import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/animated_background.dart';
import '../widgets/role_chip.dart';
import '../../../../features/staff/presentation/pages/staff_home_page.dart';
import 'home_placeholder_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String _selectedRole = 'user';
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    context.read<AuthBloc>().add(
      LoginRequested(email: email, password: password),
    );
  }

  void _googleLogin() {
    context.read<AuthBloc>().add(GoogleLoginRequested(role: _selectedRole));
  }

  InputDecoration _fieldDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        color: AppColors.textLightSecondary,
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: Icon(icon, color: AppColors.iconLight),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.black.withValues(alpha: 0.1),
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            final role = state.user.role;
            final destination = role == 'staff'
                ? const StaffHomePage()
                : const HomePlaceholderPage();
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => destination,
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
                transitionDuration: const Duration(milliseconds: 400),
              ),
            );
          }

          if (state is AuthError) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: AnimatedBackground(
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  children: [
                    // Scrollable content
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Hero Header
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                28,
                                48,
                                28,
                                40,
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    width: 80,
                                    height: 80,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      borderRadius: BorderRadius.circular(24),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.1,
                                          ),
                                          blurRadius: 20,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.home_repair_service_rounded,
                                      size: 40,
                                      color: AppColors.iconDark,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  const Text(
                                    'ServiceHub',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.5,
                                      color: AppColors.textLight,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Find the right service professional',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: AppColors.textLightSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Form Card
                            ClipRRect(
                              borderRadius: BorderRadius.circular(32),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: 32,
                                  sigmaY: 32,
                                ),
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.01),
                                    borderRadius: BorderRadius.circular(32),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.05,
                                      ),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.2,
                                        ),
                                        blurRadius: 30,
                                        offset: const Offset(0, 15),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.fromLTRB(
                                    28,
                                    36,
                                    28,
                                    32,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      const Text(
                                        'Welcome back',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.textLight,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      const Text(
                                        'Sign in to continue',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppColors.textDarkSecondary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),

                                      const SizedBox(height: 32),

                                      // Role
                                      const Text(
                                        'ACCOUNT TYPE',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 11,
                                          letterSpacing: 1.5,
                                          color: AppColors.textDarkTertiary,
                                        ),
                                      ),

                                      const SizedBox(height: 12),

                                      Row(
                                        children: [
                                          Expanded(
                                            child: RoleChip(
                                              label: 'User',
                                              icon: Icons.person_outline,
                                              selected: _selectedRole == 'user',
                                              onTap: () => setState(
                                                () => _selectedRole = 'user',
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: RoleChip(
                                              label: 'Staff',
                                              icon: Icons.badge_outlined,
                                              selected:
                                                  _selectedRole == 'staff',
                                              onTap: () => setState(
                                                () => _selectedRole = 'staff',
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 24),

                                      // Email
                                      TextField(
                                        controller: _emailController,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        style: const TextStyle(
                                          color: AppColors.textLight,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        decoration: _fieldDecoration(
                                          label: 'Email',
                                          icon: Icons.email_outlined,
                                        ),
                                      ),

                                      const SizedBox(height: 16),

                                      // Password
                                      TextField(
                                        controller: _passwordController,
                                        obscureText: _obscurePassword,
                                        style: const TextStyle(
                                          color: AppColors.textLight,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        decoration: _fieldDecoration(
                                          label: 'Password',
                                          icon: Icons.lock_outline,
                                          suffixIcon: IconButton(
                                            onPressed: () {
                                              setState(() {
                                                _obscurePassword =
                                                    !_obscurePassword;
                                              });
                                            },
                                            icon: Icon(
                                              _obscurePassword
                                                  ? Icons
                                                        .visibility_off_outlined
                                                  : Icons.visibility_outlined,
                                              color:
                                                  AppColors.iconDarkSecondary,
                                            ),
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 32),

                                      // Login
                                      BlocBuilder<AuthBloc, AuthState>(
                                        builder: (context, state) {
                                          if (state is AuthLoading) {
                                            return const Center(
                                              child: CircularProgressIndicator(
                                                color: AppColors.primary,
                                              ),
                                            );
                                          }

                                          return SizedBox(
                                            height: 58,
                                            child: ElevatedButton(
                                              onPressed: _login,
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    AppColors.primary,
                                                foregroundColor:
                                                    AppColors.onPrimary,
                                                elevation: 0,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                              ),
                                              child: const Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    'Login',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      letterSpacing: 0.5,
                                                    ),
                                                  ),
                                                  SizedBox(width: 8),
                                                  Icon(
                                                    Icons.arrow_forward_rounded,
                                                    size: 20,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),

                                      const SizedBox(height: 28),

                                      Row(
                                        children: [
                                          const Expanded(
                                            child: Divider(
                                              color: AppColors.borderLight,
                                              thickness: 1,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                            ),
                                            child: Text(
                                              'OR CONTINUE WITH',
                                              style: TextStyle(
                                                color: AppColors
                                                    .textLightSecondary,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w800,
                                                letterSpacing: 1.2,
                                              ),
                                            ),
                                          ),
                                          const Expanded(
                                            child: Divider(
                                              color: AppColors.borderLight,
                                              thickness: 1,
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 28),

                                      // Google
                                      SizedBox(
                                        height: 56,
                                        child: OutlinedButton.icon(
                                          onPressed: _googleLogin,
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor:
                                                AppColors.textLight,
                                            side: const BorderSide(
                                              color: AppColors.borderLight,
                                              width: 1.5,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                          ),
                                          icon: const Icon(
                                            Icons.login_rounded,
                                            color: AppColors.iconDark,
                                          ),
                                          label: const Text(
                                            'Continue with Google',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.textLight,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Register Bottom
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Don't have an account? ",
                                  style: TextStyle(
                                    color: AppColors.textLightSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder: (context, animation, secondaryAnimation) => const RegisterPage(),
                                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                          return FadeTransition(
                                            opacity: animation,
                                            child: child,
                                          );
                                        },
                                        transitionDuration: const Duration(milliseconds: 400),
                                      ),
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.textLight,
                                    padding: EdgeInsets.zero,
                                  ),
                                  child: const Text(
                                    'Register',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
