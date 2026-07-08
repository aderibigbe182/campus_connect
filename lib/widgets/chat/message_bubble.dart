import 'package:flutter/material.dart';

import '../../models/message_model.dart';

class MessageBubble extends StatelessWidget {

  final MessageModel message;

  const MessageBubble({

    super.key,

    required this.message,

  });

  @override
  Widget build(BuildContext context) {

    final bool isMe =

        message.senderId == 1; // TODO: Replace with logged-in user id

    return Align(

      alignment: isMe

          ? Alignment.centerRight

          : Alignment.centerLeft,

      child: Container(

        margin: const EdgeInsets.symmetric(

          horizontal: 12,

          vertical: 4,

        ),

        padding: const EdgeInsets.symmetric(

          horizontal: 14,

          vertical: 10,

        ),

        constraints: BoxConstraints(

          maxWidth:

              MediaQuery.of(context).size.width * .75,

        ),

        decoration: BoxDecoration(

          color: isMe

              ? Colors.blue

              : Colors.grey.shade200,

          borderRadius: BorderRadius.only(

            topLeft: const Radius.circular(16),

            topRight: const Radius.circular(16),

            bottomLeft: Radius.circular(

              isMe ? 16 : 4,

            ),

            bottomRight: Radius.circular(

              isMe ? 4 : 16,

            ),

          ),

        ),

        child: Column(

          crossAxisAlignment:

              CrossAxisAlignment.start,

          children: [

            Text(

              message.message,

              style: TextStyle(

                color: isMe

                    ? Colors.white

                    : Colors.black,

                fontSize: 16,

              ),

            ),

            const SizedBox(

              height: 6,

            ),

            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(
                    message.createdAt,
                  ),
                  style: TextStyle(
                    color: isMe ? Colors.white70 : Colors.grey,
                    fontSize: 11,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.seen
                        ? Icons.done_all
                        : message.delivered
                            ? Icons.done_all
                            : Icons.done,
                    size: 16,
                    color: message.seen
                        ? Colors.lightBlueAccent
                        : Colors.white70,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
}

  String _formatTime(

    DateTime date,

  ) {

    final hour =

        date.hour.toString().padLeft(2, '0');

    final minute =

        date.minute.toString().padLeft(2, '0');

    return "$hour:$minute";

  }

}