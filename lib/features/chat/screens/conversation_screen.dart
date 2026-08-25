import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import '../models/message_model.dart';
import '../models/reply_message_model.dart';
import '../models/conversation_status_model.dart';

import '../services/chat_service.dart';
import '../services/chat_cache_service.dart';
import '/core/services/socket_listener_service.dart';

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

  // ============================================================
  // SERVICES
  // ============================================================

  final ChatService _chatService =
      ChatService.instance;

  final ChatCacheService _cacheService =
      ChatCacheService.instance;

  final SocketService _socketService =
      SocketService.instance;

  final SocketListenerService _socketListeners =
      SocketListenerService.instance;

  // ============================================================
  // STATE
  // ============================================================

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

  // ============================================================
  // SOCKET CALLBACKS
  // ============================================================

  late final void Function(dynamic)
      _newMessageListener;

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

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _conversationId =
        widget.conversationId;

    _isOnline =
        widget.isOnline;

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
      await _handleIncomingMessage(data);
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
      await _refreshRelationship();
    };

    _requestAcceptedListener =
        (dynamic data) async {
      await _refreshRelationship();
    };

    _requestDeclinedListener =
        (dynamic data) async {
      await _refreshRelationship();

      if (!mounted) return;

      Navigator.of(context).pop();
    };

    _relationshipUpdatedListener =
        (dynamic data) async {
      await _refreshRelationship();
    };
  }

  // ============================================================
  // REGISTER SOCKET LISTENERS
  // ============================================================

  void _registerSocketListeners() {

    _socketListeners.listenNewMessage(
      _newMessageListener,
    );

    _socketListeners.listenMessageSeen(
      _messageSeenListener,
    );

    _socketListeners.listenMessageDelivered(
      _messageDeliveredListener,
    );

    _socketListeners.listenTyping(
      _typingListener,
    );

    _socketListeners.listenStopTyping(
      _stopTypingListener,
    );

    _socketListeners.listenPresence(
      _presenceListener,
    );

    _socketListeners.listenFriendRequestSent(
      _requestSentListener,
    );

    _socketListeners.listenFriendRequestAccepted(
      _requestAcceptedListener,
    );

    _socketListeners.listenFriendRequestDeclined(
      _requestDeclinedListener,
    );

    _socketListeners.listenRelationshipUpdated(
      _relationshipUpdatedListener,
    );
  }

  // ============================================================
  // REMOVE SOCKET LISTENERS
  // ============================================================

  void _removeSocketListeners() {

    _socketService.socket?.off(
      "new_message",
      _newMessageListener,
    );

    _socketService.socket?.off(
      "message_seen",
      _messageSeenListener,
    );

    _socketService.socket?.off(
      "message_delivered",
      _messageDeliveredListener,
    );

    _socketService.socket?.off(
      "user_typing",
      _typingListener,
    );

    _socketService.socket?.off(
      "user_stopped_typing",
      _stopTypingListener,
    );

    _socketService.socket?.off(
      "userOnline",
      _presenceListener,
    );

    _socketService.socket?.off(
      "friend_request_sent",
      _requestSentListener,
    );

    _socketService.socket?.off(
      "friend_request_accepted",
      _requestAcceptedListener,
    );

    _socketService.socket?.off(
      "friend_request_declined",
      _requestDeclinedListener,
    );

    _socketService.socket?.off(
      "relationship_updated",
      _relationshipUpdatedListener,
    );
  }

  // ============================================================
  // INITIALIZE
  // ============================================================

  Future<void> _initializeConversation() async {

    try {

      await _loadConversationStatus();

      if (_conversationId != null) {

        await _joinConversation();

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
        "CONVERSATION INIT ERROR: $e",
      );

      if (!mounted) return;

      setState(() {
        _loading = false;
      });
    }
  }

  // ============================================================
  // JOIN CONVERSATION
  // ============================================================
 Future<void> _joinConversation() async {
  final id = _conversationId;

  if (id == null) return;

  final connected = await _socketService.ensureConnected();

  if (!connected) {
    debugPrint(
      '[ConversationScreen] Unable to connect socket. '
      'Conversation room not joined.',
    );
    return;
  }

  _socketService.joinConversation(id);
}
  // ============================================================
  // LEAVE CONVERSATION
  // ============================================================

  Future<void> _leaveConversation() async {

    final id = _conversationId;

    if (id == null) return;

    if (!_socketService.isConnected) {
      return;
    }

    _socketService.leaveConversation(id);
  }

  // ============================================================
  // CONVERSATION STATUS
  // ============================================================

  Future<void> _loadConversationStatus() async {

    try {

      final status =
          await _chatService.getConversationStatus(
        widget.receiverId,
      );

      if (!mounted) return;

      setState(() {

        _status = status;

        if (status.conversationId != null) {

          _conversationId =
              status.conversationId;
        }

      });

    } catch (e) {

      debugPrint(
        "STATUS ERROR: $e",
      );
    }
  }

  Future<void> _refreshRelationship() async {

    await _loadConversationStatus();

    if (_conversationId != null) {

      await _joinConversation();

      await _loadMessages(
        initialLoad: true,
      );
    }

    if (mounted) {
      setState(() {});
    }
  }

  // ============================================================
  // LOAD MESSAGES
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

      // --------------------------------------------------------
      // CACHE FIRST
      // --------------------------------------------------------

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
                    (item) =>
                        MessageModel.fromJson(
                      Map<String, dynamic>.from(
                        item,
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
          "CACHE LOAD ERROR: $e",
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

      setState(() {

        _messages
          ..clear()
          ..addAll(
            _deduplicateMessages(
              messages,
            ),
          );

        _loading = false;
      });

      await _saveMessagesToCache();

      _page = 1;

      _hasMore =
          messages.length >= _limit;

      WidgetsBinding.instance
          .addPostFrameCallback((_) {

        if (!mounted) return;

        _scrollToBottom(
          animated: false,
        );
      });

    } catch (e) {

      debugPrint(
        "LOAD MESSAGES ERROR: $e",
      );

      if (!mounted) return;

      setState(() {
        _loading = false;
      });
    }
  }

  // ============================================================
  // LOAD OLDER MESSAGES
  // ============================================================

  Future<void> _loadOlderMessages() async {

    if (_loadingOlder ||
        !_hasMore ||
        _conversationId == null) {
      return;
    }

    if (!_scrollController.hasClients) {
      return;
    }

    setState(() {
      _loadingOlder = true;
    });

    final oldMax =
        _scrollController
            .position
            .maxScrollExtent;

    final oldPixels =
        _scrollController
            .position
            .pixels;

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
        });

        return;
      }

      final existingIds =
          _messages
              .map((message) => message.id)
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

        if (older.length < _limit) {
          _hasMore = false;
        }
      });

      await _saveMessagesToCache();

      WidgetsBinding.instance
          .addPostFrameCallback((_) {

        if (!_scrollController.hasClients) {
          return;
        }

        final newMax =
            _scrollController
                .position
                .maxScrollExtent;

        final difference =
            newMax - oldMax;

        final target =
            oldPixels + difference;

        _scrollController.jumpTo(
          target.clamp(
            0.0,
            newMax,
          ),
        );
      });

    } catch (e) {

      debugPrint(
        "LOAD OLDER ERROR: $e",
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

  // ============================================================
  // NEW MESSAGE
  // ============================================================

  Future<void> _handleIncomingMessage(
    dynamic data,
  ) async {

    try {

      final map = _asMap(data);

      if (map.isEmpty) {
        return;
      }

      final message =
          MessageModel.fromJson(map);

      // --------------------------------------------------------
      // FIRST MESSAGE CREATED CONVERSATION
      // --------------------------------------------------------

      if (_conversationId == null) {

        _conversationId =
            message.conversationId;

        await _joinConversation();

        if (mounted) {
          setState(() {});
        }
      }

      // --------------------------------------------------------
      // WRONG CONVERSATION
      // --------------------------------------------------------

      if (message.conversationId !=
          _conversationId) {
        return;
      }

      // --------------------------------------------------------
      // DUPLICATE CHECK
      // --------------------------------------------------------

      final existingIndex =
          _messages.indexWhere(
        (item) =>
            item.id == message.id,
      );

      if (existingIndex != -1) {

        if (!mounted) return;

        setState(() {

          _messages[
              existingIndex] = message;
        });

        await _saveMessagesToCache();

        return;
      }

      final wasAtBottom =
          _isNearBottom();

      // --------------------------------------------------------
      // ADD MESSAGE
      // --------------------------------------------------------

      if (!mounted) return;

      setState(() {

        _messages.add(message);

        _messages.sort(
          (a, b) =>
              a.createdAt.compareTo(
            b.createdAt,
          ),
        );
      });

      await _saveMessagesToCache();

      // --------------------------------------------------------
      // RECEIVER ACKNOWLEDGEMENT
      // --------------------------------------------------------

      if (message.senderId !=
          widget.currentUserId) {

        await _markMessageDelivered(
          message,
        );

        await _markMessageSeen(
          message,
        );
      }

      // --------------------------------------------------------
      // SCROLL
      // --------------------------------------------------------

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
        "INCOMING MESSAGE ERROR: $e",
      );
    }
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

    if (_status?.canReply != true) {
      return;
    }

    if (_sending) {
      return;
    }

    if (!mounted) return;

    setState(() {
      _sending = true;
    });

    _stopTyping();

    try {

      final wasTemporary =
          _conversationId == null;

      // ========================================================
      // IMPORTANT:
      // Actual message is sent through HTTP.
      //
      // DO NOT call SocketService.sendMessage().
      // Backend saves the message and emits new_message.
      // ========================================================

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
      // FIRST MESSAGE CREATED CONVERSATION
      // --------------------------------------------------------

      if (wasTemporary) {

        _conversationId =
            sentMessage.conversationId;

        await _joinConversation();
      }

      // --------------------------------------------------------
      // ADD LOCAL RESPONSE
      //
      // The same message will later arrive through
      // new_message. _addOrReplaceMessage prevents duplication.
      // --------------------------------------------------------

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

      ScaffoldMessenger.of(context)
          .showSnackBar(
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

    if (_status?.canReply != true) {
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

      if (_conversationId == null) {

        _conversationId =
            message.conversationId;

        await _joinConversation();

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

      ScaffoldMessenger.of(context)
          .showSnackBar(
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

    if (_status?.canReply != true) {
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

        await _joinConversation();

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

      ScaffoldMessenger.of(context)
          .showSnackBar(
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
  // MESSAGE ADD / REPLACE
  // ============================================================

  void _addOrReplaceMessage(
    MessageModel message,
  ) {

    final index =
        _messages.indexWhere(
      (item) =>
          item.id == message.id,
    );

    if (!mounted) return;

    setState(() {

      if (index == -1) {

        _messages.add(message);

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
  // DELIVERED
  // ============================================================

  Future<void> _markMessageDelivered(
    MessageModel message,
  ) async {

    try {

      await _chatService.markMessageDelivered(
        messageId:
            message.id.toString(),
      );

    } catch (e) {

      debugPrint(
        "DELIVERED HTTP ERROR: $e",
      );
    }

    _socketService.sendDelivered(
      conversationId:
          message.conversationId,
      messageId:
          message.id,
    );

    final index =
        _messages.indexWhere(
      (item) =>
          item.id == message.id,
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

    await _saveMessagesToCache();
  }

  // ============================================================
  // SEEN
  // ============================================================

  Future<void> _markMessageSeen(
    MessageModel message,
  ) async {

    try {

      await _chatService.markMessageSeen(
        messageId:
            message.id.toString(),
      );

    } catch (e) {

      debugPrint(
        "SEEN HTTP ERROR: $e",
      );
    }

    _socketService.sendSeen(
      conversationId:
          message.conversationId,
      messageId:
          message.id,
    );

    final index =
        _messages.indexWhere(
      (item) =>
          item.id == message.id,
    );

    if (index == -1 ||
        !mounted) {
      return;
    }

    setState(() {

      _messages[index] =
          _messages[index].copyWith(
        delivered: true,
        seen: true,
      );
    });

    await _saveMessagesToCache();
  }

  // ============================================================
  // MESSAGE SEEN SOCKET EVENT
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
        delivered: true,
        seen: true,
      );
    });

    _saveMessagesToCache();
  }

  // ============================================================
  // MESSAGE DELIVERED SOCKET EVENT
  // ============================================================

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

  // ============================================================
  // SEND TYPING
  // ============================================================

  void sendTyping() {

    final conversationId =
        _conversationId;

    if (conversationId == null) {
      return;
    }

    _socketService.sendTyping(
      conversationId:
          conversationId,
      senderId:
          widget.currentUserId,
    );

    _typingTimer?.cancel();

    _typingTimer =
        Timer(
      const Duration(
        milliseconds: 1200,
      ),
      _stopTyping,
    );
  }

  void _stopTyping() {

    final conversationId =
        _conversationId;

    if (conversationId == null) {
      return;
    }

    _socketService.sendStopTyping(
      conversationId,
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

    final online =
        map["online"];

    setState(() {

      _isOnline =
          online is bool
              ? online
              : true;
    });
  }

  // ============================================================
  // MARK CONVERSATION READ
  // ============================================================

  Future<void> _markConversationRead() async {

    if (_conversationId == null) {
      return;
    }

    try {

      await _chatService.markConversationAsRead(
        conversationId:
            _conversationId!,
      );

    } catch (e) {

      debugPrint(
        "MARK READ ERROR: $e",
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
            message.message ?? "",
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

      await _chatService.deleteMessage(
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

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
    }
  }

  // ============================================================
  // ACCEPT REQUEST
  // ============================================================

  Future<void> _acceptRequest() async {

    final requestId =
        _status?.requestId;

    if (requestId == null) {
      return;
    }

    try {

      await _chatService.acceptRequest(
        requestId,
      );

      await _loadConversationStatus();

      if (_conversationId != null) {

        await _joinConversation();

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

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
    }
  }

  // ============================================================
  // DECLINE REQUEST
  // ============================================================

  Future<void> _declineRequest() async {

    final requestId =
        _status?.requestId;

    if (requestId == null) {
      return;
    }

    try {

      await _chatService.declineRequest(
        requestId,
      );

      if (!mounted) return;

      Navigator.of(context).pop();

    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
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

    if (!_scrollController.hasClients) {
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

    if (!_scrollController.hasClients) {
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

    if (!_scrollController.hasClients) {
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
  // CACHE
  // ============================================================

  Future<void> _saveMessagesToCache() async {

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
  // DEDUPLICATION
  // ============================================================

  List<MessageModel>
      _deduplicateMessages(
    List<MessageModel> messages,
  ) {

    final ids =
        <int>{};

    final result =
        <MessageModel>[];

    for (final message
        in messages) {

      if (ids.add(
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

  // ============================================================
  // MAP HELPERS
  // ============================================================

  Map<String, dynamic>
      _asMap(
    dynamic data,
  ) {

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
        onPressed:
            () =>
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
                    color:
                        _typing
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

        PopupMenuButton<String>(
          onSelected:
              (value) {},
          itemBuilder:
              (_) => const [

            PopupMenuItem(
              value: "search",
              child:
                  Text("Search"),
            ),

            PopupMenuItem(
              value: "media",
              child:
                  Text("Media"),
            ),

            PopupMenuItem(
              value: "mute",
              child:
                  Text("Mute"),
            ),

            PopupMenuItem(
              value: "clear",
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

    if (_messages.isEmpty &&
        !_typing) {

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
            (_typing ? 1 : 0) +
            (_loadingOlder ? 1 : 0);

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

        if (_loadingOlder &&
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
                (_loadingOlder
                    ? 1
                    : 0);

        if (_typing &&
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

        if (messageIndex < 0 ||
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

  // ============================================================
  // MESSAGE BUBBLE
  // ============================================================

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

        if (_replyMessage != null)

          ReplyPreview(
            reply:
                _replyMessage!,
            onCancel: () {

              if (!mounted) return;

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

            onCancelReply: () {

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

              final result =
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

              if (result is File) {

                await _sendImage(
                  result,
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
  // DISPOSE
  // ============================================================

  @override
  void dispose() {

    _typingTimer?.cancel();

    _stopTyping();

    _leaveConversation();

    _removeSocketListeners();

    _scrollController
        .removeListener(
      _onScroll,
    );

    _scrollController.dispose();

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

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

            if (_status?.status ==
                    "pending_received" ||
                _status?.status ==
                    "pending_sent" ||
                _status?.status ==
                    "declined")

              _buildRelationshipBanner(),

            _buildBottomSection(),
          ],
        ),
      ),
    );
  }
}