import 'dart:async';
import 'package:flutter/material.dart';
import '../services/chat_service.dart';
import '../../../core/services/socket_service.dart';

import '../models/conversation_model.dart';
import '../models/message_model.dart';
import '../widgets/chat_tile.dart';
import 'conversation_screen.dart';
class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
List<ConversationModel> chats = [];
bool loading = true;
bool _isLoadingMore = false;
bool _hasMore = true;
int _page = 1;
final ScrollController _scrollController =
    ScrollController();
  StreamSubscription? chatSubscription;
    @override
  void initState() {
    super.initState();
    loadChats();
    _scrollController.addListener(() {
  if (_scrollController.position.pixels >=
      _scrollController.position.maxScrollExtent - 300) {
    loadChats();
  }
});
    _moveChatToTop();
    _listenNewMessages();
    _listenSeenUpdates();
  }
  @override
void dispose() {

  SocketService.instance.socket?.off("new_message");
  SocketService.instance.socket?.off("message_seen");
  _scrollController.dispose();

  super.dispose();
}
Future<void> loadChats({
  bool refresh = false,
}) async {

  if (refresh) {
    _page = 1;
    _hasMore = true;
    chats.clear();
  }

  if (_isLoadingMore || !_hasMore) return;

  _isLoadingMore = true;

  try {

    final result =
        await ChatService.instance.getChatList(
      page: _page,
      limit: 20,
    );

    final List<ConversationModel> newChats =
        (result["chats"] as List<ConversationModel>)
            .where(
              (c) =>
                  c.relationshipStatus != "declined",
            )
            .toList();

    if (!mounted) return;

    setState(() {

      chats.addAll(newChats);

      _hasMore = result["hasMore"];

      _page++;

      loading = false;

    });

  } catch (e) {

    debugPrint(e.toString());

    if (mounted) {
      setState(() {
        loading = false;
      });
    }

  } finally {

    _isLoadingMore = false;

  }
}
void _listenNewMessages() {

  SocketService.instance.listenMessage((data) {

    final message = MessageModel.fromJson(data);

    final index = chats.indexWhere(
      (c) => c.conversationId ==
          message.conversationId.toString(),
    );

    if (index == -1) return;

    final chat = chats[index];

    final updated = chat.copyWith(
      lastMessage: message.id.toString(),
      lastMessageTime: message.createdAt,
      unreadCount: chat.unreadCount + 1,
    );

    setState(() {

      chats.removeAt(index);

      chats.insert(0, updated);

    });

  });

}
void _moveChatToTop([ConversationModel? chat]) {
  if (chat == null) return;

  chats.removeWhere(
    (c) => c.conversationId == chat.conversationId,
  );

  // If ConversationModel doesn't support pinning, insert at start
  int insertIndex = chats.indexWhere((c) => true);

  if (insertIndex == -1) {
    insertIndex = chats.length;
  }

  chats.insert(insertIndex, chat);

  if (mounted) {
    setState(() {});
  }
}
void _listenSeenUpdates() {

  SocketService.instance.listenMessageSeen((data) {

    final messageId = data["messageId"];

    final index = chats.indexWhere((c) => c.lastMessage == messageId);

    if (index == -1) return;

    // Mark unread count as 0 when the last message is seen
    setState(() {
      chats[index] = chats[index].copyWith(
        unreadCount: 0,
      );
    });

  });

}
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text("Chats"),
      centerTitle: false,
    ),

   body: loading
    ? const Center(
        child: CircularProgressIndicator(),
      )
    : chats.isEmpty
        ? const Center(
            child: Text(
              "No conversations yet",
            ),
          )
        : ListView.builder(
            controller: _scrollController,
            itemCount: chats.length + (_isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == chats.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final chat = chats[index];
              return ChatTile(
                chat: chat,
                onTap: () async {

  final index = chats.indexWhere(
    (c) =>
        c.conversationId ==
        chat.conversationId,
  );

  if (index != -1) {

    setState(() {

      chats[index] =
          chats[index].copyWith(
        unreadCount: 0,
      );

    });

  }

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ConversationScreen(
        conversationId:
            chat.conversationId.toString(),
        receiverId: 0,
        currentUserId: 1,
        chatName:
            chat.fullName,
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