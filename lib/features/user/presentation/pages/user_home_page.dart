import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:service_hub_ai/features/ai/presentation/pages/ai_chat_page.dart';

import '../../../../core/service/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/user_profile_bloc.dart';
import '../bloc/user_profile_event.dart';
import '../bloc/user_profile_state.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  late final UserProfileBloc _profileBloc;

  @override
  void initState() {
    super.initState();

    _profileBloc = sl<UserProfileBloc>();

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      _profileBloc.add(LoadUserProfile(userUid: user.uid));
    }
  }

  @override
  void dispose() {
    _profileBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _profileBloc,
      child: const _UserHomeView(),
    );
  }
}

// ============================================================
// HOME VIEW
// ============================================================

class _UserHomeView extends StatefulWidget {
  const _UserHomeView();

  @override
  State<_UserHomeView> createState() => _UserHomeViewState();
}

class _UserHomeViewState extends State<_UserHomeView> {
  bool _locationRequested = false;

  String _greeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return 'Good morning';
    }

    if (hour < 17) {
      return 'Good afternoon';
    }

    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocConsumer<UserProfileBloc, UserProfileState>(
        listener: (context, state) {
          // ----------------------------------------------------
          // Profile loaded → request current location once
          // ----------------------------------------------------

          if (state is UserProfileLoaded && !_locationRequested) {
            _locationRequested = true;

            final user = FirebaseAuth.instance.currentUser;

            if (user != null) {
              context.read<UserProfileBloc>().add(
                UpdateUserLocationRequested(userUid: user.uid),
              );
            }
          }

          // ----------------------------------------------------
          // Location/profile error
          // ----------------------------------------------------

          if (state is UserProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          String userName = 'User';
          String? locationName;
          String? profileImage;

          if (state is UserProfileLoaded) {
            userName = state.profile.name.isNotEmpty
                ? state.profile.name
                : 'User';

            locationName = state.profile.locationName;
            profileImage = state.profile.profileImage;
          }

          return SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ==================================================
                // HEADER
                // ==================================================

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                    child: Row(
                      children: [
                        // Profile avatar
                        _ProfileAvatar(name: userName, imageUrl: profileImage),

                        const SizedBox(width: 14),

                        // Greeting
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _greeting(),
                                style: TextStyle(
                                  color: AppColors.textLightSecondary
                                      .withValues(alpha: 0.85),
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                userName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.textLight,
                                  fontSize: 21,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Notification
                        _GlassIconButton(
                          icon: Icons.notifications_none_rounded,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                ),

                // ==================================================
                // LOCATION
                // ==================================================
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
                    child: _LocationCard(
                      locationName: locationName,
                      loading: state is UserProfileLoading,
                    ),
                  ),
                ),

                // ==================================================
                // AI HERO
                // ==================================================
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: _AiHeroCard(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AiChatPage()),
                        );
                      },
                    ),
                  ),
                ),

                // ==================================================
                // ACTIVE BOOKING
                // ==================================================
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 30, 24, 0),
                    child: const _SectionHeader(
                      title: 'YOUR ACTIVITY',
                      actionText: 'View all',
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                    child: _EmptyBookingCard(onTap: () {}),
                  ),
                ),

                // ==================================================
                // HOW IT WORKS
                // ==================================================
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 12),
                    child: const _SectionHeader(title: 'HOW SERVICEHUB WORKS'),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: const _HowItWorksCard(),
                  ),
                ),

                // Bottom space for floating navigation
                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// PROFILE AVATAR
// ============================================================

class _ProfileAvatar extends StatelessWidget {
  final String name;
  final String? imageUrl;

  const _ProfileAvatar({required this.name, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withValues(alpha: 0.12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.5),
          width: 1.5,
        ),
        image: imageUrl != null && imageUrl!.isNotEmpty
            ? DecorationImage(image: NetworkImage(imageUrl!), fit: BoxFit.cover)
            : null,
      ),
      child: imageUrl == null || imageUrl!.isEmpty
          ? Center(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'U',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            )
          : null,
    );
  }
}

