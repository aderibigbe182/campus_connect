import 'package:flutter/material.dart';

class ChatFloatingButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ChatFloatingButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      elevation: 3,
      onPressed: onPressed,
      child: const Icon(Icons.chat),
    );
  }
}
