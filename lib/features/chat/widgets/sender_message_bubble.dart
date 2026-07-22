import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/message_action_sheet.dart';
import '../models/reply_message_model.dart';

class SenderMessageBubble extends StatelessWidget {
  final String message;
  final DateTime createdAt;
  final bool delivered;
  final bool seen;
  final bool sending;
  final VoidCallback? onDelete;
  final bool edited;
  final VoidCallback? onEdit;
  final VoidCallback? onForward;
  final VoidCallback? onReply;
  final ReplyMessageModel? replyTo;

  const SenderMessageBubble({
    super.key,
    required this.message,
    required this.createdAt,
    required this.delivered,
    required this.seen,
    this.sending = false,
    this.onDelete,
    this.edited = false,
    this.onEdit,
    this.onForward,
    this.onReply,
    this.replyTo,
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
        GestureDetector(
  onLongPress: () {
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

  ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    behavior: SnackBarBehavior.floating,
    duration: const Duration(milliseconds: 900),
    content: const Text("Copied"),
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
          onEdit: () {
  Navigator.pop(context);
  onEdit?.call();
},
          onDelete: () {
  Navigator.pop(context);

  onDelete?.call();
},
        );
      },
    );
  },
        child: Column(
  crossAxisAlignment: CrossAxisAlignment.end,
  mainAxisSize: MainAxisSize.min,
  children: [
    if (edited)
      const Padding(
        padding: EdgeInsets.only(right: 4),
        child: Text(
          "(edited)",
          style: TextStyle(
            fontSize: 10,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
      if (replyTo != null)
  Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Colors.black12,
      borderRadius: BorderRadius.circular(10),
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
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 12,
          ),
        ),
      ],
    ),
  ),
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