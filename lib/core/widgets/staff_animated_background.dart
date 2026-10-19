import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// A reusable animated background widget used across all staff pages.
/// It renders glowing arcs and animated tick marks at screen corners.
class StaffAnimatedBackground extends StatefulWidget {
  const StaffAnimatedBackground({super.key});

  @override
  State<StaffAnimatedBackground> createState() =>
      _StaffAnimatedBackgroundState();
}

class _StaffAnimatedBackgroundState extends State<StaffAnimatedBackground>
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

    // Glow at bottom-left corner
    final glowPaintBL = Paint()
      ..color = color.withValues(alpha: 0.05)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80);
    canvas.drawCircle(Offset(0, size.height), 180, glowPaintBL);

    // Arc + ticks: bottom-left corner
    _drawCornerArcTicks(
      canvas: canvas,
      center: Offset(-100, size.height + 80),
      radius: 350,
      startAngle: -math.pi / 2,
      sweep: math.pi / 2,
    );

    // Arc + ticks: top-right corner
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

    const int totalTicks = 60;
    for (int i = 0; i <= totalTicks; i++) {
      final double angle = startAngle + (sweep * i / totalTicks);
      final double progress = i / totalTicks;
      final bool isActive = progress < animationValue;
      final double tickLength = i % 10 == 0 ? 24.0 : (i % 5 == 0 ? 16.0 : 8.0);

      final Offset outerPoint = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      final Offset innerPoint = Offset(
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
