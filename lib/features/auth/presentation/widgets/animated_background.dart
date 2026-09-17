import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class AnimatedBackground extends StatefulWidget {
  final Widget child;
  
  const AnimatedBackground({
    super.key,
    required this.child,
  });

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground> with SingleTickerProviderStateMixin {
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
    return Stack(
      children: [
        // Solid Deep Dark Background
        Container(color: AppColors.background),
        
        // Large Animated Meter Dial on Right Edge
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            // Smooth easing for the sweeping animation
            final easedValue = Curves.easeInOutSine.transform(_controller.value);
            
            return Positioned(
              right: -180, // Positioned on the right edge
              top: MediaQuery.of(context).size.height * 0.1,
              child: SizedBox(
                width: 450,
                height: 600,
                child: CustomPaint(
                  painter: _MeterPainter(
                    animationValue: easedValue,
                    color: AppColors.primary,
                  ),
                ),
              ),
            );
          },
        ),

        // Foreground content
        widget.child,
      ],
    );
  }
}

class _MeterPainter extends CustomPainter {
  final double animationValue; // 0.0 to 1.0
  final Color color;

  _MeterPainter({
    required this.animationValue,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw a subtle dark glowing backdrop for the meter
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 50);
    
    canvas.drawCircle(center, radius, glowPaint);

    // Draw main outer glowing arc (left half of circle)
    final paintArc = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 4);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi / 2, // Start at bottom
      math.pi,     // Sweep to top
      false,
      paintArc,
    );

    // Draw the ticks
    final paintTick = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final paintActiveTick = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 3);

    // Draw ticks along the left half of the circle
    int totalTicks = 90; // Number of ticks
    for (int i = 0; i <= totalTicks; i++) {
      // Angle from pi/2 to 3pi/2 (left side)
      double angle = math.pi / 2 + (math.pi * i / totalTicks);
      
      // Determine if tick is "active" (lit up) based on the animation
      // We animate the active ticks from the center outwards, or sweeping from bottom to top
      double progress = i / totalTicks;
      bool isActive = progress < animationValue;

      // Tick length (longer for every 10th tick)
      double tickLength = i % 10 == 0 ? 30.0 : (i % 5 == 0 ? 20.0 : 10.0);
      
      Offset outerPoint = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      
      Offset innerPoint = Offset(
        center.dx + (radius - tickLength) * math.cos(angle),
        center.dy + (radius - tickLength) * math.sin(angle),
      );

      canvas.drawLine(innerPoint, outerPoint, isActive ? paintActiveTick : paintTick);
    }
  }

  @override
  bool shouldRepaint(covariant _MeterPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
