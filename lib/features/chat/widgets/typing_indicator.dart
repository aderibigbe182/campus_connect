import 'package:flutter/material.dart';

class TypingIndicator extends StatefulWidget {
  final bool visible;
  final String? username;

  const TypingIndicator({
    super.key,
    required this.visible,
    this.username,
  });

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _dot1;
  late final Animation<double> _dot2;
  late final Animation<double> _dot3;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();

    _dot1 = Tween<double>(
      begin: .25,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, .6),
      ),
    );

    _dot2 = Tween<double>(
      begin: .25,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(.2, .8),
      ),
    );

    _dot3 = Tween<double>(
      begin: .25,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(.4, 1.0),
      ),
    );
  }
    @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _dot(Animation<double> animation) {
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: animation,
        child: Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Colors.grey,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: 8,
      ),
      child: Row(
        children: [
          if (widget.username != null) ...[
            Text(
              "${widget.username} is typing...",
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(width: 10),
          ],

          _dot(_dot1),
          const SizedBox(width: 4),
          _dot(_dot2),
          const SizedBox(width: 4),
          _dot(_dot3),
        ],
      ),
    );
  }
}