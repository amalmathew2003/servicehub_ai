import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:service_hub_ai/core/service/service_locator.dart';
import 'package:service_hub_ai/core/theme/app_colors.dart';
import 'package:service_hub_ai/features/booking/presentation/bloc/booking_bloc.dart';
import 'package:service_hub_ai/features/booking/presentation/bloc/booking_event.dart';
import 'package:service_hub_ai/features/booking/presentation/bloc/booking_state.dart';
import 'package:service_hub_ai/features/staff/domain/entities/staff_profile.dart';
import 'package:service_hub_ai/features/staff/presentation/bloc/staff_profile_bloc.dart';
import 'package:service_hub_ai/features/staff/presentation/bloc/staff_profile_event.dart';
import 'package:service_hub_ai/features/staff/presentation/bloc/staff_profile_state.dart';
import 'package:service_hub_ai/features/staff/presentation/bloc/staff_service_bloc.dart';
import 'package:service_hub_ai/features/staff/presentation/bloc/staff_service_event.dart';
import 'package:service_hub_ai/features/staff/presentation/bloc/staff_service_state.dart';
import 'package:service_hub_ai/features/staff/presentation/widgets/add_staff_service_dialog.dart';

import '../../domain/entities/staff_service.dart';

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
                _GlowFab(onPressed: () => _showAddServiceDialog(ctx)),
          ),
        ),
        body: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // HEADER
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
                            child: _StatusPill(isOnline: isOnline),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // AVAILABILITY CARD
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

              // STATISTICS
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
                              _StatCard(
                                label: 'Services',
                                value: serviceCount.toString(),
                                icon: Icons.build_rounded,
                              ),
                              const SizedBox(width: 12),
                              _StatCard(
                                label: 'Bookings',
                                value: bookingCount.toString(),
                                icon: Icons.calendar_month_rounded,
                              ),
                              const SizedBox(width: 12),
                              _StatCard(
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

              // SERVICES HEADING
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

              // SERVICES LIST
              const _ServicesSliver(),

              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
        ),
      ),
    );
  }

  // Opens the separate AI-powered add-services widget.
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

// -----------------------------------------------------------------------------
// SERVICES SLIVER
// -----------------------------------------------------------------------------

class _ServicesSliver extends StatelessWidget {
  const _ServicesSliver();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StaffServiceBloc, StaffServiceState>(
      builder: (context, state) {
        if (state is StaffServiceLoading) {
          return const SliverFillRemaining(
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        if (state is StaffServicesLoaded && state.services.isNotEmpty) {
          return SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ServiceCard(service: state.services[index]),
                );
              }, childCount: state.services.length),
            ),
          );
        }

        return SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: const Icon(
                    Icons.build_rounded,
                    color: AppColors.primary,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'No services yet',
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tap + to add your first service',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textLightSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
// SERVICE CARD
// -----------------------------------------------------------------------------

class _ServiceCard extends StatelessWidget {
  final StaffService service;

  const _ServiceCard({required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.08),
                  Colors.white.withValues(alpha: 0.02),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.2),
                        AppColors.primary.withValues(alpha: 0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        blurRadius: 12,
                        spreadRadius: -2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.design_services_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.name,
                        style: const TextStyle(
                          color: AppColors.textLight,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                        ),
                      ),
                      if (service.description.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          service.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.textLightSecondary.withValues(
                              alpha: 0.8,
                            ),
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: AppColors.textLightSecondary,
                    size: 14,
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

// -----------------------------------------------------------------------------
// STAT CARD
// -----------------------------------------------------------------------------

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: AppColors.primary, size: 20),
                const SizedBox(height: 10),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.textLight,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textLightSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
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

// -----------------------------------------------------------------------------
// STATUS PILL
// -----------------------------------------------------------------------------

class _StatusPill extends StatelessWidget {
  final bool isOnline;

  const _StatusPill({required this.isOnline});

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFF00E676);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isOnline
            ? activeColor.withValues(alpha: 0.1)
            : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isOnline
              ? activeColor.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isOnline ? activeColor : Colors.grey,
            ),
          ),
          const SizedBox(width: 7),
          Text(
            isOnline ? 'ONLINE' : 'OFFLINE',
            style: TextStyle(
              color: isOnline ? activeColor : AppColors.textLightSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.7,
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// GLOWING FLOATING ACTION BUTTON
// -----------------------------------------------------------------------------

class _GlowFab extends StatefulWidget {
  final VoidCallback onPressed;

  const _GlowFab({required this.onPressed});

  @override
  State<_GlowFab> createState() => _GlowFabState();
}

class _GlowFabState extends State<_GlowFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulse = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        final glowOpacity = 0.15 + (_pulse.value * 0.2);

        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: glowOpacity),
                blurRadius: 18 + (_pulse.value * 8),
                spreadRadius: 1 + (_pulse.value * 3),
              ),
            ],
          ),
          child: FloatingActionButton(
            onPressed: widget.onPressed,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: const CircleBorder(),
            child: const Icon(Icons.add_rounded, size: 30),
          ),
        );
      },
    );
  }
}
