import 'package:flutter/material.dart';

class MessageStatusIcon extends StatelessWidget {
  final bool delivered;
  final bool read;

  const MessageStatusIcon({
    super.key,
    required this.delivered,
    required this.read,
  });

  @override
  Widget build(BuildContext context) {
    if (read) {
      return const Icon(
        Icons.done_all,
        size: 15,
      );
    }

    if (delivered) {
      return const Icon(
        Icons.done_all,
        size: 15,
      );
    }

    return const Icon(
      Icons.done,
      size: 15,
    );
  }
}