import 'package:flutter/material.dart';
import '../widgets/chat_list_shimmer.dart';
import '../models/chat_model.dart';
import '../services/chat_service.dart';
import '../widgets/chat_app_bar.dart';
import '../widgets/chat_search_bar.dart';
import '../widgets/chat_tile.dart';
import '../widgets/empty_chat_state.dart';
import '../widgets/chat_refresh_indicator.dart';
import '../widgets/floating_new_chat_button.dart';
import '../widgets/chat_connection_banner.dart';
import '../widgets/chat_sync_status.dart';
import '../widgets/chat_fab_badge.dart';
import '../widgets/chat_filter_chips.dart';
import '../widgets/chat_sync_banner.dart';
import '../widgets/chat_floating_button.dart';

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

  if (mounted) {
    setState(() {
      syncing = false;
      // Temporary value.
  // Will come from backend in Phase 9.
  unreadCount = 4;
    });
  }
}
  await chats;
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ChatAppBar(),
      floatingActionButton: ChatFloatingButton(
  onPressed: () {},
),
      floatingActionButton: ChatFabBadge(
  unreadCount: unreadCount,
  onPressed: () {},
),
      body: Column(
        children: [
          const SizedBox(height: 10),

          body: Column(
  children: [

    ChatSearchBar(
      onTap: () {},
    ),

    const SizedBox(height: 8),
const ChatFilterChips(),
    ChatSyncBanner(
  syncing: syncing,
),
const SizedBox(height: 10),

    ChatFilterTabs(
      onChanged: (index) {},
    ),
ChatConnectionBanner(
  isConnected: isConnected,
),

ChatSyncStatus(
  syncing: syncing,
),

const SizedBox(height: 10),

    const SizedBox(height: 10),

    Expanded(
      child: FutureBuilder<List<ChatModel>>(
        // existing code...
      ),
    ),

  ],
),

          const SizedBox(height: 10),

          Expanded(
            child: FutureBuilder<List<ChatModel>>(
              future: chats,
              builder: (context, snapshot) {

                if (!snapshot.hasData) {
                 return const ChatListShimmer();
                }

                final data = snapshot.data!;
                if (data.isEmpty) {
  return const EmptyChatState();
                  return ChatRefreshIndicator(
  onRefresh: _refreshChats,
  child: ListView.builder(
    itemCount: data.length,
    itemBuilder: (context, index) {
      return ChatTile(
        chat: data[index],
        onTap: () {},
                    );
                  },
                ),
              },
            ),
          ),
        ],
      ),
    );
  }
}