// ============================================================
// GLASS ICON BUTTON
// ============================================================

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GlassIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Material(
          color: Colors.white.withValues(alpha: 0.06),
          child: InkWell(
            onTap: onTap,
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Icon(icon, color: AppColors.textLight, size: 22),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// LOCATION CARD
// ============================================================

class _LocationCard extends StatelessWidget {
  final String? locationName;
  final bool loading;

  const _LocationCard({required this.locationName, required this.loading});

  @override
  Widget build(BuildContext context) {
    final hasLocation = locationName != null && locationName!.isNotEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'YOUR LOCATION',
                      style: TextStyle(
                        color: AppColors.textLightSecondary.withValues(
                          alpha: 0.7,
                        ),
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    if (loading)
                      Container(
                        width: 130,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      )
                    else
                      Text(
                        hasLocation
                            ? locationName!
                            : 'Finding your location...',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textLight,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
              if (hasLocation)
                const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.greenAccent,
                  size: 18,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// AI HERO CARD
// ============================================================

class _AiHeroCard extends StatelessWidget {
  final VoidCallback onTap;

  const _AiHeroCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withValues(alpha: 0.22),
                AppColors.primary.withValues(alpha: 0.04),
              ],
            ),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.28),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.16),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: AppColors.primary,
                      size: 23,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'ServiceHub AI',
                      style: TextStyle(
                        color: AppColors.textLight,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.greenAccent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'READY',
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              const Text(
                'What do you need help with?',
                style: TextStyle(
                  color: AppColors.textLight,
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
              ),

              const SizedBox(height: 9),

              Text(
                'Describe your problem naturally. '
                'I’ll help you find the right service.',
                style: TextStyle(
                  color: AppColors.textLightSecondary.withValues(alpha: 0.9),
                  fontSize: 14,
                  height: 1.45,
                ),
              ),

              const SizedBox(height: 22),

              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(17),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 17,
                      vertical: 17,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(17),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.chat_bubble_outline_rounded,
                          color: AppColors.primary,
                          size: 21,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Tell me what’s wrong...',
                            style: TextStyle(
                              color: AppColors.textLightSecondary.withValues(
                                alpha: 0.75,
                              ),
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// SECTION HEADER
// ============================================================

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;

  const _SectionHeader({required this.title, this.actionText});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.textLightSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
        if (actionText != null)
          Text(
            actionText!,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
      ],
    );
  }
}

// ============================================================
// EMPTY BOOKING CARD
// ============================================================

class _EmptyBookingCard extends StatelessWidget {
  final VoidCallback onTap;

  const _EmptyBookingCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              Icons.calendar_today_rounded,
              color: AppColors.textLightSecondary,
              size: 21,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No active bookings',
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Your upcoming services will appear here.',
                  style: TextStyle(
                    color: AppColors.textLightSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// HOW IT WORKS
// ============================================================

class _HowItWorksCard extends StatelessWidget {
  const _HowItWorksCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.035),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(
        children: const [
          _StepItem(
            number: '01',
            icon: Icons.chat_rounded,
            title: 'Tell us your problem',
            subtitle: 'Describe what you need in your own words.',
          ),
          _StepDivider(),
          _StepItem(
            number: '02',
            icon: Icons.location_on_rounded,
            title: 'Find nearby help',
            subtitle: 'Available professionals near your location are found.',
          ),
          _StepDivider(),
          _StepItem(
            number: '03',
            icon: Icons.check_circle_rounded,
            title: 'Book and track',
            subtitle: 'Book your professional and follow the service status.',
          ),
        ],
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  final String number;
  final IconData icon;
  final String title;
  final String subtitle;

  const _StepItem({
    required this.number,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    number,
                    style: TextStyle(
                      color: AppColors.primary.withValues(alpha: 0.7),
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textLight,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: TextStyle(
                  color: AppColors.textLightSecondary.withValues(alpha: 0.8),
                  fontSize: 11.5,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StepDivider extends StatelessWidget {
  const _StepDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 22, top: 8, bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          width: 1,
          height: 18,
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
    );
  }
}
