import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:service_hub_ai/core/service/service_locator.dart';
import 'package:service_hub_ai/core/theme/app_colors.dart';
import 'package:service_hub_ai/features/booking/presentation/bloc/booking_bloc.dart';
import 'package:service_hub_ai/features/booking/presentation/bloc/booking_event.dart';
import 'package:service_hub_ai/features/booking/presentation/bloc/booking_state.dart';
import 'package:service_hub_ai/features/booking/presentation/widgets/staff_booking_requests_sliver.dart';
import 'package:service_hub_ai/features/staff/domain/entities/staff_profile.dart';
import 'package:service_hub_ai/features/staff/presentation/bloc/staff_profile_bloc.dart';
import 'package:service_hub_ai/features/staff/presentation/bloc/staff_profile_event.dart';
import 'package:service_hub_ai/features/staff/presentation/bloc/staff_profile_state.dart';
import 'package:service_hub_ai/features/staff/presentation/bloc/staff_service_bloc.dart';
import 'package:service_hub_ai/features/staff/presentation/bloc/staff_service_event.dart';
import 'package:service_hub_ai/features/staff/presentation/bloc/staff_service_state.dart';
import 'package:service_hub_ai/features/staff/presentation/widgets/add_staff_service_dialog.dart';
import 'package:service_hub_ai/features/staff/presentation/widgets/staff_glow_fab.dart';
import 'package:service_hub_ai/features/staff/presentation/widgets/staff_services_sliver.dart';
import 'package:service_hub_ai/features/staff/presentation/widgets/staff_stat_card.dart';
import 'package:service_hub_ai/features/staff/presentation/widgets/staff_status_pill.dart';

class StaffHomePage extends StatelessWidget {
  const StaffHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return MultiBlocProvider(
      providers: [
        BlocProvider<StaffServiceBloc>(
          create: (_) {
            final bloc = sl<StaffServiceBloc>();

            if (user != null) {
              bloc.add(LoadStaffServices(staffUid: user.uid));
            }

            return bloc;
          },
        ),
        BlocProvider<StaffProfileBloc>(
          create: (_) {
            final bloc = sl<StaffProfileBloc>();

            if (user != null) {
              bloc.add(LoadStaffProfile(staffUid: user.uid));
              bloc.add(UpdateStaffLocationRequested(staffUid: user.uid));
            }

            return bloc;
          },
        ),
        BlocProvider<BookingBloc>(
          create: (_) {
            final bloc = sl<BookingBloc>();

            if (user != null) {
              bloc.add(LoadStaffBookingsRequested(staffId: user.uid));
            }

            return bloc;
          },
        ),
      ],
      child: const _StaffHomeView(),
    );
  }
}

class _StaffHomeView extends StatelessWidget {
  const _StaffHomeView();

