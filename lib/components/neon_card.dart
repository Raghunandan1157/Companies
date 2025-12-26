import 'package:flutter/material.dart';
import 'package:corp_pulse/components/glass_background.dart';

class NeonCard extends StatelessWidget {
  final Widget child;
  final Color glowColor;
  final double intensity;
  final VoidCallback? onTap;

  const NeonCard({
    super.key,
    required this.child,
    this.glowColor = Colors.cyan,
    this.intensity = 1.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: glowColor.withOpacity(0.15 * intensity),
              blurRadius: 16,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: GlassBackground(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: glowColor.withOpacity(0.3 * intensity),
            width: 1.5,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: child,
          ),
        ),
      ),
    );
  }
}
