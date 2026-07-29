import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '/core/services/socket_service.dart';
import '/core/services/storage_service.dart';

import '../models/forward_chat_model.dart';
import '../models/local_file_message.dart';
import '../models/local_image_message.dart';
import '../models/message_model.dart';
import '../models/reaction_model.dart';
import '../models/reply_message_model.dart';

import '../services/conversation_service.dart';
import '../services/send_message_service.dart';

import '../widgets/conversation_app_bar.dart';
import '../widgets/conversation_shimmer.dart';
import '../widgets/empty_conversation.dart';
import '../widgets/image_message_bubble.dart';
import '../widgets/message_input_bar.dart';
import '../widgets/reaction_picker.dart';
import '../widgets/reaction_users_sheet.dart';
import '../widgets/receiver_message_bubble.dart';
import '../widgets/sender_message_bubble.dart';
import '../widgets/typing_indicator.dart';

import 'forward_message_screen.dart';

class ConversationScreen extends StatefulWidget {
  final int conversationId;
  final int recipientId;
  final String recipientName;
  final String? profilePicture;
  final bool isOnline;

  const ConversationScreen({
    super.key,
    required this.conversationId,
    required this.recipientId,
    required this.recipientName,
    this.profilePicture,
    required this.isOnline,
  });

  @override
  State<ConversationScreen> createState() =>
      _ConversationScreenState();
}

