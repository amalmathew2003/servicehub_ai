import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../bloc/staff_profile_bloc.dart';
import '../bloc/staff_profile_event.dart';
import '../bloc/staff_profile_state.dart';
import 'edit_staff_profile_page.dart';

class StaffProfilePage extends StatelessWidget {
  const StaffProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 120),
              child: Column(
                children: [
                  // Hero Profile Card
                  ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primary.withValues(alpha: 0.15),
                              Colors.white.withValues(alpha: 0.05),
                            ],
                          ),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Profile Image
                            Container(
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
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                profile.email,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textLightSecondary.withValues(alpha: 0.9),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'ACCOUNT DETAILS',
                      style: TextStyle(
                        color: AppColors.textLightSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Profile Information
                  _ProfileItem(
                    icon: Icons.person_outline_rounded,
                    title: 'Name',
                    value: profile.name,
                  ),

                  _ProfileItem(
                    icon: Icons.phone_outlined,
                    title: 'Phone',
                    value: profile.phone ?? 'Not added',
                  ),
                  _LocationProfileItem(
                    latitude: profile.latitude,
                    longitude: profile.longitude,
                  ),

                  const SizedBox(height: 32),

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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: context.read<StaffProfileBloc>(),
                              child: EditStaffProfilePage(profile: profile),
                            ),
                          ),
                        );
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

                  const SizedBox(height: 16),

                  // Sign Out Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        context.read<AuthBloc>().add(const LogoutRequested());
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: BorderSide(
                          color: Colors.redAccent.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.logout_rounded, size: 20),
                      label: const Text(
                        'Sign Out',
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
    );
  }
}

class _ProfileItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _ProfileItem({
    required this.icon,
    required this.title,
    required this.value,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(icon, color: AppColors.primary, size: 22),
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
                              color: AppColors.textLightSecondary.withValues(
                                alpha: 0.7,
                              ),
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
                    ?trailing,
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

class _LocationProfileItem extends StatelessWidget {
  final double? latitude;
  final double? longitude;

  const _LocationProfileItem({
    required this.latitude,
    required this.longitude,
  });

  Future<String> _getAddress() async {
    if (latitude == null || longitude == null) {
      return 'Tap to update location';
    }
    try {
      final geocoding = Geocoding();
      final placemarks = await geocoding.placemarkFromCoordinates(latitude!, longitude!);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final parts = <String>[
          if (place.subLocality != null && place.subLocality!.isNotEmpty) place.subLocality!,
          if (place.locality != null && place.locality!.isNotEmpty) place.locality!,
          if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) place.administrativeArea!,
        ].join(', ');
        return parts.isNotEmpty
            ? parts
            : '${latitude!.toStringAsFixed(4)}, ${longitude!.toStringAsFixed(4)}';
      }
    } catch (_) {}
    return '${latitude!.toStringAsFixed(4)}, ${longitude!.toStringAsFixed(4)}';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getAddress(),
      builder: (context, snapshot) {
        final address = snapshot.connectionState == ConnectionState.waiting
            ? (latitude != null
                ? '${latitude!.toStringAsFixed(4)}, ${longitude!.toStringAsFixed(4)}'
                : 'Tap to update location')
            : (snapshot.data ?? 'Tap to update location');

        return _ProfileItem(
          icon: Icons.location_on_outlined,
          title: 'Location',
          value: address,
          trailing: const Icon(
            Icons.my_location_rounded,
            color: AppColors.primary,
            size: 20,
          ),
          onTap: () {
            final user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              context.read<StaffProfileBloc>().add(
                    UpdateStaffLocationRequested(staffUid: user.uid),
                  );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Updating location...'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
        );
      },
    );
  }
}

