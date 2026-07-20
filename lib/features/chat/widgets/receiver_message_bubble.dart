import 'package:flutter/material.dart';

class ReceiverMessageBubble extends StatelessWidget {
  final String message;
  final DateTime createdAt;

  const ReceiverMessageBubble({
    super.key,
    required this.message,
    required this.createdAt,
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
@override
Widget build(BuildContext context) {
  final theme = Theme.of(context);

  return Align(
    alignment: Alignment.centerLeft,
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
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(18),
          topRight: Radius.circular(18),
          bottomLeft: Radius.circular(4),
          bottomRight: Radius.circular(18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: 15,
              height: 1.35,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            _formatTime(createdAt),
            style: TextStyle(
              fontSize: 11,
              color: theme.colorScheme.onSurface.withOpacity(.75),
            ),
          ),
        ],
      ),
    ),
  );
}
}