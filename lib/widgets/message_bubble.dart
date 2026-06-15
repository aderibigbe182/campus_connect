import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {

  final String text;
  final bool isMe;
  final bool seen;

  const MessageBubble({
    super.key,
    required this.text,
    required this.isMe,
    required this.seen,
  });

  @override
  Widget build(BuildContext context) {

    return Align(

      alignment:
          isMe
              ? Alignment.centerRight
              : Alignment.centerLeft,

      child: Container(

        margin:
            const EdgeInsets.symmetric(
          vertical: 5,
          horizontal: 10,
        ),

        padding:
            const EdgeInsets.all(12),

        decoration: BoxDecoration(

          color:
              isMe
                  ? Colors.blue
                  : Colors.grey[300],

          borderRadius:
              BorderRadius.circular(12),
        ),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.end,

          children: [

            Text(

              text,

              style: TextStyle(
                color:
                    isMe
                        ? Colors.white
                        : Colors.black,
              ),
            ),

            const SizedBox(height: 4),

            if (isMe)
              Icon(

                seen
                    ? Icons.done_all
                    : Icons.done,

                size: 16,

                color:
                    seen
                        ? Colors.lightBlueAccent
                        : Colors.white,
              ),
          ],
        ),
      ),
    );
  }
}