import 'package:flutter/material.dart';

class MiniBarChart extends StatelessWidget {
  final List<double> values;
  final List<String> labels;
  final Color barColor;
  final double height;

  const MiniBarChart({
    super.key,
    required this.values,
    required this.labels,
    this.barColor = Colors.cyan,
    this.height = 100,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(8),
      child: CustomPaint(
        size: Size.infinite,
        painter: _BarChartPainter(
          values: values,
          labels: labels,
          barColor: barColor,
        ),
      ),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;
  final Color barColor;

  _BarChartPainter({
    required this.values,
    required this.labels,
    required this.barColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final maxValue = values.reduce((curr, next) => curr > next ? curr : next);
    final barWidth = size.width / (values.length * 2);
    final paint = Paint()
      ..color = barColor
      ..style = PaintingStyle.fill;

    final textStyle = TextStyle(
      color: Colors.white70,
      fontSize: 10,
    );

    for (int i = 0; i < values.length; i++) {
      final val = values[i];
      final barHeight = (val / maxValue) * (size.height - 20); // Reserve space for text

      final x = i * (size.width / values.length) + (size.width / values.length - barWidth) / 2;
      final y = size.height - 20 - barHeight;

      // Draw Bar
      final rRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, barHeight),
        const Radius.circular(4),
      );

      // Glow
      final glowPaint = Paint()
        ..color = barColor.withOpacity(0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawRRect(rRect, glowPaint);

      canvas.drawRRect(rRect, paint);

      // Draw Label
      final textSpan = TextSpan(
        text: labels[i],
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      textPainter.layout(minWidth: 0, maxWidth: size.width / values.length);
      textPainter.paint(
        canvas,
        Offset(x + barWidth / 2 - textPainter.width / 2, size.height - 15)
      );
    }

    // Axis line
    final axisPaint = Paint()..color = Colors.white24..strokeWidth = 1;
    canvas.drawLine(
      Offset(0, size.height - 20),
      Offset(size.width, size.height - 20),
      axisPaint
    );
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) => true;
}
