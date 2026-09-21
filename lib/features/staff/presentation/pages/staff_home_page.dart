import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:service_hub_ai/core/service/service_locator.dart';
import 'package:service_hub_ai/features/booking/presentation/bloc/booking_bloc.dart';
import 'package:service_hub_ai/features/booking/presentation/bloc/booking_event.dart';
import 'package:service_hub_ai/features/booking/presentation/bloc/booking_state.dart';
import 'package:service_hub_ai/features/staff/domain/entities/staff_profile.dart';
import 'package:service_hub_ai/features/staff/presentation/bloc/staff_profile_event.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/staff_service.dart';
import '../bloc/staff_service_bloc.dart';
import '../bloc/staff_service_event.dart';
import '../bloc/staff_service_state.dart';
import '../bloc/staff_profile_bloc.dart';
import '../bloc/staff_profile_state.dart';

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
          bloc.add(
            LoadStaffServices(
              staffUid: user.uid,
            ),
          );
        }

        return bloc;
      },
    ),

    BlocProvider<StaffProfileBloc>(
      create: (_) {
        final bloc = sl<StaffProfileBloc>();

        if (user != null) {
          bloc.add(
            LoadStaffProfile(
              staffUid: user.uid,
            ),
          );

          bloc.add(
            UpdateStaffLocationRequested(
              staffUid: user.uid,
            ),
          );
        }

        return bloc;
      },
    ),

    // BOOKING
    BlocProvider<BookingBloc>(
      create: (_) {
        final bloc = sl<BookingBloc>();

        if (user != null) {
          bloc.add(
            LoadStaffBookingsRequested(
              staffId: user.uid,
            ),
          );
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
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: AppColors.surface,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: const Row(children: [
              Icon(Icons.check_circle_rounded, color: AppColors.primary),
              SizedBox(width: 12),
              Text('Service added!', style: TextStyle(color: AppColors.textLight)),
            ]),
          ));
        }
        if (state is StaffServiceError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: AppColors.surface,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: Row(children: [
              const Icon(Icons.error_rounded, color: Colors.redAccent),
              const SizedBox(width: 12),
              Expanded(child: Text(state.message, style: const TextStyle(color: AppColors.textLight))),
            ]),
          ));
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 100),
          child: Builder(builder: (ctx) => _GlowFab(onPressed: () => _showAddServiceDialog(ctx))),
        ),
        body: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── HEADER ───────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: Row(
                    children: [
                      // Avatar with profile image
                      BlocBuilder<StaffProfileBloc, StaffProfileState>(
                        builder: (context, state) {
                          final imageUrl = state is StaffProfileLoaded ? state.profile.profileImage : null;
                          return Container(
                            width: 50, height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary.withValues(alpha: 0.15),
                              border: Border.all(color: AppColors.primary.withValues(alpha: 0.5), width: 2),
                              image: imageUrl != null
                                  ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover)
                                  : null,
                            ),
                            child: imageUrl == null
                                ? Center(child: Text(
                                    displayName[0].toUpperCase(),
                                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 20),
                                  ))
                                : null,
                          );
                        },
                      ),
                      const SizedBox(width: 14),
                      // Greeting
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_greeting(), style: const TextStyle(color: AppColors.textLightSecondary, fontSize: 12)),
                            Text(displayName, style: const TextStyle(color: AppColors.textLight, fontSize: 20, fontWeight: FontWeight.w800, height: 1.2)),
                          ],
                        ),
                      ),
                      // Status pill
                      BlocBuilder<StaffProfileBloc, StaffProfileState>(
                        builder: (context, profileState) {
                          final isOnline = profileState is StaffProfileLoaded ? profileState.profile.isOnline : false;
                          return GestureDetector(
                            onTap: () {
                              if (profileState is! StaffProfileLoaded) return;
                              final profile = profileState.profile;
                              final u = FirebaseAuth.instance.currentUser;
                              if (u == null) return;
                              context.read<StaffProfileBloc>().add(UpdateStaffProfileRequested(
                                staffUid: u.uid, isSilent: true,
                                profile: StaffProfile(
                                  uid: profile.uid, name: profile.name, email: profile.email,
                                  phone: profile.phone, profileImage: profile.profileImage,
                                  latitude: profile.latitude, longitude: profile.longitude,
                                  isOnline: !isOnline,
                                ),
                              ));
                            },
                            child: _StatusPill(isOnline: isOnline),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // ── HERO AVAILABILITY CARD ────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: BlocBuilder<StaffProfileBloc, StaffProfileState>(
                    builder: (context, state) {
                      final isOnline = state is StaffProfileLoaded ? state.profile.isOnline : false;
                      final locationName = state is StaffProfileLoaded ? (state.profile.locationName ?? '') : '';
                      const activeColor = Color(0xFF00E676);
                      return GestureDetector(
                        onTap: () {
                          if (state is! StaffProfileLoaded) return;
                          final profile = state.profile;
                          final u = FirebaseAuth.instance.currentUser;
                          if (u == null) return;
                          context.read<StaffProfileBloc>().add(UpdateStaffProfileRequested(
                            staffUid: u.uid, isSilent: true,
                            profile: StaffProfile(
                              uid: profile.uid, name: profile.name, email: profile.email,
                              phone: profile.phone, profileImage: profile.profileImage,
                              latitude: profile.latitude, longitude: profile.longitude,
                              isOnline: !isOnline,
                            ),
                          ));
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
                                      ? [activeColor.withValues(alpha: 0.12), activeColor.withValues(alpha: 0.04)]
                                      : [Colors.white.withValues(alpha: 0.05), Colors.white.withValues(alpha: 0.02)],
                                ),
                                border: Border.all(
                                  color: isOnline ? activeColor.withValues(alpha: 0.35) : Colors.white.withValues(alpha: 0.08),
                                  width: 1.5,
                                ),
                                boxShadow: isOnline ? [
                                  BoxShadow(color: activeColor.withValues(alpha: 0.12), blurRadius: 30, spreadRadius: -5, offset: const Offset(0, 8)),
                                ] : [],
                              ),
                              child: Row(
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 400),
                                    width: 52, height: 52,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isOnline ? activeColor.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.06),
                                      border: Border.all(
                                        color: isOnline ? activeColor.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.1),
                                      ),
                                    ),
                                    child: Icon(
                                      isOnline ? Icons.wifi_rounded : Icons.wifi_off_rounded,
                                      color: isOnline ? activeColor : AppColors.textLightSecondary,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        AnimatedSwitcher(
                                          duration: const Duration(milliseconds: 300),
                                          child: Text(
                                            isOnline ? 'Available for Bookings' : 'Currently Offline',
                                            key: ValueKey(isOnline),
                                            style: TextStyle(
                                              color: isOnline ? activeColor : AppColors.textLightSecondary,
                                              fontSize: 15, fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          isOnline
                                              ? (locationName.isNotEmpty ? '📍 $locationName' : 'Tap here to go offline')
                                              : 'Tap here to go online',
                                          style: const TextStyle(color: AppColors.textLightSecondary, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.power_settings_new_rounded,
                                    color: isOnline ? activeColor.withValues(alpha: 0.6) : AppColors.textLightSecondary.withValues(alpha: 0.4),
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

              // ── STATS ROW ─────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: BlocBuilder<StaffServiceBloc, StaffServiceState>(
  builder: (context, serviceState) {
    final serviceCount =
        serviceState is StaffServicesLoaded
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

              // ── SECTION HEADER ────────────────────────────────────────
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(24, 28, 24, 12),
                  child: Text(
                    'MY SERVICES',
                    style: TextStyle(
                      color: AppColors.textLightSecondary,
                      fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),

              // ── SERVICES LIST ─────────────────────────────────────────
              const _ServicesSliver(),

              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddServiceDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withValues(alpha: 0.6),
      transitionDuration: const Duration(milliseconds: 350),
      transitionBuilder: (ctx, anim, _, child) => FadeTransition(
        opacity: anim,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.92, end: 1.0).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
      ),
      pageBuilder: (ctx, _, __) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
                ),
                padding: const EdgeInsets.all(28),
                child: Material(
                  color: Colors.transparent,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.add_rounded, color: AppColors.primary, size: 22),
                        ),
                        const SizedBox(width: 14),
                        const Text('Add New Service', style: TextStyle(color: AppColors.textLight, fontSize: 18, fontWeight: FontWeight.w800)),
                      ]),
                      const SizedBox(height: 24),
                      _DialogTextField(controller: nameController, label: 'Service Name', hint: 'e.g. AC Repair, Plumbing', icon: Icons.build_rounded),
                      const SizedBox(height: 16),
                      _DialogTextField(controller: descriptionController, label: 'Description', hint: 'Describe what you offer...', icon: Icons.description_rounded, maxLines: 3),
                      const SizedBox(height: 28),
                      Row(children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.textLightSecondary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: AppColors.borderLight)),
                            ),
                            child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () {
                              final name = nameController.text.trim();
                              final description = descriptionController.text.trim();
                              if (name.isEmpty) return;
                              final u = FirebaseAuth.instance.currentUser;
                              if (u == null) return;
                              context.read<StaffServiceBloc>().add(AddStaffServiceRequested(
                                staffUid: u.uid,
                                service: StaffService(id: DateTime.now().millisecondsSinceEpoch.toString(), name: name, description: description),
                              ));
                              Navigator.pop(ctx);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary, foregroundColor: Colors.white, elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: const Text('Add Service', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                          ),
                        ),
                      ]),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
