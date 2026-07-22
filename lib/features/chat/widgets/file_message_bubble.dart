import 'package:flutter/material.dart';

class FileMessageBubble extends StatelessWidget {
  final String name;
  final int size;
  final bool isMe;
  final DateTime createdAt;

  const FileMessageBubble({
    super.key,
    required this.name,
    required this.size,
    required this.isMe,
    required this.createdAt,
  });

  String _formatTime() {
    final hour =
        createdAt.hour > 12
            ? createdAt.hour - 12
            : createdAt.hour == 0
                ? 12
                : createdAt.hour;

    final minute =
        createdAt.minute.toString().padLeft(2, "0");

    final period =
        createdAt.hour >= 12
            ? "PM"
            : "AM";

    return "$hour:$minute $period";
  }

  String _size() {
    if (size < 1024) {
      return "$size B";
    }

    if (size < 1024 * 1024) {
      return "${(size / 1024).toStringAsFixed(1)} KB";
    }

    return "${(size / (1024 * 1024)).toStringAsFixed(1)} MB";
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment:
          isMe
              ? Alignment.centerRight
              : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        padding: const EdgeInsets.all(14),
        constraints:
            const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color:
              isMe
                  ? Theme.of(context)
                      .colorScheme
                      .primary
                  : Colors.grey.shade200,
          borderRadius:
              BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.insert_drive_file,
              size: 34,
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 2,
                    overflow:
                        TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    _size(),
                    style: const TextStyle(
                      fontSize: 12,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    _formatTime(),
                    style: const TextStyle(
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}