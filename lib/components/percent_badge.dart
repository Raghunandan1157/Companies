import 'package:flutter/material.dart';

class PercentBadge extends StatelessWidget {
  final double value;
  final bool invertedColor; // If true, lower is better (e.g. NPA)

  const PercentBadge({
    super.key,
    required this.value,
    this.invertedColor = false,
  });

  @override
  Widget build(BuildContext context) {
    // Determine status (simple threshold for demo)
    // Assuming 80% is good for standard, 10% is bad for NPA etc.
    // This logic can be refined.

    // For standard: >80 good (Green), >50 avg (Amber), else Red
    // For inverted: <5 good (Green), <10 avg (Amber), else Red

    Color color;
    IconData icon;

    if (invertedColor) {
      if (value < 5) {
        color = Colors.greenAccent;
        icon = Icons.arrow_downward;
      } else if (value < 10) {
        color = Colors.amberAccent;
        icon = Icons.remove;
      } else {
        color = Colors.redAccent;
        icon = Icons.arrow_upward;
      }
    } else {
      if (value >= 80) {
        color = Colors.greenAccent;
        icon = Icons.arrow_upward;
      } else if (value >= 50) {
        color = Colors.amberAccent;
        icon = Icons.remove;
      } else {
        color = Colors.redAccent;
        icon = Icons.arrow_downward;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 2),
          Text(
            '${value.toStringAsFixed(1)}%',
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
