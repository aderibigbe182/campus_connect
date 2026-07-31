import 'package:flutter/material.dart';
import '../services/chat_service.dart';

import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../widgets/chat_tile.dart';
import 'conversation_screen.dart';
class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  List<ChatModel> chats = [];
  bool loading = true;
    @override
  void initState() {
    super.initState();
    loadChats();
  }
Future<void> loadChats() async {
  try {
    final result = await ChatService.instance.getChats();

    if (!mounted) return;

    setState(() {
      chats = result;
      loading = false;
    });
  } catch (e) {
    debugPrint("Load chats error: $e");

    if (!mounted) return;

    setState(() {
      loading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Failed to load chats"),
      ),
    );
  }
}
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text("Chats"),
      centerTitle: false,
    ),

    body: ListView.builder(
      itemCount: chats.length,

      itemBuilder: (context, index) {

        final chat = chats[index];
print(chat.lastMessage.runtimeType);
print(chat.lastMessage);
print(chat.lastMessage?.message);
print(chat.lastMessage?.message.runtimeType);
        return ChatTile(

          chat: chat,

          onTap: () {

            Navigator.push(

              context,

              MaterialPageRoute(

                builder: (_) => ConversationScreen(

                  conversationId: chat.conversationId,

                  // Provide required parameters
                  currentUserId: 1,
                  chatName: chat.otherUserName,

                ),

              ),

            );

          },

        );

      },

    ),

  );
}
}