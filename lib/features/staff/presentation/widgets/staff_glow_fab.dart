import 'package:flutter/material.dart';
import 'package:service_hub_ai/core/theme/app_colors.dart';

/// An animated floating action button with a pulsating glow effect.
class StaffGlowFab extends StatefulWidget {
  final VoidCallback onPressed;

  const StaffGlowFab({super.key, required this.onPressed});

  @override
  State<StaffGlowFab> createState() => _StaffGlowFabState();
}

class _StaffGlowFabState extends State<StaffGlowFab>
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
