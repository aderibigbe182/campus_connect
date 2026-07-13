import 'package:flutter/material.dart';

class ChatConnectionBanner extends StatelessWidget {
  final bool isConnected;

  const ChatConnectionBanner({
    super.key,
    required this.isConnected,
  });

  @override
  Widget build(BuildContext context) {
    if (isConnected) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ),
      color: Colors.orange.shade600,
      child: const Row(
        children: [
          Icon(
            Icons.wifi_off_rounded,
            color: Colors.white,
            size: 18,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "Waiting for connection...",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
