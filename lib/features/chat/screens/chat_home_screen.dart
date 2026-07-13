import 'package:flutter/material.dart';

import '../models/chat_model.dart';
import '../services/chat_service.dart';
import '../widgets/chat_app_bar.dart';
import '../widgets/chat_search_bar.dart';
import '../widgets/chat_tile.dart';

class ChatHomeScreen extends StatefulWidget {
  const ChatHomeScreen({super.key});

  @override
  State<ChatHomeScreen> createState() =>
      _ChatHomeScreenState();
}

class _ChatHomeScreenState
    extends State<ChatHomeScreen> {

  final ChatService service = ChatService();

  late Future<List<ChatModel>> chats;

  @override
  void initState() {
    super.initState();
    chats = service.getChats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ChatAppBar(),
      body: Column(
        children: [
          const SizedBox(height: 10),

          const ChatSearchBar(),

          const SizedBox(height: 10),

          Expanded(
            child: FutureBuilder<List<ChatModel>>(
              future: chats,
              builder: (context, snapshot) {

                if (!snapshot.hasData) {
                  return const Center(
                    child:
                        CircularProgressIndicator(),
                  );
                }

                final data = snapshot.data!;

                return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {

                    return ChatTile(
                      chat: data[index],
                      onTap: () {},
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
