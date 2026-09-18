import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/staff_animated_background.dart';
import '../../domain/entities/staff_profile.dart';
import '../bloc/staff_profile_bloc.dart';
import '../bloc/staff_profile_event.dart';
import '../bloc/staff_profile_state.dart';

class EditStaffProfilePage extends StatefulWidget {
  final StaffProfile profile;

  const EditStaffProfilePage({
    super.key,
    required this.profile,
  });

  @override
  State<EditStaffProfilePage> createState() => _EditStaffProfilePageState();
}

class _EditStaffProfilePageState extends State<EditStaffProfilePage> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _phoneController = TextEditingController(text: widget.profile.phone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _save(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final updated = StaffProfile(
      uid: widget.profile.uid,
      name: _nameController.text.trim(),
      email: widget.profile.email,
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      profileImage: widget.profile.profileImage,
      latitude: widget.profile.latitude,
      longitude: widget.profile.longitude,
      isOnline: widget.profile.isOnline,
    );

    context.read<StaffProfileBloc>().add(
          UpdateStaffProfileRequested(staffUid: user.uid, profile: updated),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<StaffProfileBloc, StaffProfileState>(
      listener: (context, state) {
        if (state is StaffProfileLoaded) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.green.shade800,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              content: const Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: Colors.white),
                  SizedBox(width: 10),
                  Text('Profile updated!',
                      style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          );
          Navigator.pop(context);
        }
        if (state is StaffProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.red.shade800,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              content: Text(state.message,
                  style: const TextStyle(color: Colors.white)),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: Stack(
          children: [
            // Animated Background
            const StaffAnimatedBackground(),

            SafeArea(
              child: Column(
                children: [
                  // ── AppBar ──────────────────────────────────────────────
                  Padding(
                    padding:
                        const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: BackdropFilter(
                            filter:
                                ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                    color:
                                        Colors.white.withValues(alpha: 0.08)),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                                    color: AppColors.textLight, size: 18),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          'Edit Profile',
                          style: TextStyle(
                            color: AppColors.textLight,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Body ────────────────────────────────────────────────
                  Expanded(
                    child: SingleChildScrollView(
                      padding:
                          const EdgeInsets.fromLTRB(24, 0, 24, 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Avatar ──────────────────────────────────────
                          Center(
                            child: Stack(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.5),
                                      width: 2,
                                    ),
                                  ),
                                  child: CircleAvatar(
                                    radius: 58,
                                    backgroundColor: AppColors.primary
                                        .withValues(alpha: 0.1),
                                    backgroundImage:
                                        widget.profile.profileImage != null
                                            ? NetworkImage(
                                                widget.profile.profileImage!)
                                            : null,
                                    child: widget.profile.profileImage == null
                                        ? const Icon(
                                            Icons.person_rounded,
                                            size: 50,
                                            color: AppColors.primary,
                                          )
                                        : null,
                                  ),
                                ),
                                Positioned(
                                  bottom: 4,
                                  right: 4,
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primary
                                              .withValues(alpha: 0.4),
                                          blurRadius: 10,
                                        ),
                                      ],
                                    ),
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(Icons.camera_alt_rounded,
                                          size: 18, color: Colors.white),
                                      onPressed: () {
                                        // TODO: image picker
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 36),

                          // ── Name ────────────────────────────────────────
                          _FieldLabel('Full Name'),
                          const SizedBox(height: 8),
                          _GlassTextField(
                            controller: _nameController,
                            hint: 'Enter your name',
                            icon: Icons.person_outline_rounded,
                          ),

                          const SizedBox(height: 24),

                          // ── Email (read-only) ───────────────────────────
                          _FieldLabel('Email'),
                          const SizedBox(height: 8),
                          _GlassTextField(
                            controller: TextEditingController(
                                text: widget.profile.email),
                            hint: 'Email',
                            icon: Icons.email_outlined,
                            readOnly: true,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.lock_outline_rounded,
                                  size: 14,
                                  color: AppColors.textLightSecondary
                                      .withValues(alpha: 0.5)),
                              const SizedBox(width: 6),
                              Text(
                                'Email cannot be changed',
                                style: TextStyle(
                                  color: AppColors.textLightSecondary
                                      .withValues(alpha: 0.5),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // ── Phone ────────────────────────────────────────
                          _FieldLabel('Phone Number'),
                          const SizedBox(height: 8),
                          _GlassTextField(
                            controller: _phoneController,
                            hint: 'Enter your phone number',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                          ),

                          const SizedBox(height: 40),

                          // ── Save Button ──────────────────────────────────
                          BlocBuilder<StaffProfileBloc, StaffProfileState>(
                            builder: (context, state) {
                              final isLoading =
                                  state is StaffProfileLoading;
                              return Container(
                                width: double.infinity,
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.primary,
                                      AppColors.primary
                                          .withValues(alpha: 0.75),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.35),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton.icon(
                                  onPressed:
                                      isLoading ? null : () => _save(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    foregroundColor: Colors.white,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                  ),
                                  icon: isLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(Icons.save_rounded,
                                          size: 20),
                                  label: Text(
                                    isLoading ? 'Saving…' : 'Save Changes',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: AppColors.textLightSecondary.withValues(alpha: 0.8),
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _GlassTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool readOnly;
  final TextInputType? keyboardType;

  const _GlassTextField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.readOnly = false,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: TextField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: keyboardType,
          style: TextStyle(
            color: readOnly
                ? AppColors.textLightSecondary.withValues(alpha: 0.5)
                : AppColors.textLight,
            fontSize: 15,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppColors.textLightSecondary.withValues(alpha: 0.4),
            ),
            prefixIcon: Icon(
              icon,
              color: readOnly
                  ? AppColors.iconLight.withValues(alpha: 0.4)
                  : AppColors.primary,
              size: 22,
            ),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.04),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide:
                  BorderSide(color: Colors.white.withValues(alpha: 0.08)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide:
                  BorderSide(color: Colors.white.withValues(alpha: 0.08)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                  color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ),
    );
  }
}