// ─── Services Sliver ─────────────────────────────────────────────────────────

class _ServicesSliver extends StatelessWidget {
  const _ServicesSliver();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StaffServiceBloc, StaffServiceState>(
      builder: (context, state) {
        if (state is StaffServiceLoading) {
          return const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          );
        }
        if (state is StaffServicesLoaded && state.services.isNotEmpty) {
          return SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ServiceCard(service: state.services[index]),
                ),
                childCount: state.services.length,
              ),
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
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                  ),
                  child: const Icon(Icons.build_rounded, color: AppColors.primary, size: 36),
                ),
                const SizedBox(height: 20),
                const Text('No services yet', style: TextStyle(color: AppColors.textLight, fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                const Text('Tap + to add your first service', textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textLightSecondary, fontSize: 14)),
              ],
            ),
          ),
        );
      },
    );
  }
}


// ─── Service Card ────────────────────────────────────────────────────────────

class _ServiceCard extends StatelessWidget {
  final dynamic service;
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
                // Glowing Icon Container
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

                // Content
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

                // Chevron
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

// ─── Stat Card ──────────────────────────────────────────────────────────────

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

// ─── Dialog Text Field ──────────────────────────────────────────────────────

class _DialogTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final int maxLines;

  const _DialogTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: AppColors.textLight),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(
          color: AppColors.textLightSecondary.withValues(alpha: 0.5),
        ),
        labelStyle: const TextStyle(color: AppColors.textLightSecondary),
        prefixIcon: Icon(icon, color: AppColors.iconLight, size: 20),
        filled: true,
        fillColor: Colors.black.withValues(alpha: 0.15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
      ),
    );
  }
}

