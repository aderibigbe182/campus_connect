import 'package:flutter/material.dart';

class ChatSyncStatus extends StatelessWidget {
  final bool syncing;

  const ChatSyncStatus({
    super.key,
    required this.syncing,
  });

  @override
  Widget build(BuildContext context) {
    if (!syncing) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),
          SizedBox(width: 12),
          Text(
            "Syncing chats...",
            style: TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
