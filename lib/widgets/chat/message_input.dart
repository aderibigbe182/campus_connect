import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/chat_provider.dart';

class MessageInput extends StatefulWidget {

  final int conversationId;

  const MessageInput({

    super.key,

    required this.conversationId,

  });

  @override
  State<MessageInput> createState() =>
      _MessageInputState();

}

class _MessageInputState
    extends State<MessageInput> {

  final TextEditingController controller =
      TextEditingController();

  @override
  void dispose() {

    controller.dispose();

    super.dispose();

  }

  Future<void> sendMessage() async {

    final text = controller.text.trim();

    if (text.isEmpty) return;

    await context

        .read<ChatProvider>()

        .sendMessage(

          conversationId:

              widget.conversationId,

          message: text,

        );

    controller.clear();

  }

  @override
  Widget build(BuildContext context) {

    return SafeArea(

      child: Container(

        padding: const EdgeInsets.all(10),

        decoration: BoxDecoration(

          color: Colors.white,

          border: Border(

            top: BorderSide(

              color: Colors.grey.shade300,

            ),

          ),

        ),

        child: Row(

          children: [

            IconButton(

              onPressed: () {

                // TODO Emoji Picker

              },

              icon: const Icon(

                Icons.emoji_emotions_outlined,

              ),

            ),

            Expanded(

              child: TextField(

                controller: controller,

                minLines: 1,

                maxLines: 5,

                decoration:

                    InputDecoration(

                  hintText:

                      "Type a message...",

                  filled: true,

                  fillColor:

                      Colors.grey.shade100,

                  contentPadding:

                      const EdgeInsets.symmetric(

                    horizontal: 18,

                    vertical: 12,

                  ),

                  border:

                      OutlineInputBorder(

                    borderRadius:

                        BorderRadius.circular(

                      25,

                    ),

                    borderSide:

                        BorderSide.none,

                  ),

                ),

              ),

            ),

            IconButton(

              onPressed: () {

                // TODO Attachment

              },

              icon: const Icon(

                Icons.attach_file,

              ),

            ),

            CircleAvatar(

              radius: 24,

              backgroundColor:

                  Colors.blue,

              child: IconButton(

                onPressed: sendMessage,

                icon: const Icon(

                  Icons.send,

                  color: Colors.white,

                ),

              ),

            ),

          ],

        ),

      ),

    );

  }

}