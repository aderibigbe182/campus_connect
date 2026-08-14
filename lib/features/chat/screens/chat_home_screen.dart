import 'package:flutter/material.dart';

import '../services/chat_service.dart';
import '../services/chat_cache_service.dart';

import '../../../core/services/socket_service.dart';
import '../../../core/services/socket_listener_service.dart';
import '../../../core/services/storage_service.dart';

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
  // ==========================================================
  // DATA
  // ==========================================================

  List<ConversationModel> chats = [];

  bool loading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;

  int _page = 1;

  final ScrollController _scrollController =
      ScrollController();

  // ==========================================================
  // SERVICES
  // ==========================================================

  final ChatService _chatService =
      ChatService.instance;

  final ChatCacheService _cacheService =
      ChatCacheService.instance;

  final SocketListenerService _socketListener =
      SocketListenerService.instance;

  // ==========================================================
  // INIT
  // ==========================================================

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(
      _onScroll,
    );

    _initialize();
  }

  Future<void> _initialize() async {
    await _loadCache();

    _registerSocketListeners();

    await _loadChats(
      refresh: true,
    );
  }

  // ==========================================================
  // CACHE
  // ==========================================================

  Future<void> _loadCache() async {
    try {
      final cached =
          _cacheService.loadChats();

      if (cached.isEmpty) {
        return;
      }

      final cachedChats = cached
          .map(
            (e) =>
                ConversationModel.fromJson(e),
          )
          .where(
            (chat) =>
                chat.relationshipStatus !=
                "declined",
          )
          .toList();

      if (!mounted) return;

      setState(() {
        chats = cachedChats;
        loading = false;
      });
    } catch (e) {
      debugPrint(
        "CHAT CACHE ERROR: $e",
      );
    }
  }

  Future<void> _saveCache() async {
    try {
      await _cacheService.saveChats(
        chats
            .map(
              (chat) => chat.toJson(),
            )
            .toList(),
      );
    } catch (e) {
      debugPrint(
        "SAVE CHAT CACHE ERROR: $e",
      );
    }
  }

  // ==========================================================
  // LOAD CHATS
  // ==========================================================

  Future<void> _loadChats({
    bool refresh = false,
  }) async {
    if (_isLoadingMore) {
      return;
    }

    if (!refresh && !_hasMore) {
      return;
    }

    if (refresh) {
      _page = 1;
      _hasMore = true;
    }

    _isLoadingMore = true;

    if (refresh && mounted) {
      setState(() {
        loading = chats.isEmpty;
      });
    }

    try {
      final result =
          await _chatService.getChatList(
        page: _page,
        limit: 20,
      );

      final List<ConversationModel>
          newChats =
          (result["chats"]
                  as List<ConversationModel>)
              .where(
                (chat) =>
                    chat.relationshipStatus !=
                    "declined",
              )
              .toList();

      if (!mounted) return;

      setState(() {
        // ==================================================
        // REFRESH
        // ==================================================

        if (refresh) {
          chats = newChats;
        }

        // ==================================================
        // PAGINATION
        // ==================================================

        else {
          final existingIds = chats
              .map(
                (chat) =>
                    chat.conversationId,
              )
              .toSet();

          final uniqueChats =
              newChats.where(
            (chat) =>
                !existingIds.contains(
              chat.conversationId,
            ),
          );

          chats.addAll(
            uniqueChats,
          );
        }

        // ==================================================
        // PAGINATION STATE
        // ==================================================

        _hasMore =
            result["hasMore"] == true;

        if (_hasMore) {
          _page++;
        }

        loading = false;
      });

      await _saveCache();
    } catch (e, stackTrace) {
      debugPrint(
        "========== CHAT LIST ERROR ==========",
      );

      debugPrint("$e");
      debugPrint("$stackTrace");

      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    } finally {
      _isLoadingMore = false;
    }
  }

  // ==========================================================
  // PAGINATION
  // ==========================================================

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    if (_isLoadingMore) {
      return;
    }

    if (!_hasMore) {
      return;
    }

    final position =
        _scrollController.position;

    if (position.maxScrollExtent <= 0) {
      return;
    }

    if (position.pixels >=
        position.maxScrollExtent - 300) {
      _loadChats();
    }
  }

  // ==========================================================
  // SOCKET LISTENERS
  // ==========================================================

  void _registerSocketListeners() {
    // --------------------------------------------------------
    // NEW MESSAGE
    // --------------------------------------------------------

    _socketListener.listenNewMessage(
      _handleNewMessage,
    );

    // --------------------------------------------------------
    // MESSAGE SEEN
    // --------------------------------------------------------

    _socketListener.listenMessageSeen(
      _handleMessageSeen,
    );

    // --------------------------------------------------------
    // MESSAGE DELIVERED
    // --------------------------------------------------------

    _socketListener.listenMessageDelivered(
      _handleMessageDelivered,
    );

    // --------------------------------------------------------
    // FRIEND REQUEST SENT
    // --------------------------------------------------------

    _socketListener.listenFriendRequestSent(
      (_) {
        _loadChats(
          refresh: true,
        );
      },
    );

    // --------------------------------------------------------
    // FRIEND REQUEST ACCEPTED
    // --------------------------------------------------------

    _socketListener.listenFriendRequestAccepted(
      (_) {
        _loadChats(
          refresh: true,
        );
      },
    );

    // --------------------------------------------------------
    // FRIEND REQUEST DECLINED
    // --------------------------------------------------------

    _socketListener.listenFriendRequestDeclined(
      (_) {
        _loadChats(
          refresh: true,
        );
      },
    );

    // --------------------------------------------------------
    // RELATIONSHIP UPDATED
    // --------------------------------------------------------

    _socketListener.listenRelationshipUpdated(
      (_) {
        _loadChats(
          refresh: true,
        );
      },
    );

    // --------------------------------------------------------
    // CHAT LIST UPDATED
    // --------------------------------------------------------

    _socketListener.listenChatListUpdated(
      (_) {
        _loadChats(
          refresh: true,
        );
      },
    );
  }

  // ==========================================================
  // NEW MESSAGE
  // ==========================================================

  Future<void> _handleNewMessage(
    dynamic data,
  ) async {
    try {
      final message =
          MessageModel.fromJson(data);

      debugPrint(
        "========== NEW MESSAGE ==========",
      );

      debugPrint(
        "Conversation: ${message.conversationId}",
      );

      debugPrint(
        "Message: ${message.message}",
      );

      // ------------------------------------------------------
      // FIND CONVERSATION
      // ------------------------------------------------------

      final index = chats.indexWhere(
        (chat) =>
            chat.conversationId ==
            message.conversationId,
      );

      // ------------------------------------------------------
      // CONVERSATION NOT IN LIST
      // ------------------------------------------------------

      if (index == -1) {
        await _loadChats(
          refresh: true,
        );

        return;
      }

      // ------------------------------------------------------
      // UPDATE EXISTING CHAT
      // ------------------------------------------------------

      final chat = chats[index];

      final updatedChat =
          chat.copyWith(
        lastMessage:
            message.message,

        lastMessageType:
            message.messageType,

        lastMessageTime:
            message.createdAt,

        unreadCount:
            chat.unreadCount + 1,
      );

      if (!mounted) return;

      setState(() {
        chats.removeAt(index);

        chats.insert(
          0,
          updatedChat,
        );
      });

      await _saveCache();
    } catch (e) {
      debugPrint(
        "NEW MESSAGE CHAT LIST ERROR: $e",
      );
    }
  }

  // ==========================================================
  // MESSAGE SEEN
  // ==========================================================

  Future<void> _handleMessageSeen(
    dynamic data,
  ) async {
    try {
      final conversationId =
          data["conversationId"];

      if (conversationId == null) {
        return;
      }

      final index = chats.indexWhere(
        (chat) =>
            chat.conversationId ==
            int.tryParse(
              conversationId.toString(),
            ),
      );

      if (index == -1) {
        return;
      }

      if (!mounted) return;

      setState(() {
        chats[index] =
            chats[index].copyWith(
          unreadCount: 0,
        );
      });

      await _saveCache();
    } catch (e) {
      debugPrint(
        "MESSAGE SEEN CHAT LIST ERROR: $e",
      );
    }
  }

  // ==========================================================
  // MESSAGE DELIVERED
  // ==========================================================

  Future<void> _handleMessageDelivered(
    dynamic data,
  ) async {
    debugPrint(
      "MESSAGE DELIVERED: $data",
    );

    // Chat list normally does not need
    // to change for delivery.
    //
    // ConversationScreen handles
    // individual message delivery state.
  }

  // ==========================================================
  // OPEN CHAT
  // ==========================================================

  Future<void> _openConversation(
    ConversationModel chat,
  ) async {
    // --------------------------------------------------------
    // CLEAR LOCAL UNREAD COUNT
    // --------------------------------------------------------

    final index = chats.indexWhere(
      (item) =>
          item.conversationId ==
          chat.conversationId,
    );

    if (index != -1 && mounted) {
      setState(() {
        chats[index] =
            chats[index].copyWith(
          unreadCount: 0,
        );
      });

      await _saveCache();
    }

    // --------------------------------------------------------
    // CURRENT USER
    // --------------------------------------------------------

    final currentUserId =
        await StorageService.getUserId();

    if (currentUserId == null) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Unable to identify the logged-in user.",
          ),
        ),
      );

      return;
    }

    // --------------------------------------------------------
    // OPEN CONVERSATION
    // --------------------------------------------------------

    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ConversationScreen(
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

    // --------------------------------------------------------
    // REFRESH AFTER RETURNING
    // --------------------------------------------------------

    if (!mounted) return;

    await _loadChats(
      refresh: true,
    );
  }

  // ==========================================================
  // DISPOSE
  // ==========================================================

  @override
  void dispose() {
    _socketListener.removeListener(
      "new_message",
    );

    _socketListener.removeListener(
      "message_seen",
    );

    _socketListener.removeListener(
      "message_delivered",
    );

    _socketListener.removeListener(
      "friend_request_sent",
    );

    _socketListener.removeListener(
      "friend_request_accepted",
    );

    _socketListener.removeListener(
      "friend_request_declined",
    );

    _socketListener.removeListener(
      "relationship_updated",
    );

    _socketListener.removeListener(
      "chat_list_updated",
    );

    _scrollController.dispose();

    super.dispose();
  }

  // ==========================================================
  // UI
  // ==========================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Chats",
        ),
        centerTitle: false,
      ),

      body: loading && chats.isEmpty
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : chats.isEmpty
              ? const Center(
                  child: Text(
                    "No conversations yet",
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () =>
                      _loadChats(
                    refresh: true,
                  ),

                  child:
                      ListView.builder(
                    controller:
                        _scrollController,

                    physics:
                        const AlwaysScrollableScrollPhysics(),

                    itemCount:
                        chats.length +
                            (_isLoadingMore
                                ? 1
                                : 0),

                    itemBuilder:
                        (
                      context,
                      index,
                    ) {
                      // ------------------------------------------------
                      // PAGINATION LOADER
                      // ------------------------------------------------

                      if (index ==
                          chats.length) {
                        return const Padding(
                          padding:
                              EdgeInsets.symmetric(
                            vertical: 16,
                          ),

                          child: Center(
                            child:
                                CircularProgressIndicator(),
                          ),
                        );
                      }

                      // ------------------------------------------------
                      // CHAT
                      // ------------------------------------------------

                      final chat =
                          chats[index];

                      return ChatTile(
                        chat: chat,

                        onTap: () =>
                            _openConversation(
                          chat,
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}