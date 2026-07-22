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

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest,
        border: Border(
          left: BorderSide(
            color: Theme.of(context)
                .colorScheme
                .primary,
            width: 4,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  reply.sender,
                  style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  reply.message,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
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
    );
  }
}