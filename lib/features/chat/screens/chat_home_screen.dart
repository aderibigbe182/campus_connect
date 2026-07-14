import 'package:flutter/material.dart';

import '../models/chat_model.dart';
import '../services/chat_service.dart';

import '../widgets/chat_app_bar.dart';
import '../widgets/chat_connection_banner.dart';
import '../widgets/chat_fab_badge.dart';
import '../widgets/chat_filter_chips.dart';
import '../widgets/chat_list_shimmer.dart';
import '../widgets/chat_search_bar.dart';
import '../widgets/chat_sync_banner.dart';
import '../widgets/chat_sync_status.dart';
import '../widgets/chat_tile.dart';

class ChatHomeScreen extends StatefulWidget {
  const ChatHomeScreen({super.key});

  @override
 State<ChatHomeScreen> createState() => _ChatHomeScreenState();
}

class _ChatHomeScreenState extends State<ChatHomeScreen> {
  final ChatService service = ChatService();

  late Future<List<ChatModel>> chats;

  bool isConnected = true;
  bool syncing = false;
  int unreadCount = 0;

  @override
  void initState() {
    super.initState();
    chats = service.getChats();
  }

  Future<void> _refreshChats() async {
    setState(() {
      syncing = true;
      chats = service.getChats();
    });

    await chats;

    if (!mounted) return;

    setState(() {
      syncing = false;

      // Temporary value.
      // Will come from backend in Phase 9.
      unreadCount = 4;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ChatAppBar(),

      floatingActionButton: ChatFabBadge(
        unreadCount: unreadCount,
        onPressed: () {},
      ),

      body: Column(
        children: [
          const SizedBox(height: 10),

          ChatSearchBar(
            onTap: () {},
          ),

          const SizedBox(height: 8),

          const ChatFilterChips(),

          const SizedBox(height: 8),

          ChatSyncBanner(
            syncing: syncing,
          ),

          const SizedBox(height: 8),

          ChatConnectionBanner(
            isConnected: isConnected,
          ),

          ChatSyncStatus(
            syncing: syncing,
          ),

          const SizedBox(height: 10),

          Expanded(
            child: FutureBuilder<List<ChatModel>>(
              future: chats,
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      "Failed to load chats",
                    ),
                  );
                }

                final chatsData = snapshot.data ?? [];

                if (chatsData.isEmpty) {
                  return const Center(
                    child: Text(
                      "No chats yet",
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: chatsData.length,
                  itemBuilder: (context, index) {
                    return ChatTile(
                      chat: chatsData[index],
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
