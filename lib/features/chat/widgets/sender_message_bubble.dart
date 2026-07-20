import 'package:flutter/material.dart';

class SenderMessageBubble extends StatelessWidget {
  final String message;
  final DateTime createdAt;
  final bool delivered;
  final bool seen;
  final bool sending;

  const SenderMessageBubble({
    super.key,
    required this.message,
    required this.createdAt,
    required this.delivered,
    required this.seen,
    this.sending = false,
  });

String _formatTime(DateTime dateTime) {
  final hour = dateTime.hour > 12
      ? dateTime.hour - 12
      : dateTime.hour == 0
          ? 12
          : dateTime.hour;

  final minute =
      dateTime.minute.toString().padLeft(2, '0');

  final period =
      dateTime.hour >= 12 ? "PM" : "AM";

  return "$hour:$minute $period";
}
Widget _buildStatusIcon() {
  if (sending) {
    return const SizedBox(
      width: 12,
      height: 12,
      child: CircularProgressIndicator(
        strokeWidth: 1.5,
      ),
    );
  }

  if (seen) {
    return const Icon(
      Icons.done_all,
      size: 16,
      color: Colors.blue,
    );
  }

  if (delivered) {
    return const Icon(
      Icons.done_all,
      size: 16,
      color: Colors.grey,
    );
  }

  return const Icon(
    Icons.done,
    size: 16,
    color: Colors.grey,
  );
}
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 4,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(4),
          ),
        ),
        child: Column(
  crossAxisAlignment: CrossAxisAlignment.end,
  mainAxisSize: MainAxisSize.min,
  children: [
    Text(
      message,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onPrimary,
        fontSize: 15,
        height: 1.35,
      ),
    ),

    const SizedBox(height: 4),
    
  ],
),
      ),
    );
  }
}