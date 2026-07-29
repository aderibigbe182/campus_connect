import 'package:flutter/material.dart';

import '../models/reply_message_model.dart';

class ReplyPreview extends StatelessWidget {
  final ReplyMessageModel reply;
  final VoidCallback onCancel;

  const ReplyPreview({
    super.key,
    required this.reply,
    required this.onCancel,
  });

  IconData _icon() {
    switch (reply.type) {
      case "image":
        return Icons.image;
      case "video":
        return Icons.videocam;
      case "audio":
        return Icons.mic;
      case "document":
        return Icons.insert_drive_file;
      default:
        return Icons.reply;
    }
  }

  String _subtitle() {
    if (reply.type == "text") {
      return reply.message;
    }

    switch (reply.type) {
      case "image":
        return "Photo";
      case "video":
        return "Video";
      case "audio":
        return "Voice message";
      case "document":
        return "Document";
      default:
        return reply.message;
    }
  }
}
@override
Widget build(BuildContext context) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 10,
    ),
    decoration: BoxDecoration(
      color: Colors.grey.shade100,
      border: Border(
        left: BorderSide(
          color: Theme.of(context).primaryColor,
          width: 4,
        ),
      ),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          _icon(),
          color: Theme.of(context).primaryColor,
          size: 22,
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                reply.senderName,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                _subtitle(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),

        InkWell(
          onTap: onCancel,
          borderRadius: BorderRadius.circular(20),
          child: const Padding(
            padding: EdgeInsets.all(4),
            child: Icon(
              Icons.close,
              size: 20,
            ),
          ),
        ),
      ],
    ),
  );
}