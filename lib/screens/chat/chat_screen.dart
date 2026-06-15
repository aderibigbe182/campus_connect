import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/services/chat_service.dart';
import '../../widgets/message_bubble.dart';

class ChatScreen extends StatefulWidget {

  final String chatId;

  const ChatScreen({
    super.key,
    required this.chatId,
  });

  @override
  State<ChatScreen> createState() =>
      _ChatScreenState();
}

class _ChatScreenState
    extends State<ChatScreen> {

  final ChatService chatService =
      ChatService();

  final TextEditingController controller =
      TextEditingController();

  void send() async {

    if (controller.text.trim().isEmpty) {
      return;
    }

    await chatService.sendMessage(
      chatId: widget.chatId,
      senderId: "currentUserId",
      text: controller.text,
    );

    controller.clear();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Chat"),
      ),

      body: Column(

        children: [

          Expanded(

            child: StreamBuilder<QuerySnapshot>(

              stream:
                  chatService.getMessages(
                widget.chatId,
              ),

              builder: (context, snapshot) {

                if (!snapshot.hasData) {

                  return const Center(
                    child:
                        CircularProgressIndicator(),
                  );
                }

                final messages =
                    snapshot.data!.docs;

                return ListView.builder(

                  itemCount: messages.length,

                  itemBuilder: (context, index) {

                    final msg =
                        messages[index];

                    return MessageBubble(

                      text: msg['text'],

                      isMe:
                          msg['senderId'] ==
                              "currentUserId",

                      seen: msg['seen'],
                    );
                  },
                );
              },
            ),
          ),

          Padding(

            padding:
                const EdgeInsets.all(10),

            child: Row(

              children: [

                Expanded(

                  child: TextField(

                    controller: controller,

                    decoration:
                        const InputDecoration(
                      hintText:
                          "Type a message",
                    ),
                  ),
                ),

                IconButton(

                  onPressed: send,

                  icon:
                      const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}