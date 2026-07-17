import 'package:flutter/material.dart';

class OnlineIndicator extends StatelessWidget {
  final bool isOnline;

  const OnlineIndicator({
    super.key,
    required this.isOnline,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: isOnline
                ? Colors.green
                : Colors.grey,
            shape: BoxShape.circle,
          ),
        ),

        const SizedBox(width: 5),

        Text(
          isOnline
              ? "Online"
              : "Offline",
          style: TextStyle(
            color: isOnline
                ? Colors.green
                : Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}