// ─── Glowing FAB ────────────────────────────────────────────────────────────

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
      builder: (_, _) {
        return GestureDetector(
          onTap: widget.onPressed,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(
                    alpha: 0.3 + 0.2 * _pulse.value,
                  ),
                  blurRadius: 20 + 10 * _pulse.value,
                  spreadRadius: 2 + 4 * _pulse.value,
                ),
              ],
            ),
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
          ),
        );
      },
    );
  }
}

// ──────────────────────────────────────────────
// Premium Status Pill
// ──────────────────────────────────────────────

class _StatusPill extends StatefulWidget {
  final bool isOnline;
  const _StatusPill({required this.isOnline});

  @override
  State<_StatusPill> createState() => _StatusPillState();
}

class _StatusPillState extends State<_StatusPill>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = widget.isOnline;

    final activeColor = const Color(0xFF00E676);       // bright green
    final inactiveColor = const Color(0xFF757575);     // grey

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: isOnline
            ? activeColor.withValues(alpha: 0.10)
            : inactiveColor.withValues(alpha: 0.08),
        border: Border.all(
          color: isOnline
              ? activeColor.withValues(alpha: 0.45)
              : inactiveColor.withValues(alpha: 0.25),
          width: 1.2,
        ),
        boxShadow: isOnline
            ? [
                BoxShadow(
                  color: activeColor.withValues(alpha: 0.25),
                  blurRadius: 12,
                  spreadRadius: -1,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Power icon
          Icon(
            isOnline
                ? Icons.power_settings_new_rounded
                : Icons.power_off_outlined,
            size: 13,
            color: isOnline ? activeColor : inactiveColor,
          ),
          const SizedBox(width: 6),

          // Pulsing dot (only when online)
          if (isOnline)
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, _) => Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: activeColor.withValues(alpha: _pulseAnimation.value),
                  boxShadow: [
                    BoxShadow(
                      color: activeColor.withValues(alpha: _pulseAnimation.value * 0.6),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            )
          else
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: inactiveColor.withValues(alpha: 0.5),
              ),
            ),

          const SizedBox(width: 6),

          // Label
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Text(
              isOnline ? 'Online' : 'Offline',
              key: ValueKey(isOnline),
              style: TextStyle(
                color: isOnline ? activeColor : inactiveColor,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
