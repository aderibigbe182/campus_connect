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

  String _type() {
    final dynamic dynamicReply = reply;

    try {
      final value = dynamicReply.type;
      if (value is String) return value;
    } catch (_) {}

    try {
      final value = dynamicReply.messageType;
      if (value is String) return value;
    } catch (_) {}

    try {
      final value = dynamicReply.replyType;
      if (value is String) return value;
    } catch (_) {}

    return "";
  }

  IconData _icon() {
    switch (_type()) {
      case "image":
        return Icons.image;
      case "video":
        return Icons.videocam;
      case "audio":
        return Icons.mic;
      case "file":
        return Icons.insert_drive_file;
      default:
        return Icons.reply;
    }
  }

  String _subtitle() {
    switch (_type()) {
      case "image":
        return "📷 Photo";
      case "video":
        return "🎥 Video";
      case "audio":
        return "🎤 Voice message";
      case "file":
        return "📄 File";
      default:
        return reply.message;
    }
  }
    @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
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
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    reply.sender,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    _subtitle(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            IconButton(
              onPressed: onCancel,
              icon: const Icon(Icons.close),
            ),
          ],
        ),
      ),
    );
  }
}