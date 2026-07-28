import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/reply_message_model.dart';
import '../widgets/message_action_sheet.dart';
import '../widgets/message_reactions.dart';

class ReceiverMessageBubble extends StatelessWidget {
  final String message;
  final DateTime createdAt;

  final ReplyMessageModel? replyTo;

  final List<String> reactions;

  final VoidCallback? onReply;
  final VoidCallback? onForward;
  final VoidCallback? onDelete;

  final Function(String)? onReactionTap;

  const ReceiverMessageBubble({
    super.key,
    required this.message,
    required this.createdAt,
    this.replyTo,
    this.reactions = const [],
    this.onReply,
    this.onForward,
    this.onDelete,
    this.onReactionTap,
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
      child: GestureDetector(
        onLongPress: () {
          HapticFeedback.mediumImpact();

          showModalBottomSheet(
            context: context,
            builder: (_) {
              return MessageActionSheet(
                onCopy: () async {
                  Navigator.pop(context);

                  await Clipboard.setData(
                    ClipboardData(text: message),
                  );

                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text("Copied"),
                      duration:
                          Duration(milliseconds: 900),
                    ),
                  );
                },
                onReply: () {
                  Navigator.pop(context);
                  onReply?.call();
                },
                onForward: () {
                  Navigator.pop(context);
                  onForward?.call();
                },
                onEdit: null,
                onDelete: () {
                  Navigator.pop(context);
                  onDelete?.call();
                },
              );
            },
          );
        },
        child: Container(
          constraints: BoxConstraints(
            maxWidth:
                MediaQuery.of(context).size.width * .72,
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
            color:
                theme.colorScheme.surfaceContainerHighest,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
              bottomLeft: Radius.circular(4),
              bottomRight: Radius.circular(18),
            ),
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              if (replyTo != null)
                Container(
                  width: double.infinity,
                  margin:
                      const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        replyTo!.sender,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        replyTo!.message,
                        maxLines: 2,
                        overflow:
                            TextOverflow.ellipsis,
                        style:
                            const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),

              Text(
                message,
                style: TextStyle(
                  color:
                      theme.colorScheme.onSurface,
                  fontSize: 15,
                  height: 1.35,
                ),
              ),

              if (reactions.isNotEmpty)
                Padding(
                  padding:
                      const EdgeInsets.only(top: 6),
                  child: MessageReactions(
                    reactions: reactions,
                    onTap: onReactionTap,
                  ),
                ),

              const SizedBox(height: 6),

              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  _formatTime(createdAt),
                  style: TextStyle(
                    fontSize: 11,
                    color: theme
                        .colorScheme.onSurface
                        .withOpacity(.75),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}