  String _greeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) return 'Good morning,';
    if (hour < 17) return 'Good afternoon,';

    return 'Good evening,';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    final displayName = user?.displayName?.isNotEmpty == true
        ? user!.displayName!.split(' ').first
        : (user?.email?.split('@').first ?? 'Staff');

    return BlocListener<StaffServiceBloc, StaffServiceState>(
      listener: (context, state) {
        if (state is StaffServiceAdded) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.surface,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              content: const Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: AppColors.primary),
                  SizedBox(width: 12),
                  Text(
                    'Service added!',
                    style: TextStyle(color: AppColors.textLight),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is StaffServiceError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.surface,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              content: Row(
                children: [
                  const Icon(Icons.error_rounded, color: Colors.redAccent),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      state.message,
                      style: const TextStyle(color: AppColors.textLight),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 100),
          child: Builder(
            builder: (ctx) =>
                StaffGlowFab(onPressed: () => _showAddServiceDialog(ctx)),
          ),
        ),
        body: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── HEADER ──────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: Row(
                    children: [
                      BlocBuilder<StaffProfileBloc, StaffProfileState>(
                        builder: (context, state) {
                          final imageUrl = state is StaffProfileLoaded
                              ? state.profile.profileImage
                              : null;

                          return Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary.withValues(alpha: 0.15),
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.5),
                                width: 2,
                              ),
                              image: imageUrl != null
                                  ? DecorationImage(
                                      image: NetworkImage(imageUrl),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: imageUrl == null
                                ? Center(
                                    child: Text(
                                      displayName.isNotEmpty
                                          ? displayName[0].toUpperCase()
                                          : 'S',
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 20,
                                      ),
                                    ),
                                  )
                                : null,
                          );
                        },
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _greeting(),
                              style: const TextStyle(
                                color: AppColors.textLightSecondary,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              displayName,
                              style: const TextStyle(
                                color: AppColors.textLight,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      BlocBuilder<StaffProfileBloc, StaffProfileState>(
                        builder: (context, profileState) {
                          final isOnline = profileState is StaffProfileLoaded
                              ? profileState.profile.isOnline
                              : false;

                          return GestureDetector(
                            onTap: () {
                              if (profileState is! StaffProfileLoaded) return;

                              final profile = profileState.profile;
                              final currentUser =
                                  FirebaseAuth.instance.currentUser;

                              if (currentUser == null) return;

                              context.read<StaffProfileBloc>().add(
                                UpdateStaffProfileRequested(
                                  staffUid: currentUser.uid,
                                  isSilent: true,
                                  profile: StaffProfile(
                                    uid: profile.uid,
                                    name: profile.name,
                                    email: profile.email,
                                    phone: profile.phone,
                                    profileImage: profile.profileImage,
                                    latitude: profile.latitude,
                                    longitude: profile.longitude,
                                    isOnline: !isOnline,
                                  ),
                                ),
                              );
                            },
                            child: StaffStatusPill(isOnline: isOnline),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // ── AVAILABILITY CARD ────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: BlocBuilder<StaffProfileBloc, StaffProfileState>(
                    builder: (context, state) {
                      final isOnline = state is StaffProfileLoaded
                          ? state.profile.isOnline
                          : false;

                      final locationName = state is StaffProfileLoaded
                          ? (state.profile.locationName ?? '')
                          : '';

                      const activeColor = Color(0xFF00E676);

                      return GestureDetector(
                        onTap: () {
                          if (state is! StaffProfileLoaded) return;

                          final profile = state.profile;
                          final currentUser = FirebaseAuth.instance.currentUser;

                          if (currentUser == null) return;

                          context.read<StaffProfileBloc>().add(
                            UpdateStaffProfileRequested(
                              staffUid: currentUser.uid,
                              isSilent: true,
                              profile: StaffProfile(
                                uid: profile.uid,
                                name: profile.name,
                                email: profile.email,
                                phone: profile.phone,
                                profileImage: profile.profileImage,
                                latitude: profile.latitude,
                                longitude: profile.longitude,
                                isOnline: !isOnline,
                              ),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeOutCubic,
                              padding: const EdgeInsets.all(22),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: isOnline
                                      ? [
                                          activeColor.withValues(alpha: 0.12),
                                          activeColor.withValues(alpha: 0.04),
                                        ]
                                      : [
                                          Colors.white.withValues(alpha: 0.05),
                                          Colors.white.withValues(alpha: 0.02),
                                        ],
                                ),
                                border: Border.all(
                                  color: isOnline
                                      ? activeColor.withValues(alpha: 0.35)
                                      : Colors.white.withValues(alpha: 0.08),
                                  width: 1.5,
                                ),
                                boxShadow: isOnline
                                    ? [
                                        BoxShadow(
                                          color: activeColor.withValues(
                                            alpha: 0.12,
                                          ),
                                          blurRadius: 30,
                                          spreadRadius: -5,
                                          offset: const Offset(0, 8),
                                        ),
                                      ]
                                    : [],
                              ),
                              child: Row(
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 400),
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isOnline
                                          ? activeColor.withValues(alpha: 0.15)
                                          : Colors.white.withValues(
                                              alpha: 0.06,
                                            ),
                                      border: Border.all(
                                        color: isOnline
                                            ? activeColor.withValues(alpha: 0.4)
                                            : Colors.white.withValues(
                                                alpha: 0.1,
                                              ),
                                      ),
                                    ),
                                    child: Icon(
                                      isOnline
                                          ? Icons.wifi_rounded
                                          : Icons.wifi_off_rounded,
                                      color: isOnline
                                          ? activeColor
                                          : AppColors.textLightSecondary,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        AnimatedSwitcher(
                                          duration: const Duration(
                                            milliseconds: 300,
                                          ),
                                          child: Text(
                                            isOnline
                                                ? 'Available for Bookings'
                                                : 'Currently Offline',
                                            key: ValueKey(isOnline),
                                            style: TextStyle(
                                              color: isOnline
                                                  ? activeColor
                                                  : AppColors
                                                        .textLightSecondary,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          isOnline
                                              ? (locationName.isNotEmpty
                                                    ? '📍 $locationName'
                                                    : 'Tap here to go offline')
                                              : 'Tap here to go online',
                                          style: const TextStyle(
                                            color: AppColors.textLightSecondary,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.power_settings_new_rounded,
                                    color: isOnline
                                        ? activeColor.withValues(alpha: 0.6)
                                        : AppColors.textLightSecondary
                                              .withValues(alpha: 0.4),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // ── STATISTICS ───────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: BlocBuilder<StaffServiceBloc, StaffServiceState>(
                    builder: (context, serviceState) {
                      final serviceCount = serviceState is StaffServicesLoaded
                          ? serviceState.services.length
                          : 0;

                      return BlocBuilder<BookingBloc, BookingState>(
                        builder: (context, bookingState) {
                          final bookingCount =
                              bookingState is StaffBookingsLoaded
                              ? bookingState.bookings.length
                              : 0;

                          return Row(
                            children: [
                              StaffStatCard(
                                label: 'Services',
                                value: serviceCount.toString(),
                                icon: Icons.build_rounded,
                              ),
                              const SizedBox(width: 12),
                              StaffStatCard(
                                label: 'Bookings',
                                value: bookingCount.toString(),
                                icon: Icons.calendar_month_rounded,
                              ),
                              const SizedBox(width: 12),
                              const StaffStatCard(
                                label: 'Rating',
                                value: '—',
                                icon: Icons.star_rounded,
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ),

              // ── BOOKING REQUESTS HEADING ─────────────────────────────
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(24, 28, 24, 12),
                  child: Text(
                    'BOOKING REQUESTS',
                    style: TextStyle(
                      color: AppColors.textLightSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),

              // ── BOOKING REQUESTS LIST ────────────────────────────────
              const StaffBookingRequestsSliver(),

              // ── SERVICES HEADING ─────────────────────────────────────
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(24, 28, 24, 12),
                  child: Text(
                    'MY SERVICES',
                    style: TextStyle(
                      color: AppColors.textLightSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),

              // ── SERVICES LIST ────────────────────────────────────────
              const StaffServicesSliver(),

              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
        ),
      ),
    );
  }

  /// Opens the separate AI-powered add-services widget.
  void _showAddServiceDialog(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in again to add services.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Reuse the same StaffServiceBloc inside the dialog route.
    final serviceBloc = context.read<StaffServiceBloc>();

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => BlocProvider.value(
        value: serviceBloc,
        child: AddStaffServiceDialog(staffUid: user.uid),
      ),
    );
  }
}