class _ConversationScreenState
    extends State<ConversationScreen>
    with WidgetsBindingObserver {
  //==========================================================
  // Controllers
  //==========================================================

  final ScrollController _scrollController =
      ScrollController();

  //==========================================================
  // Services
  //==========================================================

  final SocketService socket =
      SocketService.instance;

  //==========================================================
  // State
  //==========================================================

  bool _isLoading = true;
  bool _isTyping = false;

  late bool _recipientOnline;
  String? _recipientLastSeen;

  static const String _currentUserId = "1";

  ReplyMessageModel? _replyingTo;

  Timer? _typingTimer;

  //==========================================================
  // Messages
  //==========================================================

  final List<MessageModel> _messages = [];

  final List<LocalImageMessage>
      _imageMessages = [];

  final List<LocalFileMessage>
      _fileMessages = [];

  //==========================================================
  // Forward Screen Demo Data
  //==========================================================

  final List<ForwardChatModel> _forwardChats = const [
    ForwardChatModel(
      id: 2,
      name: "David Johnson",
    ),
    ForwardChatModel(
      id: 3,
      name: "Mary Williams",
    ),
    ForwardChatModel(
      id: 4,
      name: "Campus Group",
    ),
  ];
    //==========================================================
  // Lifecycle
  //==========================================================

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _recipientOnline = widget.isOnline;

    loadMessages();

    _connectSocket();
  }

  @override
  void dispose() {
    socket.leaveConversation(
      widget.conversationId.toString(),
    );

    socket.disconnect();

    _typingTimer?.cancel();

    _scrollController.dispose();

    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(
    AppLifecycleState state,
  ) {
    if (state == AppLifecycleState.resumed) {
      socket.updatePresence(true);
    }

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      socket.updatePresence(false);
    }
  }

  //==========================================================
  // Socket Connection
  //==========================================================

  Future<void> _connectSocket() async {
    final token = await StorageService.getToken();

    if (token == null) return;

    socket.connect(token);

    socket.joinConversation(
      widget.conversationId.toString(),
    );

    //==============================
    // Incoming Messages
    //==============================

    socket.listenMessage((data) {
      if (!mounted) return;

      final incoming =
          MessageModel.fromJson(data);

      final pendingIndex =
          _messages.indexWhere(
        (m) =>
            m.status ==
                MessageStatus.sending &&
            m.senderId ==
                incoming.senderId &&
            m.text == incoming.text,
      );

      setState(() {
        if (pendingIndex != -1) {
          _messages[pendingIndex] =
              incoming;
        } else {
          _messages.insert(
            0,
            incoming,
          );
        }
      });

      _scrollToBottom();
    });

    //==============================
    // Delivered
    //==============================

    socket.listenDelivered((data) {
      if (!mounted) return;

      final id = data["messageId"];

      final index =
          _messages.indexWhere(
        (m) => m.id == id,
      );

      if (index == -1) return;

      setState(() {
        _messages[index] =
            _messages[index].copyWith(
          status:
              MessageStatus.delivered,
        );
      });
    });

    //==============================
    // Seen
    //==============================

    socket.listenSeen((data) {
      if (!mounted) return;

      final id = data["messageId"];

      final index =
          _messages.indexWhere(
        (m) => m.id == id,
      );

      if (index == -1) return;

      setState(() {
        _messages[index] =
            _messages[index].copyWith(
          status: MessageStatus.seen,
        );
      });
    });

    //==============================
    // Typing
    //==============================

    socket.listenTyping((_) {
      if (!mounted) return;

      setState(() {
        _isTyping = true;
      });
    });

    socket.listenStopTyping((_) {
      if (!mounted) return;

      setState(() {
        _isTyping = false;
      });
    });

    //==============================
    // Presence
    //==============================

    socket.listenPresence((data) {
      if (!mounted) return;

      if (data["userId"].toString() !=
          widget.recipientId.toString()) {
        return;
      }

      setState(() {
        _recipientOnline =
            data["online"] ?? false;

        _recipientLastSeen =
            data["lastSeen"];
      });
    });

    //==============================
    // Reactions
    //==============================

    socket.listenReaction((data) {
      if (!mounted) return;

      final messageId =
          data["messageId"];

      final userId =
          data["userId"];

      final emoji =
          data["emoji"];

      final removed =
          data["removed"] ?? false;

      final index =
          _messages.indexWhere(
        (m) => m.id == messageId,
      );

      if (index == -1) return;

      final reactions =
          List<ReactionModel>.from(
        _messages[index].reactions,
      );

      reactions.removeWhere(
        (r) => r.userId == userId,
      );

      if (!removed) {
        reactions.add(
          ReactionModel(
            userId: userId,
            emoji: emoji,
          ),
        );
      }

      setState(() {
        _messages[index] =
            _messages[index].copyWith(
          reactions: reactions,
        );
      });
    });

    //==============================
    // Room Joined
    //==============================

    socket.listenRoomJoined((_) {});
  }
    //==========================================================
  // Load Messages
  //==========================================================

  Future<void> loadMessages() async {
    try {
      final result =
          await ConversationService.getMessages(
        widget.conversationId,
      );

      if (!mounted) return;

      setState(() {
        _messages = result;
        _isLoading = false;
      });

      _markMessagesSeen();

      WidgetsBinding.instance
          .addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  //==========================================================
  // Send Message
  //==========================================================

  Future<void> _sendMessage(
    String text,
    ReplyMessageModel? reply,
  ) async {
    final pending = MessageModel(
      id: DateTime.now()
          .millisecondsSinceEpoch
          .toString(),
      conversationId:
          widget.conversationId.toString(),
      senderId: currentUserId.toString(),
      senderName: "You",
      text: text,
      messageType: MessageType.text,
      timestamp: DateTime.now(),
      status: MessageStatus.sending,
      replyTo: reply?.message,
    );

    setState(() {
      _messages.insert(0, pending);
      _replyingTo = null;
    });

    _scrollToBottom();

    socket.sendMessage(
      conversationId:
          widget.conversationId.toString(),
      senderId: currentUserId.toString(),
      receiverId:
          widget.recipientId.toString(),
      text: text,
    );
  }

  //==========================================================
  // Reply
  //==========================================================

  void _startReply(
    MessageModel message,
  ) {
    setState(() {
      _replyingTo = ReplyMessageModel(
        messageId: message.id,
        sender: message.senderId ==
                currentUserId.toString()
            ? "You"
            : widget.recipientName,
        message: message.text,
      );
    });
  }

  void _cancelReply() {
    setState(() {
      _replyingTo = null;
    });
  }

  //==========================================================
  // Typing
  //==========================================================

  void _onTyping() {
    socket.sendTyping(
      widget.conversationId.toString(),
      currentUserId.toString(),
    );

    _typingTimer?.cancel();

    _typingTimer = Timer(
      const Duration(
        milliseconds: 1200,
      ),
      _stopTyping,
    );
  }

  void _stopTyping() {
    socket.sendStopTyping(
      widget.conversationId.toString(),
      currentUserId.toString(),
    );
  }

  //==========================================================
  // Seen
  //==========================================================

  void _markMessagesSeen() {
    for (final message in _messages) {
      if (message.senderId !=
              currentUserId.toString() &&
          message.status !=
              MessageStatus.seen) {
        socket.sendSeen(
          message.id,
        );
      }
    }
  }

  //==========================================================
  // Scroll
  //==========================================================

  void _scrollToBottom() {
    if (!_scrollController
        .hasClients) {
      return;
    }

    _scrollController.animateTo(
      0,
      duration: const Duration(
        milliseconds: 250,
      ),
      curve: Curves.easeOut,
    );
  }
    //==========================================================
  // Reactions
  //==========================================================

  void _showReactionPicker(
    MessageModel message,
  ) {
    showDialog(
      context: context,
      barrierColor: Colors.black26,
      builder: (_) {
        return TweenAnimationBuilder<double>(
          tween: Tween(
            begin: .7,
            end: 1,
          ),
          duration: const Duration(
            milliseconds: 200,
          ),
          curve: Curves.easeOutBack,
          builder: (
            context,
            value,
            child,
          ) {
            return Transform.scale(
              scale: value,
              child: child,
            );
          },
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Center(
              child: ReactionPicker(
                onSelected: (emoji) {
                  HapticFeedback.lightImpact();

                  Navigator.pop(context);

                  _reactToMessage(
                    message,
                    emoji,
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void _reactToMessage(
    MessageModel message,
    String emoji,
  ) {
    final index = _messages.indexWhere(
      (m) => m.id == message.id,
    );

    if (index == -1) return;

    final reactions =
        List<ReactionModel>.from(
      _messages[index].reactions,
    );

    final existing =
        reactions.indexWhere(
      (r) =>
          r.userId ==
          currentUserId.toString(),
    );

    if (existing != -1) {
      if (reactions[existing].emoji ==
          emoji) {
        reactions.removeAt(existing);
      } else {
        reactions[existing] =
            ReactionModel(
          userId:
              currentUserId.toString(),
          emoji: emoji,
        );
      }
    } else {
      reactions.add(
        ReactionModel(
          userId:
              currentUserId.toString(),
          emoji: emoji,
        ),
      );
    }

    setState(() {
      _messages[index] =
          _messages[index].copyWith(
        reactions: reactions,
      );
    });

    socket.sendReaction(
      messageId: message.id,
      userId:
          currentUserId.toString(),
      emoji: emoji,
    );
  }

  void _showReactionUsers(
    MessageModel message,
    String emoji,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return ReactionUsersSheet(
          emoji: emoji,
          reactions: message.reactions,
        );
      },
    );
  }

  //==========================================================
  // Edit Message
  //==========================================================

  Future<void> _editMessage(
    int index,
  ) async {
    final controller =
        TextEditingController(
      text: _messages[index].text,
    );

    final updated =
        await showDialog<String>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title:
              const Text("Edit message"),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLines: 4,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child:
                  const Text("Cancel"),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  controller.text.trim(),
                );
              },
              child:
                  const Text("Save"),
            ),
          ],
        );
      },
    );

    if (updated == null ||
        updated.isEmpty) {
      return;
    }

    setState(() {
      _messages[index] =
          _messages[index].copyWith(
        text: updated,
        isEdited: true,
      );
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          "Message edited",
        ),
        duration:
            Duration(seconds: 1),
      ),
    );
  }

  //==========================================================
  // Delete Message
  //==========================================================

  Future<void> _deleteMessage(
    int index,
  ) async {
    final confirm =
        await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title:
              const Text("Delete"),
          content: const Text(
            "Delete this message?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                    context,
                    false);
              },
              child:
                  const Text("Cancel"),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(
                    context,
                    true);
              },
              child:
                  const Text("Delete"),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    setState(() {
      _messages.removeAt(index);
    });
  }

  //==========================================================
  // Forward
  //==========================================================

  Future<void> _forwardMessage(
    MessageModel message,
  ) async {
    final chat =
        await Navigator.push<
            ForwardChatModel>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ForwardMessageScreen(
          chats: _forwardChats,
        ),
      ),
    );

    if (chat == null) return;

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          "Message forwarded to ${chat.name}",
        ),
      ),
    );
  }
    //==========================================================
  // UI
  //==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Theme.of(context).colorScheme.surface,

      appBar: PreferredSize(
        preferredSize:
            const Size.fromHeight(70),
        child: ConversationAppBar(
          recipientName: widget.recipientName,
          profilePicture:
              widget.profilePicture,
          isOnline: _recipientOnline,
          lastSeen: _recipientOnline
              ? "Online"
              : (_recipientLastSeen ??
                  "Last seen recently"),
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [

            //--------------------------------------------------
            // Messages
            //--------------------------------------------------

            Expanded(
              child: _isLoading
                  ? const ConversationShimmer()
                  : _messages.isEmpty &&
                          _imageMessages.isEmpty &&
                          _fileMessages.isEmpty
                      ? const EmptyConversation()
                      : ListView(
                          controller:
                              _scrollController,
                          reverse: true,
                          padding:
                              const EdgeInsets.only(
                            top: 10,
                            bottom: 10,
                          ),
                          children: [

                            //------------------------------------------------
                            // Local Images
                            //------------------------------------------------

                            ..._imageMessages.map(
                              (image) =>
                                  ImageMessageBubble(
                                image:
                                    image.image,
                                isMe:
                                    image.isMe,
                                createdAt: image
                                    .createdAt,
                              ),
                            ),

                            //------------------------------------------------
                            // Messages
                            //------------------------------------------------

                            ..._messages
                                .asMap()
                                .entries
                                .map(
                              (entry) {
                                final index =
                                    entry.key;

                                final message =
                                    entry.value;

                                final isMe =
                                    message.senderId ==
                                        currentUserId
                                            .toString();

                                return GestureDetector(
                                  onLongPress: () {
                                    _showReactionPicker(
                                      message,
                                    );
                                  },
                                  child: isMe
                                                                        ? SenderMessageBubble(
                                          message:
                                              message.text,
                                          createdAt:
                                              message.timestamp,
                                          delivered:
                                              message.status ==
                                                  MessageStatus
                                                      .delivered ||
                                              message.status ==
                                                  MessageStatus
                                                      .seen,
                                          seen:
                                              message.status ==
                                                  MessageStatus
                                                      .seen,
                                          sending:
                                              message.status ==
                                                  MessageStatus
                                                      .sending,
                                          edited:
                                              message
                                                  .isEdited,
                                          replyTo:
                                              message.replyTo ==
                                                      null
                                                  ? null
                                                  : ReplyMessageModel(
                                                      messageId:
                                                          "",
                                                      sender:
                                                          "",
                                                      message:
                                                          message.replyTo!,
                                                    ),
                                          onReply: () =>
                                              _startReply(
                                                message,
                                              ),
                                          onEdit: () =>
                                              _editMessage(
                                                index,
                                              ),
                                          onDelete: () =>
                                              _deleteMessage(
                                                index,
                                              ),
                                          onForward: () =>
                                              _forwardMessage(
                                                message,
                                              ),
                                          reactions:
                                              message
                                                  .reactions
                                                  .map(
                                                    (
                                                      e,
                                                    ) =>
                                                        e.emoji,
                                                  )
                                                  .toList(),
                                        )
                                      : ReceiverMessageBubble(
                                          message:
                                              message.text,
                                          createdAt:
                                              message.timestamp,
                                          replyTo:
                                              message.replyTo ==
                                                      null
                                                  ? null
                                                  : ReplyMessageModel(
                                                      messageId:
                                                          "",
                                                      sender:
                                                          "",
                                                      message:
                                                          message.replyTo!,
                                                    ),
                                          onReply: () =>
                                              _startReply(
                                                message,
                                              ),
                                          onForward: () =>
                                              _forwardMessage(
                                                message,
                                              ),
                                          reactions:
                                              message
                                                  .reactions
                                                  .map(
                                                    (
                                                      e,
                                                    ) =>
                                                        e.emoji,
                                                  )
                                                  .toList(),
                                        ),
                                );
                              },
                            ),
                          ],
                        ),
            ),

            //--------------------------------------------------
            // Typing Indicator
            //--------------------------------------------------

            if (_isTyping)
              TypingIndicator(
                username:
                    widget.recipientName,
              ),

            //--------------------------------------------------
            // Message Input
            //--------------------------------------------------

            MessageInputBar(
              replyingTo: _replyingTo,
              onCancelReply:
                  _cancelReply,
              onSend: _sendMessage,
              onTyping: _onTyping,
              onStopTyping:
                  _stopTyping,
              onImageSelected:
                  (image) {
                setState(() {
                  _imageMessages.insert(
                    0,
                    LocalImageMessage(
                      image: image,
                      isMe: true,
                      createdAt:
                          DateTime.now(),
                    ),
                  );
                });

                WidgetsBinding.instance
                    .addPostFrameCallback(
                  (_) {
                    _scrollToBottom();
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
