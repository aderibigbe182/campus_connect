import 'dart:async';
import 'package:flutter/material.dart';
import '../services/chat_service.dart';
import '../../../core/services/socket_service.dart';

import '../models/conversation_model.dart';
import '../models/message_model.dart';
import '../../../core/services/storage_service.dart';
import '../widgets/chat_tile.dart';
import 'conversation_screen.dart';
import '../services/chat_cache_service.dart';
class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
List<ConversationModel> chats = [];
bool loading = true;
bool _isLoadingMore = false;
bool _refreshQueued = false;
bool _hasMore = true;
int _page = 1;
final ScrollController _scrollController =
    ScrollController();
  StreamSubscription? chatSubscription;
  @override
void initState() {
  super.initState();

  _loadCachedChats();
  _initializeChats();

  _listenRelationshipUpdates();
  _listenNewMessages();
  _listenSeenUpdates();
  _listenChatListUpdates();

  loadChats(refresh: true);

  _scrollController.addListener(() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;

    if (position.maxScrollExtent <= 0) return;

    if (position.pixels >=
        position.maxScrollExtent - 300) {
      loadChats();
    }
  });
}
  @override
void dispose() {

  SocketService.instance.socket?.off("new_message");
  SocketService.instance.socket?.off("message_seen");
  _scrollController.dispose();
  SocketService.instance.socket?.off(
  "friend_request_sent",
  );
  SocketService.instance.socket?.off(
    "relationship_updated",
  );
  SocketService.instance.socket?.off(
    "friend_request_accepted",
  );
  SocketService.instance.socket?.off(
    "friend_request_declined",
  );

  super.dispose();
}
Future<void> _initializeChats() async {
  await _loadCachedChats();

  if (!mounted) return;

  await loadChats(
    refresh: true,
  );
}
Future<void> _loadCachedChats() async {
  final cached =
      ChatCacheService.instance.loadChats();

  if (cached.isEmpty) {
    return;
  }

  final cachedChats = cached
      .map(
        (e) => ConversationModel.fromJson(e),
      )
      .where(
        (c) => c.relationshipStatus != "declined",
      )
      .toList();

  if (!mounted) return;

  setState(() {
    chats = cachedChats;
    loading = false;
  });
}
Future<void> loadChats({
  bool refresh = false,
}) async {
  // ==========================================
  // QUEUED REFRESH
  // ==========================================
  if (refresh && _isLoadingMore) {
    _refreshQueued = true;
    return;
  }

  // ==========================================
  // PAGINATION GUARDS
  // ==========================================
  if (!refresh && (_isLoadingMore || !_hasMore)) {
    return;
  }

  // ==========================================
  // REFRESH RESET
  // ==========================================
  if (refresh) {
    _page = 1;
    _hasMore = true;
  }

  _isLoadingMore = true;

  // Only show the main loading indicator
  // when there are no chats available yet.
  if (mounted && chats.isEmpty) {
    setState(() {
      loading = true;
    });
  }

  try {
    // ==========================================
    // LOAD FROM SERVER
    // ==========================================
    final result = await ChatService.instance.getChatList(
      page: _page,
      limit: 20,
    );

    final List<ConversationModel> newChats =
        (result["chats"] as List<ConversationModel>)
            .where(
              (c) => c.relationshipStatus != "declined",
            )
            .toList();

    if (!mounted) return;

    setState(() {
      // ========================================
      // REFRESH
      // ========================================
      if (refresh) {
        chats = newChats;
      }

      // ========================================
      // PAGINATION
      // ========================================
      else {
        final existingIds = chats
            .map((c) => c.conversationId)
            .toSet();

        final uniqueChats = newChats
            .where(
              (c) => !existingIds.contains(
                c.conversationId,
              ),
            )
            .toList();

        chats.addAll(uniqueChats);
      }

      // ========================================
      // PAGINATION STATE
      // ========================================
      if (newChats.isEmpty) {
        _hasMore = false;
      } else {
        _hasMore = result["hasMore"] == true;

        if (_hasMore) {
          _page++;
        }
      }

      // ========================================
      // LOADING FINISHED
      // ========================================
      loading = false;
    });

    // ==========================================
    // SAVE CACHE
    // ==========================================
    await ChatCacheService.instance.saveChats(
      chats.map((e) => e.toJson()).toList(),
    );
  } catch (e) {
    debugPrint(
      "CHAT LIST ERROR: $e",
    );

    if (mounted) {
      setState(() {
        // IMPORTANT:
        // Never leave the screen in loading state
        // after an error.
        loading = false;
      });
    }
  } finally {
    // ==========================================
    // ALWAYS RELEASE LOADING LOCK
    // ==========================================
    _isLoadingMore = false;

    // ==========================================
    // RUN QUEUED REFRESH
    // ==========================================
    if (_refreshQueued) {
      _refreshQueued = false;

      // Do not await this.
      // It can otherwise create a chain of refreshes
      // that keeps the loading state alive.
      Future.microtask(
        () => loadChats(refresh: true),
      );
    }
  }
}
void _listenRelationshipUpdates() {
  final socket = SocketService.instance.socket;

  socket?.on("friend_request_sent", (data) async {
    debugPrint(
      "FRIEND REQUEST SENT SOCKET: $data",
    );

    await loadChats(refresh: true);
  });

  socket?.on("relationship_updated", (data) async {
    debugPrint(
      "RELATIONSHIP UPDATED SOCKET: $data",
    );

    await loadChats(refresh: true);
  });

  socket?.on("friend_request_accepted", (data) async {
    debugPrint(
      "FRIEND REQUEST ACCEPTED SOCKET: $data",
    );

    await loadChats(refresh: true);
  });

  socket?.on("friend_request_declined", (data) async {
    debugPrint(
      "FRIEND REQUEST DECLINED SOCKET: $data",
    );

    await loadChats(refresh: true);
  });
}
void _listenChatListUpdates() {
  SocketService.instance.listenChatListUpdated(
    (data) async {
      debugPrint(
        "========== CHAT LIST UPDATED ==========",
      );

      debugPrint(
        "DATA: $data",
      );

      await loadChats(
        refresh: true,
      );
    },
  );
}
void _listenNewMessages() {
  SocketService.instance.listenMessage((data) async {
    try {
      final message = MessageModel.fromJson(data);

      debugPrint("========== NEW MESSAGE FOR CHAT LIST ==========");
      debugPrint("Conversation ID: ${message.conversationId}");
      debugPrint("Message ID: ${message.id}");
      debugPrint("Message: ${message.message}");
      debugPrint("Created At: ${message.createdAt}");
      debugPrint("===============================================");

      final index = chats.indexWhere(
        (c) => c.conversationId == message.conversationId,
      );

      // ==========================================
      // NEW CONVERSATION
      // ==========================================
      if (index == -1) {
        debugPrint(
          "Conversation not currently in chat list. Refreshing chat list...",
        );

        await loadChats(refresh: true);
        return;
      }

      // ==========================================
      // EXISTING CONVERSATION
      // ==========================================
      final chat = chats[index];

      final updated = chat.copyWith(
        lastMessage: message.message,
        lastMessageType: message.messageType,
        lastMessageTime: message.createdAt,
        unreadCount: chat.unreadCount + 1,
      );

      if (!mounted) return;

      setState(() {
        chats.removeAt(index);
        chats.insert(0, updated);
      });

      await ChatCacheService.instance.saveChats(
        chats.map((e) => e.toJson()).toList(),
      );
    } catch (e) {
      debugPrint(
        "Error processing new message in chat list: $e",
      );
    }
  });
}
void _listenSeenUpdates() {

  SocketService.instance.listenMessageSeen((data) async {

    final messageId = data["messageId"];

    final index = chats.indexWhere((c) => c.lastMessage == messageId);

    if (index == -1) return;

    // Mark unread count as 0 when the last message is seen
    setState(() {
      chats[index] = chats[index].copyWith(
        unreadCount: 0,
      );
    });

    await ChatCacheService.instance.saveChats(
      chats.map((e) => e.toJson()).toList(),
    );

  });

}
Future<void> loadCachedChats() async {
  final cached = ChatCacheService.instance.loadChats();

  if (cached.isEmpty) return;

  final cachedChats = cached
      .map((e) => ConversationModel.fromJson(e))
      .toList();

  if (!mounted) return;

  setState(() {
    chats = cachedChats;
    loading = false;
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

    await ChatCacheService.instance.saveChats(
      chats.map((e) => e.toJson()).toList(),
    );
  }

  final currentUserId =
      await StorageService.getUserId();

  if (currentUserId == null) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Unable to identify the logged-in user.",
        ),
      ),
    );

    return;
  }

  if (!mounted) return;

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ConversationScreen(
        conversationId:
            chat.conversationId,
        receiverId:
            chat.receiverId,
        currentUserId:
            currentUserId,
        chatName:
            chat.fullName,
        profileImage:
            chat.profilePicture,
        isOnline:
            chat.isOnline,
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