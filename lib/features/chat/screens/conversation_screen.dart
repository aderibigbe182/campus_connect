import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import '../models/message_model.dart';
import '../models/reply_message_model.dart';
import '../models/conversation_status_model.dart';

import '../services/chat_service.dart';
import '../services/chat_cache_service.dart';

import '../../../core/services/socket_listener_service.dart';

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
  // ===========================================================
  // STATE
  // ===========================================================

  bool _loading = true;
  bool _sending = false;
  bool _typing = false;
  bool _isOnline = false;

  ConversationStatusModel? _status;

  ReplyMessageModel? _replyMessage;

  final List<MessageModel> _messages = [];

  int? _conversationId;

  int _page = 1;

  final int _limit = 30;

  bool _hasMore = true;
  bool _loadingOlder = false;

  final ScrollController _scrollController =
      ScrollController();

  // ===========================================================
  // INIT
  // ===========================================================

  @override
  void initState() {
    super.initState();

    _conversationId = widget.conversationId;
    _isOnline = widget.isOnline;

    _scrollController.addListener(_onScroll);

    _registerSocketListeners();

    _initializeConversation();
  }

  // ===========================================================
  // SOCKET LISTENERS
  // ===========================================================

  void _registerSocketListeners() {
    final listener =
        SocketListenerService.instance;

    // ---------------------------------------------------------
    // NEW MESSAGE
    // ---------------------------------------------------------

    listener.listenNewMessage(
      _handleNewMessage,
    );

    // ---------------------------------------------------------
    // MESSAGE SEEN
    // ---------------------------------------------------------

    listener.listenMessageSeen(
      _handleMessageSeen,
    );

    // ---------------------------------------------------------
    // TYPING
    // ---------------------------------------------------------

    listener.listenTyping(
      _handleTyping,
    );

    // ---------------------------------------------------------
    // STOP TYPING
    // ---------------------------------------------------------

    listener.listenStopTyping(
      _handleStopTyping,
    );

    // ---------------------------------------------------------
    // PRESENCE
    // ---------------------------------------------------------

    listener.listenPresence(
      _handlePresence,
    );

    // ---------------------------------------------------------
    // REQUEST ACCEPTED
    // ---------------------------------------------------------

    listener.listenFriendRequestAccepted(
      _handleRequestAccepted,
    );

    // ---------------------------------------------------------
    // REQUEST DECLINED
    // ---------------------------------------------------------

    listener.listenFriendRequestDeclined(
      _handleRequestDeclined,
    );
  }

  // ===========================================================
  // SOCKET EVENT: NEW MESSAGE
  // ===========================================================

  Future<void> _handleNewMessage(
    dynamic data,
  ) async {
    try {
      final message =
          MessageModel.fromJson(
        Map<String, dynamic>.from(data),
      );

      // No conversation yet.
      if (_conversationId == null) {
        return;
      }

      // Message belongs to another conversation.
      if (message.conversationId !=
          _conversationId) {
        return;
      }

      // Prevent duplicates.
      final exists = _messages.any(
        (m) => m.id == message.id,
      );

      if (exists) {
        return;
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _messages.add(message);
      });

      await ChatCacheService.instance.saveMessages(
        _conversationId!,
        _messages
            .map((e) => e.toJson())
            .toList(),
      );

      WidgetsBinding.instance
          .addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } catch (e) {
      debugPrint(
        "NEW MESSAGE SOCKET ERROR: $e",
      );
    }
  }

  // ===========================================================
  // SOCKET EVENT: MESSAGE SEEN
  // ===========================================================

  void _handleMessageSeen(
    dynamic data,
  ) {
    try {
      final messageId =
          int.tryParse(
        data["messageId"].toString(),
      );

      if (messageId == null) {
        return;
      }

      final index = _messages.indexWhere(
        (message) =>
            message.id == messageId,
      );

      if (index == -1) {
        return;
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _messages[index] =
            _messages[index].copyWith(
          seen: true,
        );
      });
    } catch (e) {
      debugPrint(
        "MESSAGE SEEN SOCKET ERROR: $e",
      );
    }
  }

  // ===========================================================
  // SOCKET EVENT: TYPING
  // ===========================================================

  void _handleTyping(
    dynamic data,
  ) {
    if (!_isEventFromReceiver(data)) {
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _typing = true;
    });
  }

  // ===========================================================
  // SOCKET EVENT: STOP TYPING
  // ===========================================================

  void _handleStopTyping(
    dynamic data,
  ) {
    if (!_isEventFromReceiver(data)) {
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _typing = false;
    });
  }

  // ===========================================================
  // CHECK SOCKET EVENT USER
  // ===========================================================

  bool _isEventFromReceiver(
    dynamic data,
  ) {
    if (data is! Map) {
      return true;
    }

    final userId =
        int.tryParse(
      data["userId"]?.toString() ?? "",
    );

    // If backend doesn't provide userId,
    // don't reject the event.
    if (userId == null) {
      return true;
    }

    return userId == widget.receiverId;
  }

  // ===========================================================
  // SOCKET EVENT: PRESENCE
  // ===========================================================

  void _handlePresence(
    dynamic data,
  ) {
    try {
      if (data is! Map) {
        return;
      }

      final userId =
          int.tryParse(
        data["userId"]?.toString() ?? "",
      );

      if (userId != widget.receiverId) {
        return;
      }

      final online =
          data["online"] == true;

      if (!mounted) {
        return;
      }

      setState(() {
        _isOnline = online;
      });
    } catch (e) {
      debugPrint(
        "PRESENCE SOCKET ERROR: $e",
      );
    }
  }

  // ===========================================================
  // SOCKET EVENT: REQUEST ACCEPTED
  // ===========================================================

  Future<void> _handleRequestAccepted(
    dynamic data,
  ) async {
    try {
      if (data is! Map) {
        return;
      }

      final conversationId =
          int.tryParse(
        data["conversationId"]?.toString() ??
            "",
      );

      if (conversationId == null) {
        return;
      }

      if (_conversationId != null &&
          conversationId !=
              _conversationId) {
        return;
      }

      await _loadConversationStatus();

      if (_conversationId != null) {
        await _loadMessages(
          scrollToBottom: true,
        );
      }
    } catch (e) {
      debugPrint(
        "REQUEST ACCEPTED SOCKET ERROR: $e",
      );
    }
  }

  // ===========================================================
  // SOCKET EVENT: REQUEST DECLINED
  // ===========================================================

  Future<void> _handleRequestDeclined(
    dynamic data,
  ) async {
    try {
      if (data is! Map) {
        return;
      }

      final conversationId =
          int.tryParse(
        data["conversationId"]?.toString() ??
            "",
      );

      if (conversationId == null) {
        return;
      }

      if (_conversationId != null &&
          conversationId !=
              _conversationId) {
        return;
      }

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop();
    } catch (e) {
      debugPrint(
        "REQUEST DECLINED SOCKET ERROR: $e",
      );
    }
  }

  // ===========================================================
  // DISPOSE
  // ===========================================================

  @override
  void dispose() {
    final listener =
        SocketListenerService.instance;

    listener.removeListener(
      "new_message",
    );

    listener.removeListener(
      "message_seen",
    );

    listener.removeListener(
      "user_typing",
    );

    listener.removeListener(
      "user_stopped_typing",
    );

    listener.removeListener(
      "userOnline",
    );

    listener.removeListener(
      "friend_request_accepted",
    );

    listener.removeListener(
      "friend_request_declined",
    );

    _scrollController.removeListener(
      _onScroll,
    );

    _scrollController.dispose();

    super.dispose();
  }

  // ===========================================================
  // INITIALIZE CONVERSATION
  // ===========================================================

  Future<void> _initializeConversation() async {
    try {
      await _loadConversationStatus();

      if (_conversationId != null) {
        await _loadMessages(
          scrollToBottom: true,
        );

        await ChatService.instance
            .markConversationAsRead(
          conversationId: _conversationId!,
        );
      } else {
        if (!mounted) {
          return;
        }

        setState(() {
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint(
        "INITIALIZE CONVERSATION ERROR: $e",
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;
      });
    }
  }

  // ===========================================================
  // CONVERSATION STATUS
  // ===========================================================

  Future<void> _loadConversationStatus() async {
    try {
      final status =
          await ChatService.instance
              .getConversationStatus(
        widget.receiverId,
      );

      debugPrint(
        "========== CONVERSATION STATUS ==========",
      );

      debugPrint(
        "status: ${status.status}",
      );

      debugPrint(
        "canReply: ${status.canReply}",
      );

      debugPrint(
        "pending: ${status.pending}",
      );

      debugPrint(
        "isRequester: ${status.isRequester}",
      );

      debugPrint(
        "conversationId: ${status.conversationId}",
      );

      debugPrint(
        "requestId: ${status.requestId}",
      );

      debugPrint(
        "=========================================",
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _status = status;

        if (status.conversationId !=
            null) {
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

  // ===========================================================
  // SCROLL
  // ===========================================================

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    if (_loadingOlder) {
      return;
    }

    if (!_hasMore) {
      return;
    }

    if (_scrollController.position.pixels <=
        80) {
      _loadOlderMessages();
    }
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) {
      return;
    }

    _scrollController.animateTo(
      _scrollController.position
          .maxScrollExtent,
      duration:
          const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  // ===========================================================
  // LOAD MESSAGES
  // ===========================================================

  Future<void> _loadMessages({
    bool scrollToBottom = false,
  }) async {
    if (_conversationId == null) {
      return;
    }

    final conversationId =
        _conversationId!;

    // ---------------------------------------------------------
    // CACHE
    // ---------------------------------------------------------

    final cached =
        ChatCacheService.instance
            .loadMessages(
      conversationId,
    );

    if (cached.isNotEmpty &&
        mounted) {
      setState(() {
        _messages
          ..clear()
          ..addAll(
            cached
                .map(
                  (e) =>
                      MessageModel.fromJson(e),
                )
                .toList(),
          );

        _loading = false;
      });

      if (scrollToBottom) {
        WidgetsBinding.instance
            .addPostFrameCallback((_) {
          _scrollToBottom();
        });
      }
    }

    // ---------------------------------------------------------
    // SERVER
    // ---------------------------------------------------------

    try {
      final messages =
          await ChatService.instance
              .getMessages(
        conversationId,
        page: 1,
        limit: _limit,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _page = 1;

        _messages
          ..clear()
          ..addAll(messages);

        _hasMore =
            messages.length >= _limit;

        _loading = false;
      });

      await ChatCacheService.instance
          .saveMessages(
        conversationId,
        _messages
            .map((e) => e.toJson())
            .toList(),
      );

      if (scrollToBottom) {
        WidgetsBinding.instance
            .addPostFrameCallback((_) {
          _scrollToBottom();
        });
      }
    } catch (e) {
      debugPrint(
        "LOAD MESSAGES ERROR: $e",
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;
      });
    }
  }

  // ===========================================================
  // LOAD OLDER MESSAGES
  // ===========================================================

  Future<void> _loadOlderMessages() async {
    if (_loadingOlder ||
        _conversationId == null ||
        !_hasMore) {
      return;
    }

    if (!_scrollController.hasClients) {
      return;
    }

    _loadingOlder = true;

    if (mounted) {
      setState(() {});
    }

    try {
      final oldMaxExtent =
          _scrollController
              .position
              .maxScrollExtent;

      final nextPage = _page + 1;

      final older =
          await ChatService.instance
              .getMessages(
        _conversationId!,
        page: nextPage,
        limit: _limit,
      );

      if (!mounted) {
        return;
      }

      if (older.isEmpty) {
        setState(() {
          _hasMore = false;
          _loadingOlder = false;
        });

        return;
      }

      setState(() {
        _page = nextPage;

        _messages.insertAll(
          0,
          older,
        );

        if (older.length < _limit) {
          _hasMore = false;
        }
      });

      await ChatCacheService.instance
          .saveMessages(
        _conversationId!,
        _messages
            .map((e) => e.toJson())
            .toList(),
      );

      WidgetsBinding.instance
          .addPostFrameCallback((_) {
        if (!_scrollController
            .hasClients) {
          return;
        }

        final newMaxExtent =
            _scrollController
                .position
                .maxScrollExtent;

        final difference =
            newMaxExtent -
                oldMaxExtent;

        if (difference > 0) {
          _scrollController.jumpTo(
            difference,
          );
        }
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

  // ===========================================================
  // SEND TEXT
  // ===========================================================

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

    if (mounted) {
      setState(() {
        _sending = true;
      });
    }

    try {
      final wasTemporary =
          _conversationId == null;

      final sentMessage =
          await ChatService.instance
              .sendMessage(
        conversationId:
            _conversationId,
        receiverId:
            widget.receiverId,
        message: trimmed,
        reply: _replyMessage,
      );

      // -------------------------------------------------------
      // TEMPORARY CONVERSATION
      // -------------------------------------------------------

      if (wasTemporary) {
        _conversationId =
            sentMessage.conversationId;

        if (mounted) {
          setState(() {
            final exists =
                _messages.any(
              (message) =>
                  message.id ==
                  sentMessage.id,
            );

            if (!exists) {
              _messages.add(
                sentMessage,
              );
            }

            _replyMessage = null;
          });
        }

        if (_conversationId !=
            null) {
          await ChatCacheService.instance
              .saveMessages(
            _conversationId!,
            _messages
                .map(
                  (e) => e.toJson(),
                )
                .toList(),
          );
        }

        await _loadConversationStatus();
      }

      // -------------------------------------------------------
      // EXISTING CONVERSATION
      // -------------------------------------------------------

      else {
        if (mounted) {
          setState(() {
            final exists =
                _messages.any(
              (message) =>
                  message.id ==
                  sentMessage.id,
            );

            if (!exists) {
              _messages.add(
                sentMessage,
              );
            }

            _replyMessage = null;
          });
        }

        if (_conversationId !=
            null) {
          await ChatCacheService.instance
              .saveMessages(
            _conversationId!,
            _messages
                .map(
                  (e) => e.toJson(),
                )
                .toList(),
          );
        }
      }

      if (mounted) {
        setState(() {
          _replyMessage = null;
        });
      }

      WidgetsBinding.instance
          .addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } catch (e) {
      debugPrint(
        "SEND TEXT ERROR: $e",
      );

      if (!mounted) {
        return;
      }

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

  // ===========================================================
  // SEND IMAGE
  // ===========================================================

  Future<void> _sendImage(
    File image,
  ) async {
    if (_status?.status !=
        "friends") {
      await _showPendingDialog();
      return;
    }

    if (_sending) {
      return;
    }

    if (mounted) {
      setState(() {
        _sending = true;
      });
    }

    try {
      final message =
          await ChatService.instance
              .sendMessage(
        conversationId:
            _conversationId,
        receiverId:
            widget.receiverId,
        message: "",
        messageType: "image",
        fileUrl: image.path,
        fileName:
            image.path.split(
              Platform.pathSeparator,
            ).last,
        fileSize:
            await image.length(),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        final exists =
            _messages.any(
          (m) => m.id == message.id,
        );

        if (!exists) {
          _messages.add(message);
        }

        _replyMessage = null;
      });

      if (_conversationId !=
          null) {
        await ChatCacheService.instance
            .saveMessages(
          _conversationId!,
          _messages
              .map(
                (e) => e.toJson(),
              )
              .toList(),
        );
      }

      WidgetsBinding.instance
          .addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } catch (e) {
      debugPrint(
        "SEND IMAGE ERROR: $e",
      );

      if (!mounted) {
        return;
      }

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

  // ===========================================================
  // SEND FILE
  // ===========================================================

  Future<void> _sendFile(
    File file,
  ) async {
    if (_status?.status !=
        "friends") {
      await _showPendingDialog();
      return;
    }

    if (_sending) {
      return;
    }

    if (mounted) {
      setState(() {
        _sending = true;
      });
    }

    try {
      final message =
          await ChatService.instance
              .sendMessage(
        conversationId:
            _conversationId,
        receiverId:
            widget.receiverId,
        message: "",
        messageType: "file",
        fileUrl: file.path,
        fileName:
            file.path.split(
              Platform.pathSeparator,
            ).last,
        fileSize:
            await file.length(),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        final exists =
            _messages.any(
          (m) => m.id == message.id,
        );

        if (!exists) {
          _messages.add(message);
        }

        _replyMessage = null;
      });

      if (_conversationId !=
          null) {
        await ChatCacheService.instance
            .saveMessages(
          _conversationId!,
          _messages
              .map(
                (e) => e.toJson(),
              )
              .toList(),
        );
      }

      WidgetsBinding.instance
          .addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } catch (e) {
      debugPrint(
        "SEND FILE ERROR: $e",
      );

      if (!mounted) {
        return;
      }

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

  // ===========================================================
  // PENDING DIALOG
  // ===========================================================

  Future<void> _showPendingDialog() async {
    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Pending Request",
          ),
          content: const Text(
            "You cannot send another message until this request is accepted.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).pop();
              },
              child: const Text(
                "OK",
              ),
            ),
          ],
        );
      },
    );
  }

  // ===========================================================
  // REPLY
  // ===========================================================

  void _replyToMessage(
    MessageModel message,
  ) {
    if (!mounted) {
      return;
    }

    setState(() {
      _replyMessage =
          ReplyMessageModel(
        messageId:
            message.id,
        sender:
            message.senderId.toString(),
        message:
            message.message ?? "",
      );
    });
  }

  // ===========================================================
  // DELETE MESSAGE
  // ===========================================================

  Future<void> _deleteMessage(
    int messageId,
  ) async {
    try {
      await ChatService.instance
          .deleteMessage(
        messageId:
            messageId.toString(),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _messages.removeWhere(
          (message) =>
              message.id ==
              messageId,
        );
      });

      if (_conversationId !=
          null) {
        await ChatCacheService.instance
            .saveMessages(
          _conversationId!,
          _messages
              .map(
                (e) => e.toJson(),
              )
              .toList(),
        );
      }
    } catch (e) {
      debugPrint(
        "DELETE MESSAGE ERROR: $e",
      );

      if (!mounted) {
        return;
      }

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

  // ===========================================================
  // ACCEPT REQUEST
  // ===========================================================

  Future<void> _acceptRequest() async {
    if (_status?.requestId ==
        null) {
      return;
    }

    try {
      await ChatService.instance
          .acceptRequest(
        _status!.requestId!,
      );

      await _loadConversationStatus();

      if (_conversationId !=
          null) {
        await _loadMessages(
          scrollToBottom: true,
        );
      }
    } catch (e) {
      debugPrint(
        "ACCEPT REQUEST ERROR: $e",
      );

      if (!mounted) {
        return;
      }

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

  // ===========================================================
  // DECLINE REQUEST
  // ===========================================================

  Future<void> _declineRequest() async {
    if (_status?.requestId ==
        null) {
      return;
    }

    try {
      await ChatService.instance
          .declineRequest(
        _status!.requestId!,
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop();
    } catch (e) {
      debugPrint(
        "DECLINE REQUEST ERROR: $e",
      );

      if (!mounted) {
        return;
      }

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

  // ===========================================================
  // APP BAR
  // ===========================================================

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      centerTitle: false,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      titleSpacing: 0,
      title: Row(
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
                            ? widget.chatName[
                                0]
                                .toUpperCase()
                            : "?",
                      )
                    : null,
          ),

          const SizedBox(
            width: 12,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
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
                  style: TextStyle(
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
          icon: const Icon(
            Icons.call,
          ),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(
            Icons.videocam,
          ),
          onPressed: () {},
        ),
        PopupMenuButton<String>(
          onSelected: (
            value,
          ) {},
          itemBuilder: (_) =>
              const [
            PopupMenuItem(
              value: "search",
              child: Text(
                "Search",
              ),
            ),
            PopupMenuItem(
              value: "media",
              child: Text(
                "Media",
              ),
            ),
            PopupMenuItem(
              value: "mute",
              child: Text(
                "Mute",
              ),
            ),
            PopupMenuItem(
              value: "clear",
              child: Text(
                "Clear Chat",
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ===========================================================
  // RELATIONSHIP BANNER
  // ===========================================================

  Widget _buildRelationshipBanner() {
    if (_status == null) {
      return const SizedBox.shrink();
    }

    switch (_status!.status) {
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

  // ===========================================================
  // MESSAGE LIST
  // ===========================================================

  Widget _buildMessagesList() {
    if (_loading) {
      return const Center(
        child:
            CircularProgressIndicator(),
      );
    }

    if (_messages.isEmpty) {
      return Center(
        child: Text(
          _status?.status == "none"
              ? "Start a conversation with ${widget.chatName}"
              : "No messages yet",
          textAlign:
              TextAlign.center,
        ),
      );
    }

    final messageCount =
        _messages.length;

    final showTyping =
        _typing;

    final showLoadingOlder =
        _loadingOlder;

    final totalItemCount =
        messageCount +
            (showTyping ? 1 : 0) +
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
          totalItemCount,
      itemBuilder:
          (context, index) {
        // -----------------------------------------------------
        // LOADING OLDER
        // -----------------------------------------------------

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

        // -----------------------------------------------------
        // TYPING
        // -----------------------------------------------------

        if (showTyping &&
            messageIndex ==
                messageCount) {
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

        // -----------------------------------------------------
        // SAFETY
        // -----------------------------------------------------

        if (messageIndex < 0 ||
            messageIndex >=
                messageCount) {
          return const SizedBox
              .shrink();
        }

        final message =
            _messages[
                messageIndex];

        return _buildMessageBubble(
          message,
        );
      },
    );
  }

  // ===========================================================
  // MESSAGE BUBBLE
  // ===========================================================

  Widget _buildMessageBubble(
    MessageModel message,
  ) {
    final isMe =
        message.senderId ==
            widget.currentUserId;

    // ---------------------------------------------------------
    // IMAGE
    // ---------------------------------------------------------

    if (message.messageType ==
        "image") {
      return ImageMessageBubble(
        isMe: isMe,
        imageUrl:
            message.message ?? "",
        createdAt:
            message.createdAt,
      );
    }

    // ---------------------------------------------------------
    // MY MESSAGE
    // ---------------------------------------------------------

    if (isMe) {
      return SenderMessageBubble(
        message:
            message.message ?? "",
        createdAt:
            message.createdAt,
        delivered:
            message.delivered,
        seen:
            message.seen,
        onReply: () {
          _replyToMessage(
            message,
          );
        },
        onDelete: () {
          _deleteMessage(
            message.id,
          );
        },
        onEdit: () {},
      );
    }

    // ---------------------------------------------------------
    // RECEIVED MESSAGE
    // ---------------------------------------------------------

    return ReceiverMessageBubble(
      message:
          message.message ?? "",
      createdAt:
          message.createdAt,
      onReply: () {
        _replyToMessage(
          message,
        );
      },
    );
  }

  // ===========================================================
  // BOTTOM SECTION
  // ===========================================================

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
              setState(() {
                _replyMessage =
                    null;
              });
            },
          ),

        if (_status?.canReply ==
            true)
          MessageInputBar(
            visible: true,
            reply:
                _replyMessage,
            onCancelReply: () {
              setState(() {
                _replyMessage =
                    null;
              });
            },
            onSendText:
                _sendText,
            onSendImage:
                (image, caption) async {
              final file =
                  await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ImagePreviewScreen(
                    imageFile:
                        image,
                  ),
                ),
              );

              if (file != null) {
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

  // ===========================================================
  // BUILD
  // ===========================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar:
          _buildAppBar(),
      body: SafeArea(
        child: Column(
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