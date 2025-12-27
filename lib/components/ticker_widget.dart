import 'package:flutter/material.dart';
import 'package:corp_pulse/theme/app_theme.dart';

class TickerWidget extends StatefulWidget {
  final List<String> messages;
  final Duration scrollDuration;

  const TickerWidget({
    super.key,
    required this.messages,
    this.scrollDuration = const Duration(seconds: 10),
  });

  @override
  State<TickerWidget> createState() => _TickerWidgetState();
}

class _TickerWidgetState extends State<TickerWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.scrollDuration,
    )..repeat();

    _animation = Tween<double>(begin: 1.0, end: -1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 30,
      color: AppTheme.neonCyan.withOpacity(0.1),
      child: ClipRect(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return FractionallySizedBox(
              widthFactor: 2.0, // Double width to allow scrolling
              alignment: Alignment(_animation.value, 0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                     _buildTextRow(context),
                     _buildTextRow(context), // Duplicate for seamless loop effect
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextRow(BuildContext context) {
    // We use a container with screen width to ensure spacing if needed,
    // or just let it flow. For safety, let's just render the text items with padding.
    // The parent Row is unconstrained horizontally by SingleChildScrollView so no overflow.
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: widget.messages.map((msg) =>
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            msg,
            style: const TextStyle(color: AppTheme.neonCyan, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.visible, // Should not happen due to scroll view
          ),
        )
      ).toList(),
    );
  }
}
