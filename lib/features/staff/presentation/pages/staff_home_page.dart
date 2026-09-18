import 'dart:ui';
import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:service_hub_ai/core/service/service_locator.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/staff_service.dart';
import '../bloc/staff_service_bloc.dart';
import '../bloc/staff_service_event.dart';
import '../bloc/staff_service_state.dart';

class StaffHomePage extends StatelessWidget {
  const StaffHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return BlocProvider(
      create: (_) {
        final bloc = sl<StaffServiceBloc>();
        if (user != null) {
          bloc.add(LoadStaffServices(staffUid: user.uid));
        }
        return bloc;
      },
      child: const _StaffHomeView(),
    );
  }
}

class _StaffHomeView extends StatelessWidget {
  const _StaffHomeView();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

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
                    'Service added successfully!',
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
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            // Animated background
            const _StaffAnimatedBackground(),

            // Main content
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                    child: Row(
                      children: [
                        // Avatar
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary.withValues(alpha: 0.15),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.4),
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              (user?.displayName?.isNotEmpty == true
                                      ? user!.displayName![0]
                                      : user?.email?[0] ?? 'S')
                                  .toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Staff Dashboard',
                                style: TextStyle(
                                  color: AppColors.textLight,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                user?.email ?? '',
                                style: const TextStyle(
                                  color: AppColors.textLightSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Status pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.green.withValues(alpha: 0.4),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.circle,
                                color: Colors.greenAccent,
                                size: 8,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Online',
                                style: TextStyle(
                                  color: Colors.greenAccent,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Stats row
                  // Stats row
                  BlocBuilder<StaffServiceBloc, StaffServiceState>(
                    builder: (context, state) {
                      int serviceCount = 0;

                      if (state is StaffServicesLoaded) {
                        serviceCount = state.services.length;
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          children: [
                            _StatCard(
                              label: 'Services',
                              value: serviceCount.toString(),
                              icon: Icons.build_rounded,
                            ),
                            const SizedBox(width: 12),
                            _StatCard(
                              label: 'Bookings',
                              value: '0',
                              icon: Icons.calendar_month_rounded,
                            ),
                            const SizedBox(width: 12),
                            _StatCard(
                              label: 'Rating',
                              value: '—',
                              icon: Icons.star_rounded,
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  // Section header
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
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

                  const SizedBox(height: 16),

                  // Services list
                  const Expanded(child: _ServicesBody()),
                ],
              ),
            ),
          ],
        ),

        // FAB
        floatingActionButton: Builder(
          builder: (context) =>
              _GlowFab(onPressed: () => _showAddServiceDialog(context)),
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
      transitionBuilder: (ctx, anim, _, child) {
        return FadeTransition(
          opacity: anim,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.92, end: 1.0).animate(
              CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
            ),
            child: child,
          ),
        );
      },
      pageBuilder: (ctx, anim1, anim2) {
        return Center(
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
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.07),
                    ),
                  ),
                  padding: const EdgeInsets.all(28),
                  child: Material(
                    color: Colors.transparent,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Dialog header
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(
                                  alpha: 0.15,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.add_rounded,
                                color: AppColors.primary,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            const Text(
                              'Add New Service',
                              style: TextStyle(
                                color: AppColors.textLight,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Service name field
                        _DialogTextField(
                          controller: nameController,
                          label: 'Service Name',
                          hint: 'e.g. AC Repair, Plumbing',
                          icon: Icons.build_rounded,
                        ),

                        const SizedBox(height: 16),

                        // Description field
                        _DialogTextField(
                          controller: descriptionController,
                          label: 'Description',
                          hint: 'Describe what you offer...',
                          icon: Icons.description_rounded,
                          maxLines: 3,
                        ),

                        const SizedBox(height: 28),

                        // Actions
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.textLightSecondary,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    side: const BorderSide(
                                      color: AppColors.borderLight,
                                    ),
                                  ),
                                ),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: ElevatedButton(
                                onPressed: () {
                                  final name = nameController.text.trim();
                                  final description = descriptionController.text
                                      .trim();

                                  if (name.isEmpty) return;

                                  final user =
                                      FirebaseAuth.instance.currentUser;
                                  if (user == null) return;

                                  final service = StaffService(
                                    id: DateTime.now().millisecondsSinceEpoch
                                        .toString(),
                                    name: name,
                                    description: description,
                                  );

                                  context.read<StaffServiceBloc>().add(
                                    AddStaffServiceRequested(
                                      staffUid: user.uid,
                                      service: service,
                                    ),
                                  );

                                  Navigator.pop(ctx);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: const Text(
                                  'Add Service',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Services body ──────────────────────────────────────────────────────────

class _ServicesBody extends StatelessWidget {
  const _ServicesBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StaffServiceBloc, StaffServiceState>(
      builder: (context, state) {
        if (state is StaffServiceLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (state is StaffServicesLoaded) {
          if (state.services.isEmpty) {
            return _emptyState();
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            itemCount: state.services.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final service = state.services[index];
              return _ServiceCard(service: service);
            },
          );
        }

        return _emptyState();
      },
    );
  }

  Widget _emptyState() {
    return Center(
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
            'Tap the + button to add\nyour first service offering',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textLightSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
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

// ─── Animated Background ─────────────────────────────────────────────────────

class _StaffAnimatedBackground extends StatefulWidget {
  const _StaffAnimatedBackground();

  @override
  State<_StaffAnimatedBackground> createState() =>
      _StaffAnimatedBackgroundState();
}

class _StaffAnimatedBackgroundState extends State<_StaffAnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final easedValue = Curves.easeInOutSine.transform(_controller.value);
        return Positioned.fill(
          child: CustomPaint(
            painter: _StaffBgPainter(
              animationValue: easedValue,
              color: AppColors.primary,
            ),
          ),
        );
      },
    );
  }
}

class _StaffBgPainter extends CustomPainter {
  final double animationValue;
  final Color color;

  _StaffBgPainter({required this.animationValue, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    // Glow at top-right corner
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.07)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80);
    canvas.drawCircle(Offset(size.width, 0), 200, glowPaint);

    // Glow at bottom-left corner (to match, diagonal balance)
    final glowPaintBL = Paint()
      ..color = color.withValues(alpha: 0.05)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80);
    canvas.drawCircle(Offset(0, size.height), 180, glowPaintBL);

    // Arc + ticks: bottom-left corner (sweeps from up to right)
    _drawCornerArcTicks(
      canvas: canvas,
      center: Offset(-100, size.height + 80),
      radius: 350,
      startAngle: -math.pi / 2,
      sweep: math.pi / 2,
    );

    // Arc + ticks: top-right corner (mirrored diagonally, sweeps from down to left)
    _drawCornerArcTicks(
      canvas: canvas,
      center: Offset(size.width + 100, -80),
      radius: 350,
      startAngle: math.pi / 2,
      sweep: math.pi / 2,
    );
  }

  void _drawCornerArcTicks({
    required Canvas canvas,
    required Offset center,
    required double radius,
    required double startAngle,
    required double sweep,
  }) {
    final paintArc = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 3);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweep,
      false,
      paintArc,
    );

    final paintTick = Paint()
      ..color = color.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final paintActiveTick = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 2);

    int totalTicks = 60;
    for (int i = 0; i <= totalTicks; i++) {
      double angle = startAngle + (sweep * i / totalTicks);
      double progress = i / totalTicks;
      bool isActive = progress < animationValue;
      double tickLength = i % 10 == 0 ? 24.0 : (i % 5 == 0 ? 16.0 : 8.0);

      Offset outerPoint = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      Offset innerPoint = Offset(
        center.dx + (radius - tickLength) * math.cos(angle),
        center.dy + (radius - tickLength) * math.sin(angle),
      );

      canvas.drawLine(
        innerPoint,
        outerPoint,
        isActive ? paintActiveTick : paintTick,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StaffBgPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}
