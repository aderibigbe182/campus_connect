import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import '../models/message_model.dart';
import '../models/reply_message_model.dart';
import '../models/conversation_status_model.dart';

import '../services/chat_service.dart';
import '../services/chat_cache_service.dart';

import '/core/services/socket_service.dart';

import '../widgets/message_input_bar.dart';
import '../widgets/reply_preview.dart';
import '../widgets/typing_indicator.dart';
import '../widgets/sender_message_bubble.dart';
import '../widgets/receiver_message_bubble.dart';
import '../widgets/image_message_bubble.dart';
import '../widgets/request_banner.dart';

import 'image_preview_screen.dart';

class ConversationScreen extends StatefulWidget {
  final int? conversationId;
  final int receiverId;
  final int currentUserId;
  final String chatName;
  final String? profileImage;
  final bool isOnline;
  final bool isPending;

  const ConversationScreen({
    super.key,
    required this.conversationId,
    required this.receiverId,
    required this.currentUserId,
    required this.chatName,
    this.profileImage,
    this.isOnline = false,
    this.isPending = false,
  });

  @override
  State<ConversationScreen> createState() =>
      _ConversationScreenState();
}

class _ConversationScreenState
    extends State<ConversationScreen> {
  final ChatService _chatService =
      ChatService.instance;

  final ChatCacheService _cacheService =
      ChatCacheService.instance;

  final SocketService _socketService =
      SocketService.instance;

  final ScrollController _scrollController =
      ScrollController();

  final List<MessageModel> _messages = [];

  ConversationStatusModel? _status;

  ReplyMessageModel? _replyMessage;

  int? _conversationId;

  int _page = 1;

  static const int _limit = 30;

  bool _loading = true;
  bool _loadingOlder = false;
  bool _sending = false;
  bool _typing = false;
  bool _isOnline = false;
  bool _hasMore = true;

  Timer? _typingTimer;

  // ------------------------------------------------------------
  // SOCKET CALLBACKS
  //
  // These are stored as fields so we can remove ONLY our
  // listeners in dispose(), instead of clearing listeners
  // belonging to ChatHomeScreen or other parts of the app.
  // ------------------------------------------------------------

  late final void Function(dynamic)
      _newMessageListener;

  late final void Function(dynamic)
      _chatListMessageListener;

  late final void Function(dynamic)
      _messageSeenListener;

  late final void Function(dynamic)
      _messageDeliveredListener;

  late final void Function(dynamic)
      _typingListener;

  late final void Function(dynamic)
      _stopTypingListener;

  late final void Function(dynamic)
      _presenceListener;

  late final void Function(dynamic)
      _requestSentListener;

  late final void Function(dynamic)
      _requestAcceptedListener;

  late final void Function(dynamic)
      _requestDeclinedListener;

  late final void Function(dynamic)
      _relationshipUpdatedListener;

  @override
  void initState() {
    super.initState();

    _conversationId =
        widget.conversationId;

    _isOnline = widget.isOnline;

    _createSocketCallbacks();

    _registerSocketListeners();

    _scrollController.addListener(
      _onScroll,
    );

    _initializeConversation();
  }

  // ============================================================
  // SOCKET CALLBACK SETUP
  // ============================================================

  void _createSocketCallbacks() {
    _newMessageListener =
        (dynamic data) async {
      await _handleIncomingMessage(
        data,
        source: "new_message",
      );
    };

    _chatListMessageListener =
        (dynamic data) async {
      await _handleIncomingMessage(
        data,
        source: "chat_list_updated",
      );
    };

    _messageSeenListener =
        (dynamic data) {
      _handleMessageSeen(data);
    };

    _messageDeliveredListener =
        (dynamic data) {
      _handleMessageDelivered(data);
    };

    _typingListener =
        (dynamic data) {
      _handleTyping(data);
    };

    _stopTypingListener =
        (dynamic data) {
      _handleStopTyping(data);
    };

    _presenceListener =
        (dynamic data) {
      _handlePresence(data);
    };

    _requestSentListener =
        (dynamic data) async {
      await _handleRelationshipSocketEvent(
        data,
        "friend_request_sent",
      );
    };

    _requestAcceptedListener =
        (dynamic data) async {
      await _handleRelationshipSocketEvent(
        data,
        "friend_request_accepted",
      );
    };

    _requestDeclinedListener =
        (dynamic data) async {
      await _handleRelationshipSocketEvent(
        data,
        "friend_request_declined",
      );
    };

    _relationshipUpdatedListener =
        (dynamic data) async {
      await _handleRelationshipSocketEvent(
        data,
        "relationship_updated",
      );
    };
  }

  void _registerSocketListeners() {
    final socket =
        _socketService.socket;

    if (socket == null) {
      return;
    }

    // ----------------------------------------------------------
    // MESSAGE EVENTS
    // ----------------------------------------------------------

    socket.on(
      "new_message",
      _newMessageListener,
    );

    // Important:
    //
    // The backend also sends chat_list_updated to the receiver.
    // We listen to it here as a second delivery path.
    //
    // This means the receiver can still receive the message
    // through the user room even when it wasn't received through
    // the conversation room.
    socket.on(
      "chat_list_updated",
      _chatListMessageListener,
    );

    // ----------------------------------------------------------
    // MESSAGE STATUS
    // ----------------------------------------------------------

    socket.on(
      "message_seen",
      _messageSeenListener,
    );

    socket.on(
      "message_delivered",
      _messageDeliveredListener,
    );

    // Some older SocketService versions emit these names.
    // We don't use SocketService.listenTyping() because the
    // current SocketService doesn't expose those methods.
    socket.on(
      "user_typing",
      _typingListener,
    );

    socket.on(
      "user_stopped_typing",
      _stopTypingListener,
    );

    // ----------------------------------------------------------
    // PRESENCE
    // ----------------------------------------------------------

    socket.on(
      "userOnline",
      _presenceListener,
    );

    // Keep compatibility with the older event name used by
    // previous versions of this screen.
    socket.on(
      "presence",
      _presenceListener,
    );

    // ----------------------------------------------------------
    // RELATIONSHIP EVENTS
    // ----------------------------------------------------------

    socket.on(
      "friend_request_sent",
      _requestSentListener,
    );

    socket.on(
      "friend_request_accepted",
      _requestAcceptedListener,
    );

    socket.on(
      "friend_request_declined",
      _requestDeclinedListener,
    );

    socket.on(
      "relationship_updated",
      _relationshipUpdatedListener,
    );
  }

  void _removeSocketListeners() {
    final socket =
        _socketService.socket;

    if (socket == null) {
      return;
    }

    socket.off(
      "new_message",
      _newMessageListener,
    );

    socket.off(
      "chat_list_updated",
      _chatListMessageListener,
    );

    socket.off(
      "message_seen",
      _messageSeenListener,
    );

    socket.off(
      "message_delivered",
      _messageDeliveredListener,
    );

    socket.off(
      "user_typing",
      _typingListener,
    );

    socket.off(
      "user_stopped_typing",
      _stopTypingListener,
    );

    socket.off(
      "userOnline",
      _presenceListener,
    );

    socket.off(
      "presence",
      _presenceListener,
    );

    socket.off(
      "friend_request_sent",
      _requestSentListener,
    );

    socket.off(
      "friend_request_accepted",
      _requestAcceptedListener,
    );

    socket.off(
      "friend_request_declined",
      _requestDeclinedListener,
    );

    socket.off(
      "relationship_updated",
      _relationshipUpdatedListener,
    );
  }

  // ============================================================
  // INITIALIZATION
  // ============================================================

  Future<void> _initializeConversation() async {
    try {
      await _loadConversationStatus();

      if (_conversationId != null) {
        await _joinConversationRoom(
          _conversationId!,
        );

        await _loadMessages(
          initialLoad: true,
        );

        await _markConversationRead();
      } else {
        if (!mounted) return;

        setState(() {
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint(
        "CONVERSATION INITIALIZATION ERROR: $e",
      );

      if (!mounted) return;

      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _joinConversationRoom(
    int conversationId,
  ) async {
    if (!_socketService.isConnected) {
      return;
    }

    _socketService.joinConversation(
      conversationId,
    );
  }

  Future<void> _leaveConversationRoom() async {
    final id = _conversationId;

    if (id == null) {
      return;
    }

    if (!_socketService.isConnected) {
      return;
    }

    _socketService.leaveConversation(
      id,
    );
  }

  // ============================================================
  // CONVERSATION STATUS
  // ============================================================

  Future<void> _loadConversationStatus() async {
    try {
      final status =
          await _chatService
              .getConversationStatus(
        widget.receiverId,
      );

      if (!mounted) return;

      setState(() {
        _status = status;

        // The status endpoint can provide the real conversation
        // ID after a request has become a conversation.
        if (status.conversationId != null &&
            status.conversationId !=
                _conversationId) {
          _conversationId =
              status.conversationId;
        }
      });
    } catch (e) {
      debugPrint(
        "CONVERSATION STATUS ERROR: $e",
      );
    }
  }

  Future<void> _handleRelationshipSocketEvent(
    dynamic data,
    String event,
  ) async {
    try {
      final map =
          _asMap(data);

      final eventConversationId =
          _readInt(
        map,
        "conversationId",
      );

      // If the event contains a conversation ID,
      // ignore events belonging to another chat.
      if (eventConversationId != null &&
          _conversationId != null &&
          eventConversationId !=
              _conversationId) {
        return;
      }

      await _loadConversationStatus();

      // An accepted request can create/activate a conversation.
      if (_status?.conversationId != null) {
        final newId =
            _status!.conversationId!;

        if (newId != _conversationId) {
          if (_conversationId != null) {
            await _leaveConversationRoom();
          }

          _conversationId = newId;

          await _joinConversationRoom(
            newId,
          );
        }

        await _loadMessages(
          initialLoad: true,
        );
      }

      if (event ==
          "friend_request_declined") {
        if (!mounted) return;

        // The existing architecture closes the conversation
        // after a declined request.
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint(
        "$event HANDLER ERROR: $e",
      );
    }
  }

  // ============================================================
  // MESSAGE LOADING
  // ============================================================

  Future<void> _loadMessages({
    bool initialLoad = false,
  }) async {
    final conversationId =
        _conversationId;

    if (conversationId == null) {
      return;
    }

    if (initialLoad) {
      _page = 1;
      _hasMore = true;
    }

    // ----------------------------------------------------------
    // CACHE FIRST
    // ----------------------------------------------------------

    if (initialLoad) {
      try {
        final cached =
            _cacheService.loadMessages(
          conversationId,
        );

        if (cached.isNotEmpty &&
            mounted) {
          final cachedMessages =
              cached
                  .map(
                    (e) =>
                        MessageModel.fromJson(
                      Map<String, dynamic>.from(
                        e,
                      ),
                    ),
                  )
                  .toList();

          setState(() {
            _messages
              ..clear()
              ..addAll(
                _deduplicateMessages(
                  cachedMessages,
                ),
              );

            _loading = false;
          });

          _scrollToBottom(
            animated: false,
          );
        }
      } catch (e) {
        debugPrint(
          "CACHE MESSAGE LOAD ERROR: $e",
        );
      }
    }

    // ----------------------------------------------------------
    // SERVER
    // ----------------------------------------------------------

    try {
      final messages =
          await _chatService.getMessages(
        conversationId,
        page: 1,
        limit: _limit,
      );

      if (!mounted) return;

      final cleanMessages =
          _deduplicateMessages(
        messages,
      );

      setState(() {
        _messages
          ..clear()
          ..addAll(cleanMessages);

        _loading = false;
      });

      await _saveMessagesToCache();

      WidgetsBinding.instance
          .addPostFrameCallback((_) {
        if (!mounted) return;

        _scrollToBottom(
          animated: false,
        );
      });

      // Reset pagination because page 1 was
      // just loaded from the server.
      _page = 1;

      if (messages.length <
          _limit) {
        _hasMore = false;
      } else {
        _hasMore = true;
      }
    } catch (e) {
      debugPrint(
        "LOAD MESSAGES ERROR: $e",
      );

      if (!mounted) return;

      // If cached messages already exist,
      // don't replace them with an error state.
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _loadOlderMessages() async {
    if (_loadingOlder ||
        !_hasMore ||
        _conversationId == null) {
      return;
    }

    if (!_scrollController.hasClients) {
      return;
    }

    _loadingOlder = true;

    final oldMaxScrollExtent =
        _scrollController
            .position
            .maxScrollExtent;

    final oldPixels =
        _scrollController.position.pixels;

    final nextPage =
        _page + 1;

    try {
      final older =
          await _chatService.getMessages(
        _conversationId!,
        page: nextPage,
        limit: _limit,
      );

      if (!mounted) return;

      if (older.isEmpty) {
        setState(() {
          _hasMore = false;
          _loadingOlder = false;
        });

        return;
      }

      final existingIds =
          _messages
              .map((e) => e.id)
              .toSet();

      final uniqueOlder =
          older
              .where(
                (message) =>
                    !existingIds.contains(
                  message.id,
                ),
              )
              .toList();

      setState(() {
        _page = nextPage;

        _messages.insertAll(
          0,
          uniqueOlder,
        );

        if (older.length <
            _limit) {
          _hasMore = false;
        }
      });

      await _saveMessagesToCache();

      WidgetsBinding.instance
          .addPostFrameCallback((_) {
        if (!_scrollController
            .hasClients) {
          return;
        }

        final newMaxScrollExtent =
            _scrollController
                .position
                .maxScrollExtent;

        final heightDifference =
            newMaxScrollExtent -
            oldMaxScrollExtent;

        final target =
            oldPixels +
            heightDifference;

        final max =
            _scrollController
                .position
                .maxScrollExtent;

        _scrollController.jumpTo(
          target.clamp(
            0.0,
            max,
          ),
        );
      });
    } catch (e) {
      debugPrint(
        "LOAD OLDER MESSAGES ERROR: $e",
      );
    } finally {
      if (mounted) {
        setState(() {
          _loadingOlder = false;
        });
      } else {
        _loadingOlder = false;
      }
    }
  }

  List<MessageModel>
      _deduplicateMessages(
    List<MessageModel> messages,
  ) {
    final seenIds =
        <int>{};

    final result =
        <MessageModel>[];

    for (final message
        in messages) {
      if (seenIds.add(
        message.id,
      )) {
        result.add(message);
      }
    }

    result.sort(
      (a, b) =>
          a.createdAt.compareTo(
        b.createdAt,
      ),
    );

    return result;
  }

  Future<void>
      _saveMessagesToCache() async {
    if (_conversationId == null) {
      return;
    }

    await _cacheService.saveMessages(
      _conversationId!,
      _messages
          .map(
            (message) =>
                message.toJson(),
          )
          .toList(),
    );
  }

  // ============================================================
  // REAL-TIME MESSAGE HANDLING
  // ============================================================

  Future<void> _handleIncomingMessage(
    dynamic data, {
    required String source,
  }) async {
    try {
      final map =
          _asMap(data);

      if (map.isEmpty) {
        return;
      }

      final message =
          MessageModel.fromJson(
        map,
      );

      // --------------------------------------------------------
      // If this screen doesn't know the conversation ID yet,
      // a socket message can establish it.
      // --------------------------------------------------------

      if (_conversationId == null) {
        _conversationId =
            message.conversationId;

        await _joinConversationRoom(
          message.conversationId,
        );

        if (mounted) {
          setState(() {});
        }
      }

      // --------------------------------------------------------
      // Ignore messages from other conversations.
      // --------------------------------------------------------

      if (message.conversationId !=
          _conversationId) {
        return;
      }

      // --------------------------------------------------------
      // Prevent duplicate delivery.
      //
      // This is especially important because:
      //
      // new_message
      //
      // and
      //
      // chat_list_updated
      //
      // can represent the same message.
      // --------------------------------------------------------

      final existingIndex =
          _messages.indexWhere(
        (item) =>
            item.id == message.id,
      );

      if (existingIndex != -1) {
        // The server can send a newer version of
        // the same message containing delivered/seen
        // state. Replace it.
        if (mounted) {
          setState(() {
            _messages[
                existingIndex] =
                message;
          });
        }

        await _saveMessagesToCache();

        return;
      }

      final wasAtBottom =
          _isNearBottom();

      if (!mounted) {
        return;
      }

      setState(() {
        _messages.add(message);

        _messages.sort(
          (a, b) =>
              a.createdAt
                  .compareTo(
            b.createdAt,
          ),
        );
      });

      await _saveMessagesToCache();

      // --------------------------------------------------------
      // RECEIVER DELIVERY
      // --------------------------------------------------------
      //
      // If the incoming message belongs to the other user,
      // acknowledge delivery immediately.
      //
      // This does NOT depend on the user opening/reopening
      // the conversation.
      // --------------------------------------------------------

      if (message.senderId !=
          widget.currentUserId) {
        await _acknowledgeDelivery(
          message,
        );

        // ------------------------------------------------------
        // If the conversation is currently open, it is also
        // immediately considered seen/read.
        // ------------------------------------------------------

        await _acknowledgeSeen(
          message,
        );
      }

      WidgetsBinding.instance
          .addPostFrameCallback((_) {
        if (!mounted) return;

        if (wasAtBottom ||
            message.senderId !=
                widget.currentUserId) {
          _scrollToBottom();
        }
      });
    } catch (e) {
      debugPrint(
        "INCOMING MESSAGE ERROR [$source]: $e",
      );
    }
  }

  Future<void>
      _acknowledgeDelivery(
    MessageModel message,
  ) async {
    if (_conversationId == null) {
      return;
    }

    try {
      // HTTP makes sure the database state is updated.
      await _chatService
          .markMessageDelivered(
        messageId:
            message.id.toString(),
      );
    } catch (e) {
      debugPrint(
        "HTTP DELIVERY ACK ERROR: $e",
      );
    }

    try {
      // Socket makes sure the sender's open conversation
      // receives the delivered update immediately.
      _socketService.sendDelivered(
        conversationId:
            message.conversationId,
        messageId:
            message.id,
      );
    } catch (e) {
      debugPrint(
        "SOCKET DELIVERY ACK ERROR: $e",
      );
    }

    final index =
        _messages.indexWhere(
      (item) =>
          item.id == message.id,
    );

    if (index != -1 &&
        mounted) {
      setState(() {
        _messages[index] =
            _messages[index].copyWith(
          delivered: true,
        );
      });

      await _saveMessagesToCache();
    }
  }

  Future<void>
      _acknowledgeSeen(
    MessageModel message,
  ) async {
    try {
      await _chatService
          .markMessageSeen(
        messageId:
            message.id.toString(),
      );
    } catch (e) {
      debugPrint(
        "HTTP SEEN ACK ERROR: $e",
      );
    }

    try {
      _socketService.sendSeen(
        conversationId:
            message.conversationId,
        messageId:
            message.id,
      );
    } catch (e) {
      debugPrint(
        "SOCKET SEEN ACK ERROR: $e",
      );
    }

    final index =
        _messages.indexWhere(
      (item) =>
          item.id == message.id,
    );

    if (index != -1 &&
        mounted) {
      setState(() {
        _messages[index] =
            _messages[index].copyWith(
          delivered: true,
          seen: true,
        );
      });

      await _saveMessagesToCache();
    }
  }

  // ============================================================
  // SEEN / DELIVERED EVENTS
  // ============================================================

  void _handleMessageSeen(
    dynamic data,
  ) {
    final map =
        _asMap(data);

    final conversationId =
        _readInt(
      map,
      "conversationId",
    );

    final messageId =
        _readInt(
      map,
      "messageId",
    );

    if (messageId == null) {
      return;
    }

    if (conversationId != null &&
        conversationId !=
            _conversationId) {
      return;
    }

    final index =
        _messages.indexWhere(
      (message) =>
          message.id ==
          messageId,
    );

    if (index == -1 ||
        !mounted) {
      return;
    }

    setState(() {
      _messages[index] =
          _messages[index].copyWith(
        seen: true,
        delivered: true,
      );
    });

    _saveMessagesToCache();
  }

  void _handleMessageDelivered(
    dynamic data,
  ) {
    final map =
        _asMap(data);

    final conversationId =
        _readInt(
      map,
      "conversationId",
    );

    final messageId =
        _readInt(
      map,
      "messageId",
    );

    if (messageId == null) {
      return;
    }

    if (conversationId != null &&
        conversationId !=
            _conversationId) {
      return;
    }

    final index =
        _messages.indexWhere(
      (message) =>
          message.id ==
          messageId,
    );

    if (index == -1 ||
        !mounted) {
      return;
    }

    setState(() {
      _messages[index] =
          _messages[index].copyWith(
        delivered: true,
      );
    });

    _saveMessagesToCache();
  }

  // ============================================================
  // TYPING
  // ============================================================

  void _handleTyping(
    dynamic data,
  ) {
    final map =
        _asMap(data);

    final conversationId =
        _readInt(
      map,
      "conversationId",
    );

    final senderId =
        _readInt(
      map,
      "senderId",
    );

    if (conversationId !=
        _conversationId) {
      return;
    }

    if (senderId !=
        widget.receiverId) {
      return;
    }

    if (!mounted) return;

    setState(() {
      _typing = true;
    });
  }

  void _handleStopTyping(
    dynamic data,
  ) {
    final map =
        _asMap(data);

    final conversationId =
        _readInt(
      map,
      "conversationId",
    );

    final senderId =
        _readInt(
      map,
      "senderId",
    );

    if (conversationId !=
        _conversationId) {
      return;
    }

    if (senderId !=
        widget.receiverId) {
      return;
    }

    if (!mounted) return;

    setState(() {
      _typing = false;
    });
  }

  void sendTyping() {
    final conversationId =
        _conversationId;

    if (conversationId == null) {
      return;
    }

    _socketService.socket?.emit(
      "typing",
      {
        "conversationId":
            conversationId,
        "senderId":
            widget.currentUserId,
      },
    );

    _typingTimer?.cancel();

    _typingTimer = Timer(
      const Duration(
        milliseconds: 1200,
      ),
      _stopSendingTyping,
    );
  }

  void _stopSendingTyping() {
    final conversationId =
        _conversationId;

    if (conversationId == null) {
      return;
    }

    _socketService.socket?.emit(
      "stopTyping",
      {
        "conversationId":
            conversationId,
        "senderId":
            widget.currentUserId,
      },
    );
  }

  // ============================================================
  // PRESENCE
  // ============================================================

  void _handlePresence(
    dynamic data,
  ) {
    final map =
        _asMap(data);

    final userId =
        _readInt(
      map,
      "userId",
    );

    if (userId !=
        widget.receiverId) {
      return;
    }

    if (!mounted) return;

    final onlineValue =
        map["online"];

    setState(() {
      // Current backend's userOnline event represents
      // the user coming online and doesn't always contain
      // an explicit "online" boolean.
      _isOnline =
          onlineValue is bool
              ? onlineValue
              : true;
    });
  }

  // ============================================================
  // SEND TEXT
  // ============================================================

  Future<void> _sendText(
    String text,
  ) async {
    final trimmed =
        text.trim();

    if (trimmed.isEmpty) {
      return;
    }

    if (_status?.canReply !=
        true) {
      return;
    }

    if (_sending) {
      return;
    }

    if (!mounted) return;

    setState(() {
      _sending = true;
    });

    _stopSendingTyping();

    try {
      final wasTemporary =
          _conversationId == null;

      final sentMessage =
          await _chatService.sendMessage(
        conversationId:
            _conversationId,
        receiverId:
            widget.receiverId,
        message:
            trimmed,
        reply:
            _replyMessage,
      );

      // --------------------------------------------------------
      // TEMPORARY -> REAL CONVERSATION
      // --------------------------------------------------------

      if (wasTemporary) {
        final newConversationId =
            sentMessage
                .conversationId;

        _conversationId =
            newConversationId;

        await _joinConversationRoom(
          newConversationId,
        );
      }

      _addOrReplaceMessage(
        sentMessage,
      );

      await _saveMessagesToCache();

      await _loadConversationStatus();

      if (!mounted) return;

      setState(() {
        _replyMessage = null;
      });

      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _sending = false;
        });
      }
    }
  }

  // ============================================================
  // SEND IMAGE
  // ============================================================

  Future<void> _sendImage(
    File image,
  ) async {
    if (_status?.canReply !=
        true) {
      return;
    }

    if (_sending) {
      return;
    }

    if (!mounted) return;

    setState(() {
      _sending = true;
    });

    try {
      final message =
          await _chatService.sendMessage(
        conversationId:
            _conversationId,
        receiverId:
            widget.receiverId,
        message: "",
        messageType:
            "image",
        fileUrl:
            image.path,
        fileName:
            image.path.split(
          Platform.pathSeparator,
        ).last,
        fileSize:
            await image.length(),
        reply:
            _replyMessage,
      );

      // If this was the first message,
      // the backend may have created the conversation.
      if (_conversationId == null) {
        _conversationId =
            message.conversationId;

        await _joinConversationRoom(
          message.conversationId,
        );

        await _loadConversationStatus();
      }

      _addOrReplaceMessage(
        message,
      );

      await _saveMessagesToCache();

      if (!mounted) return;

      setState(() {
        _replyMessage = null;
      });

      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _sending = false;
        });
      }
    }
  }

  // ============================================================
  // SEND FILE
  // ============================================================

  Future<void> _sendFile(
    File file,
  ) async {
    if (_status?.canReply !=
        true) {
      return;
    }

    if (_sending) {
      return;
    }

    if (!mounted) return;

    setState(() {
      _sending = true;
    });

    try {
      final message =
          await _chatService.sendMessage(
        conversationId:
            _conversationId,
        receiverId:
            widget.receiverId,
        message: "",
        messageType:
            "file",
        fileUrl:
            file.path,
        fileName:
            file.path.split(
          Platform.pathSeparator,
        ).last,
        fileSize:
            await file.length(),
        reply:
            _replyMessage,
      );

      if (_conversationId == null) {
        _conversationId =
            message.conversationId;

        await _joinConversationRoom(
          message.conversationId,
        );

        await _loadConversationStatus();
      }

      _addOrReplaceMessage(
        message,
      );

      await _saveMessagesToCache();

      if (!mounted) return;

      setState(() {
        _replyMessage = null;
      });

      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _sending = false;
        });
      }
    }
  }

  void _addOrReplaceMessage(
    MessageModel message,
  ) {
    final index =
        _messages.indexWhere(
      (item) =>
          item.id == message.id,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      if (index == -1) {
        _messages.add(
          message,
        );
      } else {
        _messages[index] =
            message;
      }

      _messages.sort(
        (a, b) =>
            a.createdAt.compareTo(
          b.createdAt,
        ),
      );
    });
  }

  // ============================================================
  // MARK CONVERSATION AS READ
  // ============================================================

  Future<void>
      _markConversationRead() async {
    if (_conversationId ==
        null) {
      return;
    }

    try {
      await _chatService
          .markConversationAsRead(
        conversationId:
            _conversationId!,
      );
    } catch (e) {
      debugPrint(
        "MARK CONVERSATION READ ERROR: $e",
      );
    }
  }

  // ============================================================
  // REPLY
  // ============================================================

  void _replyToMessage(
    MessageModel message,
  ) {
    if (!mounted) return;

    setState(() {
      _replyMessage =
          ReplyMessageModel(
        messageId:
            message.id,
        sender:
            message.senderId ==
                    widget.currentUserId
                ? "You"
                : widget.chatName,
        message:
            message.message ??
                "",
      );
    });
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<void> _deleteMessage(
    int messageId,
  ) async {
    try {
      await _chatService
          .deleteMessage(
        messageId:
            messageId.toString(),
      );

      if (!mounted) return;

      setState(() {
        _messages.removeWhere(
          (message) =>
              message.id ==
              messageId,
        );
      });

      await _saveMessagesToCache();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
    }
  }

  // ============================================================
  // SCROLL
  // ============================================================

  void _onScroll() {
    if (!_scrollController
        .hasClients) {
      return;
    }

    if (_scrollController
            .position
            .pixels <=
        80) {
      _loadOlderMessages();
    }
  }

  bool _isNearBottom() {
    if (!_scrollController
        .hasClients) {
      return true;
    }

    final distance =
        _scrollController
                .position
                .maxScrollExtent -
            _scrollController
                .position
                .pixels;

    return distance < 180;
  }

  void _scrollToBottom({
    bool animated = true,
  }) {
    if (!_scrollController
        .hasClients) {
      return;
    }

    final target =
        _scrollController
            .position
            .maxScrollExtent;

    if (!animated) {
      _scrollController.jumpTo(
        target,
      );
      return;
    }

    _scrollController.animateTo(
      target,
      duration:
          const Duration(
        milliseconds: 250,
      ),
      curve:
          Curves.easeOut,
    );
  }

  // ============================================================
  // APP BAR
  // ============================================================

  PreferredSizeWidget
      _buildAppBar() {
    return AppBar(
      elevation: 0,
      centerTitle: false,
      leading:
          IconButton(
        icon:
            const Icon(
          Icons.arrow_back,
        ),
        onPressed: () =>
            Navigator.pop(
          context,
        ),
      ),
      titleSpacing: 0,
      title:
          Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage:
                widget.profileImage !=
                        null
                    ? NetworkImage(
                        widget.profileImage!,
                      )
                    : null,
            child:
                widget.profileImage ==
                        null
                    ? Text(
                        widget.chatName
                                .isNotEmpty
                            ? widget
                                .chatName[0]
                                .toUpperCase()
                            : "?",
                      )
                    : null,
          ),
          const SizedBox(
            width: 12,
          ),
          Expanded(
            child:
                Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  widget.chatName,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      const TextStyle(
                    fontSize: 17,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
                const SizedBox(
                  height: 2,
                ),
                Text(
                  _typing
                      ? "typing..."
                      : (_isOnline
                          ? "Online"
                          : "Offline"),
                  style:
                      TextStyle(
                    fontSize: 12,
                    color: _typing
                        ? Colors.green
                        : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon:
              const Icon(
            Icons.call,
          ),
          onPressed: () {},
        ),
        IconButton(
          icon:
              const Icon(
            Icons.videocam,
          ),
          onPressed: () {},
        ),
        PopupMenuButton<
            String>(
          onSelected:
              (value) {},
          itemBuilder:
              (_) =>
                  const [
            PopupMenuItem(
              value:
                  "search",
              child:
                  Text("Search"),
            ),
            PopupMenuItem(
              value:
                  "media",
              child:
                  Text("Media"),
            ),
            PopupMenuItem(
              value:
                  "mute",
              child:
                  Text("Mute"),
            ),
            PopupMenuItem(
              value:
                  "clear",
              child:
                  Text("Clear Chat"),
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // RELATIONSHIP BANNER
  // ============================================================

  Widget _buildRelationshipBanner() {
    final status =
        _status;

    if (status == null) {
      return const SizedBox.shrink();
    }

    switch (status.status) {
      case "pending_received":
        return RequestBanner(
          title:
              "${widget.chatName} wants to be your friend",
          subtitle:
              "Accept this request to continue chatting.",
          primaryText:
              "Accept",
          secondaryText:
              "Decline",
          onPrimary:
              _acceptRequest,
          onSecondary:
              _declineRequest,
        );

      case "pending_sent":
        return RequestBanner(
          title:
              "Request sent",
          subtitle:
              "Waiting for ${widget.chatName} to accept.",
        );

      case "declined":
        return RequestBanner(
          title:
              "Request declined",
          subtitle:
              "You can send another request later.",
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Future<void> _acceptRequest() async {
    final requestId =
        _status?.requestId;

    if (requestId == null) {
      return;
    }

    try {
      await _chatService
          .acceptRequest(
        requestId,
      );

      await _loadConversationStatus();

      if (_conversationId !=
          null) {
        await _joinConversationRoom(
          _conversationId!,
        );

        await _loadMessages(
          initialLoad: true,
        );

        await _markConversationRead();
      }

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
    }
  }

  Future<void> _declineRequest() async {
    final requestId =
        _status?.requestId;

    if (requestId == null) {
      return;
    }

    try {
      await _chatService
          .declineRequest(
        requestId,
      );

      if (!mounted) return;

      Navigator.of(
        context,
      ).pop();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
    }
  }

  // ============================================================
  // MESSAGE LIST
  // ============================================================

  Widget _buildMessagesList() {
    if (_loading) {
      return const Center(
        child:
            CircularProgressIndicator(),
      );
    }

    final showTyping =
        _typing;

    final showLoadingOlder =
        _loadingOlder;

    if (_messages.isEmpty &&
        !showTyping) {
      return Center(
        child: Text(
          _status?.status ==
                  "none"
              ? "Start a conversation with ${widget.chatName}"
              : "No messages yet",
          textAlign:
              TextAlign.center,
        ),
      );
    }

    final itemCount =
        _messages.length +
            (showTyping
                ? 1
                : 0) +
            (showLoadingOlder
                ? 1
                : 0);

    return ListView.builder(
      controller:
          _scrollController,
      padding:
          const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      itemCount:
          itemCount,
      itemBuilder:
          (context, index) {
        // ------------------------------------------------------
        // Older-message loading indicator
        // ------------------------------------------------------

        if (showLoadingOlder &&
            index == 0) {
          return const Padding(
            padding:
                EdgeInsets.symmetric(
              vertical: 10,
            ),
            child: Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child:
                    CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
            ),
          );
        }

        final messageIndex =
            index -
                (showLoadingOlder
                    ? 1
                    : 0);

        // ------------------------------------------------------
        // Typing indicator
        // ------------------------------------------------------

        if (showTyping &&
            messageIndex ==
                _messages.length) {
          return const Padding(
            padding:
                EdgeInsets.only(
              left: 12,
              top: 8,
              bottom: 8,
            ),
            child:
                TypingIndicator(
              visible: true,
            ),
          );
        }

        if (messageIndex <
                0 ||
            messageIndex >=
                _messages.length) {
          return const SizedBox.shrink();
        }

        return _buildMessageBubble(
          _messages[
              messageIndex],
        );
      },
    );
  }

  Widget _buildMessageBubble(
    MessageModel message,
  ) {
    final isMe =
        message.senderId ==
            widget.currentUserId;

    if (message.messageType ==
        "image") {
      return ImageMessageBubble(
        isMe: isMe,
        imageUrl:
            message.message ??
                message.fileUrl ??
                "",
        createdAt:
            message.createdAt,
      );
    }

    if (isMe) {
      return SenderMessageBubble(
        message:
            message.message ??
                "",
        createdAt:
            message.createdAt,
        delivered:
            message.delivered,
        seen:
            message.seen,
        onReply:
            () =>
                _replyToMessage(
          message,
        ),
        onDelete:
            () =>
                _deleteMessage(
          message.id,
        ),
        onEdit: () {},
      );
    }

    return ReceiverMessageBubble(
      message:
          message.message ??
              "",
      createdAt:
          message.createdAt,
      onReply:
          () =>
              _replyToMessage(
        message,
      ),
    );
  }

  // ============================================================
  // BOTTOM SECTION
  // ============================================================

  Widget _buildBottomSection() {
    return Column(
      mainAxisSize:
          MainAxisSize.min,
      children: [
        if (_replyMessage !=
            null)
          ReplyPreview(
            reply:
                _replyMessage!,
            onCancel: () {
              if (!mounted) {
                return;
              }

              setState(() {
                _replyMessage =
                    null;
              });
            },
          ),

        if (_status?.canReply ==
            true)
          MessageInputBar(
            visible:
                true,
            reply:
                _replyMessage,
            onCancelReply:
                () {
              if (!mounted) {
                return;
              }

              setState(() {
                _replyMessage =
                    null;
              });
            },
            onSendText:
                _sendText,
            onSendImage:
                (
              image,
              caption,
            ) async {
              final file =
                  await Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) =>
                          ImagePreviewScreen(
                    imageFile:
                        image,
                  ),
                ),
              );

              if (!mounted) {
                return;
              }

              if (file
                  is File) {
                await _sendImage(
                  file,
                );
              }
            },
            onSendFile:
                _sendFile,
            onSendVoice:
                (audio) async {},
          )
        else
          const SizedBox(
            height: 10,
          ),
      ],
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  Map<String, dynamic>
      _asMap(dynamic data) {
    if (data
        is Map<String, dynamic>) {
      return data;
    }

    if (data is Map) {
      return Map<String, dynamic>.from(
        data,
      );
    }

    return {};
  }

  int? _readInt(
    Map<String, dynamic> map,
    String key,
  ) {
    final value =
        map[key];

    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    return int.tryParse(
      value.toString(),
    );
  }

  @override
  void dispose() {
    _typingTimer?.cancel();

    _stopSendingTyping();

    _leaveConversationRoom();

    _removeSocketListeners();

    _scrollController
        .removeListener(
      _onScroll,
    );

    _scrollController
        .dispose();

    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar:
          _buildAppBar(),
      body:
          SafeArea(
        child:
            Column(
          children: [
            Expanded(
              child:
                  _buildMessagesList(),
            ),

            // --------------------------------------------------
            // Relationship state
            // --------------------------------------------------

            if (_status?.status ==
                    "pending_received" ||
                _status?.status ==
                    "pending_sent" ||
                _status?.status ==
                    "declined")
              _buildRelationshipBanner(),

            // --------------------------------------------------
            // Message composer
            // --------------------------------------------------

            _buildBottomSection(),
          ],
        ),
      ),
    );
  }
}