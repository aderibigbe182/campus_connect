import 'package:flutter/material.dart';

class ChatFabBadge extends StatelessWidget {
  final int unreadCount;
  final VoidCallback onPressed;

  const ChatFabBadge({
    super.key,
    required this.unreadCount,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        FloatingActionButton.extended(
          onPressed: onPressed,
          backgroundColor: const Color(0xff2563EB),
          foregroundColor: Colors.white,
          icon: const Icon(Icons.edit_rounded),
          label: const Text("New Chat"),
        ),

        if (unreadCount > 0)
          Positioned(
            right: -6,
            top: -6,
            child: Container(
              height: 24,
              width: 24,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                unreadCount > 99
                    ? "99+"
                    : unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
