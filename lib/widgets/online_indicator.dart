import 'package:flutter/material.dart';

class OnlineIndicator extends StatelessWidget {

  final bool isOnline;

  const OnlineIndicator({
    super.key,
    required this.isOnline,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: isOnline
            ? Colors.green
            : Colors.grey,
        shape: BoxShape.circle,
      ),
    );
  }
}