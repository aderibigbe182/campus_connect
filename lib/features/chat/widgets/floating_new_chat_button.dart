import 'package:flutter/material.dart';

class FloatingNewChatButton extends StatelessWidget {
  final VoidCallback onPressed;

  const FloatingNewChatButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      backgroundColor: const Color(0xff2563EB),
      foregroundColor: Colors.white,
      elevation: 3,
      icon: const Icon(Icons.edit_rounded),
      label: const Text(
        "New Chat",
        style: TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
