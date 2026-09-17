import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/animated_background.dart';
import '../widgets/role_chip.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String _selectedRole = 'user';
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _register() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    context.read<AuthBloc>().add(
          RegisterRequested(
            name: name,
            email: email,
            password: password,
            role: _selectedRole,
          ),
        );
  }

  InputDecoration _fieldDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.textLightSecondary, fontWeight: FontWeight.w500),
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
            Navigator.pop(context);
          }

          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: AnimatedBackground(
          child: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Column(
                    children: [
                      // Header with back button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(
                                Icons.arrow_back_rounded,
                                color: AppColors.iconLight,
                                size: 28,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Scrollable content
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Hero Header
                              Padding(
                                padding: const EdgeInsets.fromLTRB(28, 0, 28, 40),
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
                                            color: Colors.black.withValues(alpha: 0.2),
                                            blurRadius: 20,
                                            offset: const Offset(0, 10),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.person_add_alt_1_rounded,
                                        size: 40,
                                        color: AppColors.iconDark,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    const Text(
                                      'Create Account',
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
                                      'Join as a user or service professional',
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
                                  filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 20),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.01),
                                      borderRadius: BorderRadius.circular(32),
                                      border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.1),
                                          blurRadius: 30,
                                          offset: const Offset(0, 15),
                                        ),
                                      ],
                                    ),
                                    padding: const EdgeInsets.fromLTRB(28, 36, 28, 32),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
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
                                            onTap: () => setState(() => _selectedRole = 'user'),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: RoleChip(
                                            label: 'Staff',
                                            icon: Icons.badge_outlined,
                                            selected: _selectedRole == 'staff',
                                            onTap: () => setState(() => _selectedRole = 'staff'),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 32),

                                    // Name
                                    TextField(
                                      controller: _nameController,
                                      style: const TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w600),
                                      decoration: _fieldDecoration(
                                        label: 'Full Name',
                                        icon: Icons.person_outline,
                                      ),
                                    ),

                                    const SizedBox(height: 16),

                                    // Email
                                    TextField(
                                      controller: _emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      style: const TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w600),
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
                                      style: const TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w600),
                                      decoration: _fieldDecoration(
                                        label: 'Password',
                                        icon: Icons.lock_outline,
                                        suffixIcon: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              _obscurePassword = !_obscurePassword;
                                            });
                                          },
                                          icon: Icon(
                                            _obscurePassword
                                                ? Icons.visibility_off_outlined
                                                : Icons.visibility_outlined,
                                            color: AppColors.iconDarkSecondary,
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 32),

                                    // Register
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
                                            onPressed: _register,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.primary,
                                              foregroundColor: AppColors.onPrimary,
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(16),
                                              ),
                                            ),
                                            child: const Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'Create Account',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w700,
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                                SizedBox(width: 8),
                                                Icon(Icons.arrow_forward_rounded, size: 20),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Login Bottom
                          Center(
                            child: TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.textLight,
                              ),
                              child: const Text(
                                'Already have an account? Login',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
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
    ));
  }
}

