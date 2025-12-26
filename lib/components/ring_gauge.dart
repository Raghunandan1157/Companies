import 'dart:math';
import 'package:flutter/material.dart';

class RingGauge extends StatelessWidget {
  final double percentage; // 0 to 100
  final String label;
  final Color color;
  final double size;

  const RingGauge({
    super.key,
    required this.percentage,
    required this.label,
    this.color = Colors.cyan,
    this.size = 150,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Ring
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(
              percentage: 100,
              color: Colors.white10,
              strokeWidth: 15,
            ),
          ),
          // Progress Ring
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: percentage),
            duration: const Duration(seconds: 2),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return CustomPaint(
                size: Size(size, size),
                painter: _RingPainter(
                  percentage: value,
                  color: color,
                  strokeWidth: 15,
                  glow: true,
                ),
              );
            },
          ),
          // Center Text
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${percentage.toInt()}%',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: size * 0.22,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(color: color, blurRadius: 10),
                  ],
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: size * 0.1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double percentage;
  final Color color;
  final double strokeWidth;
  final bool glow;

  _RingPainter({
    required this.percentage,
    required this.color,
    required this.strokeWidth,
    this.glow = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = color
      ..strokeCap = StrokeCap.round;

    if (glow) {
      paint.maskFilter = const MaskFilter.blur(BlurStyle.solid, 4);
      // Draw glow underlayer
      final glowPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 4
        ..color = color.withOpacity(0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10)
        ..strokeCap = StrokeCap.round;

      final sweepAngle = 2 * pi * (percentage / 100);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        sweepAngle,
        false,
        glowPaint,
      );
    }

    final sweepAngle = 2 * pi * (percentage / 100);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
        sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.percentage != percentage || oldDelegate.color != color;
  }
}
