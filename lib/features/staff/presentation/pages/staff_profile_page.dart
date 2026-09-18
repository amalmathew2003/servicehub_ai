import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/service/service_locator.dart';
import '../bloc/staff_profile_bloc.dart';
import '../bloc/staff_profile_event.dart';
import '../bloc/staff_profile_state.dart';

class StaffProfilePage extends StatelessWidget {
  const StaffProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    return BlocProvider(
      create: (_) {
        final bloc = sl<StaffProfileBloc>();
        if (user != null) {
          bloc.add(LoadStaffProfile(staffUid: user.uid));
        }
        return bloc;
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'My Profile',
            style: TextStyle(
              color: AppColors.textLight,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: AppColors.textLight),
        ),
        body: BlocBuilder<StaffProfileBloc, StaffProfileState>(
          builder: (context, state) {
            if (state is StaffProfileLoading || state is StaffProfileInitial) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (state is StaffProfileError) {
              return Center(
                child: Text(
                  state.message,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              );
            }

            if (state is StaffProfileLoaded) {
              final profile = state.profile;

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 120),
                child: Column(
                  children: [
                    // Profile Image
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.5),
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 55,
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                          backgroundImage: profile.profileImage != null
                              ? NetworkImage(profile.profileImage!)
                              : null,
                          child: profile.profileImage == null
                              ? const Icon(
                                  Icons.person_rounded,
                                  size: 50,
                                  color: AppColors.primary,
                                )
                              : null,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Name
                    Text(
                      profile.name,
                      style: const TextStyle(
                        color: AppColors.textLight,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Email
                    Text(
                      profile.email,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textLightSecondary.withValues(alpha: 0.8),
                        letterSpacing: 0.5,
                      ),
                    ),

                    const SizedBox(height: 36),

                    // Profile Information
                    _ProfileItem(
                      icon: Icons.person_outline_rounded,
                      title: 'Name',
                      value: profile.name,
                    ),

                    _ProfileItem(
                      icon: Icons.email_outlined,
                      title: 'Email',
                      value: profile.email,
                    ),

                    _ProfileItem(
                      icon: Icons.phone_outlined,
                      title: 'Phone',
                      value: profile.phone ?? 'Not added',
                    ),

                    _ProfileItem(
                      icon: Icons.location_on_outlined,
                      title: 'Location',
                      value: (profile.latitude != null && profile.longitude != null)
                          ? '${profile.latitude!.toStringAsFixed(2)}, ${profile.longitude!.toStringAsFixed(2)}'
                          : 'Location not available',
                    ),

                    const SizedBox(height: 24),

                    // Online Status Glass Card
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.03),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.07),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: profile.isOnline 
                                      ? Colors.green.withValues(alpha: 0.2)
                                      : Colors.grey.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.power_settings_new_rounded,
                                  size: 18,
                                  color: profile.isOnline ? Colors.greenAccent : Colors.grey,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  profile.isOnline ? 'Available for bookings' : 'Offline',
                                  style: const TextStyle(
                                    color: AppColors.textLight,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Switch(
                                value: profile.isOnline,
                                activeColor: Colors.greenAccent,
                                activeTrackColor: Colors.green.withValues(alpha: 0.3),
                                inactiveThumbColor: Colors.grey,
                                inactiveTrackColor: Colors.grey.withValues(alpha: 0.3),
                                onChanged: (value) {
                                  // TODO: Add UpdateStaffProfileRequested event
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 36),

                    // Edit Profile Button
                    Container(
                      width: double.infinity,
                      height: 54,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primary.withValues(alpha: 0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Navigate to Edit Profile
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(Icons.edit_rounded, size: 20),
                        label: const Text(
                          'Edit Profile',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _ProfileItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _ProfileItem({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textLightSecondary.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value,
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.textLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}