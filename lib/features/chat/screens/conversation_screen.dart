import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';

import '../models/message_model.dart';
import '../models/reply_message_model.dart';
import '../services/chat_service.dart';
import '/core/services/socket_service.dart';
import '../services/chat_cache_service.dart';

import '../widgets/message_input_bar.dart';
import '../widgets/reply_preview.dart';
import '../widgets/typing_indicator.dart';
import '../widgets/sender_message_bubble.dart';
import '../widgets/receiver_message_bubble.dart';
import '../widgets/image_message_bubble.dart';

import 'image_preview_screen.dart';
import '../widgets/request_banner.dart';
import '../models/conversation_status_model.dart';

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
  State<ConversationScreen> createState() => _ConversationScreenState();
}
class _ConversationScreenState
    extends State<ConversationScreen> {
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
    final ScrollController _scrollController = ScrollController();
    


    @override
    void initState() {
      super.initState();
       _conversationId = widget.conversationId;
      _listenForPresence();
      _listenForTyping();
      _listenForSeen();
      _listenForMessages();
      _initializeConversation();
      _listenForRequestUpdates();
      _scrollController.addListener(_onScroll);
      _isOnline = widget.isOnline;
    }

    @override
    void dispose() {
      SocketService.instance.socket?.off("new_message");
      SocketService.instance.socket?.off("typing");
      SocketService.instance.socket?.off("stop_typing");
      SocketService.instance.socket?.off("message_seen");
      SocketService.instance.socket?.off(
          "friend_request_accepted",
        );
        SocketService.instance.socket?.off(
          "friend_request_declined",
        );
      _scrollController.removeListener(_onScroll);
      _scrollController.dispose();

      super.dispose();
    }
    void configureStatus(
      ConversationStatusModel status,
    ) {
      setState(() {
        _status = status;
      });
    }
    void _onScroll() {
  if (_scrollController.position.pixels <= 80 &&
      !_loadingOlder &&
      _hasMore) {
    _loadOlderMessages();
  }
}
Future<void> _initializeConversation() async {
  try {
    await _loadConversationStatus();

    if (_conversationId != null) {
      await _loadMessages();

      await ChatService.instance.markConversationAsRead(
        conversationId: _conversationId!,
      );
    } else {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });
    }
  } catch (e) {
    debugPrint(
      "INITIALIZE CONVERSATION ERROR: $e",
    );

    if (!mounted) return;

    setState(() {
      _loading = false;
    });
  }
}
Future<void> _loadConversationStatus() async {
  try {
    final status =
        await ChatService.instance.getConversationStatus(
      widget.receiverId,
    );

    debugPrint(
      "========== CONVERSATION STATUS ==========",
    );
    debugPrint("status: ${status.status}");
    debugPrint("canReply: ${status.canReply}");
    debugPrint("pending: ${status.pending}");
    debugPrint("isRequester: ${status.isRequester}");
    debugPrint("pendingMessage: ${status.pendingMessage}");
    debugPrint("conversationId: ${status.conversationId}");
    debugPrint("requestId: ${status.requestId}");
    debugPrint(
      "=========================================",
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
      "CONVERSATION STATUS ERROR: $e",
    );
  }
}
Future<void> _listenForSeen() async {
  SocketService.instance.listenMessageSeen((data) {

    final messageId = data["messageId"];

    final index = _messages.indexWhere(
      (m) => m.id == messageId,
    );

    if (index == -1) return;

    if (!mounted) return;

    setState(() {
      _messages[index] =
          _messages[index].copyWith(
        seen: true,
      );
    });
  });

}

void _listenForMessages() {
  SocketService.instance.listenMessage((data) async {
    try {
      final message =
          MessageModel.fromJson(
        Map<String, dynamic>.from(data),
      );

      if (_conversationId == null) return;

      if (message.conversationId !=
          _conversationId) {
        return;
      }

      final exists = _messages.any(
        (m) => m.id == message.id,
      );

      if (exists) return;

      if (!mounted) return;

      setState(() {
        _messages.add(message);
      });

      await ChatCacheService.instance.saveMessages(
        _conversationId!,
        _messages
            .map((e) => e.toJson())
            .toList(),
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollToBottom();
        }
      });
    } catch (e) {
      debugPrint(
        "NEW MESSAGE ERROR: $e",
      );
    }
  });
}
void _listenForPresence() {
  SocketService.instance.socket?.on('presence', (data) {
    final userId = data["userId"];

    // Update presence state for this conversation's receiver
    if (userId != widget.receiverId) return;

    if (!mounted) return;

    setState(() {
      _isOnline = data["online"] ?? false;
    });
  });
}
  Future<void> _loadMessages() async {
  if (_conversationId == null) return;

  final conversationId =
      _conversationId!;

  // Load cached messages first
  final cached = ChatCacheService.instance
    .loadMessages(conversationId);

  if (cached.isNotEmpty && mounted) {
    setState(() {
      _messages
        ..clear()
        ..addAll(
          cached
              .map((e) => MessageModel.fromJson(e))
              .toList(),
        );

      _loading = false;
    });
  }

  try {
    // ==========================
    // Fetch latest from server
    // ==========================
    final messages =
        await ChatService.instance.getMessages(
      _conversationId!,
    );
    await ChatCacheService.instance.saveMessages(
      conversationId,
      messages.map((e) => e.toJson()).toList(),
    );
    if (!mounted) return;

    _messages
      ..clear()
      ..addAll(messages);
    setState(() {
      _loading = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  } catch (e) {
    if (!mounted) return;

    setState(() {
      _loading = false;
    });

    debugPrint(e.toString());
  }
}
Future<void> _loadOlderMessages() async {
  if (_loadingOlder ||
      widget.conversationId == null) {
    return;
  }

  _loadingOlder = true;

  try {
    final oldHeight =
        _scrollController.position.maxScrollExtent;

    _page++;

    final older =
        await ChatService.instance.getMessages(
      _conversationId!,
      page: _page,
      limit: _limit,
    );

    if (!mounted) return;

    if (older.isEmpty) {
      _hasMore = false;
      return;
    }

    setState(() {
      _messages.insertAll(0, older);

      if (older.length < _limit) {
        _hasMore = false;
      }
    });

    await ChatCacheService.instance.saveMessages(
      _conversationId!,
      _messages.map((e) => e.toJson()).toList(),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      final newHeight =
          _scrollController.position.maxScrollExtent;

      _scrollController.jumpTo(
        newHeight - oldHeight,
      );
    });
  } catch (e) {
    debugPrint(
      "Error loading older messages: $e",
    );
  } finally {
    _loadingOlder = false;
  }
}

void _listenForTyping() {

  SocketService.instance.listenTyping((_) {

    if (!mounted) return;

    setState(() {
      _typing = true;
    });

  });

  SocketService.instance.listenStopTyping((_) {

    if (!mounted) return;

    setState(() {
      _typing = false;
    });

  });

}
  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;

    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }
//=============================================
//SEND TEXT
//============================================
Future<void> _sendText(String text) async {
  if (_status?.canReply != true) return;

  if (_sending) return;

  setState(() {
    _sending = true;
  });

  try {
    final wasTemporary = _conversationId == null;

    final sentMessage =
        await ChatService.instance.sendMessage(
      conversationId: _conversationId,
      receiverId: widget.receiverId,
      message: text,
      reply: _replyMessage,
    );
    // ==========================================
    // TEMPORARY CONVERSATION BECAME REAL
    // ==========================================

    if (wasTemporary) {
      _conversationId =
          sentMessage.conversationId;

       if (mounted) {
      setState(() {
        final exists = _messages.any(
          (m) => m.id == sentMessage.id,
        );

        if (!exists) {
          _messages.add(sentMessage);
        }

        _replyMessage = null;
      });
    }

      await ChatCacheService.instance.saveMessages(
        _conversationId!,
        _messages.map((e) => e.toJson()).toList(),
      );
      await _loadMessages();
      await _loadConversationStatus();

    } else {
      if (mounted) {
        setState(() {
          _messages.add(sentMessage);
        });
      }
    }
    
    if (mounted) {
      setState(() {
        _replyMessage = null;
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.toString()),
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
  Future<void> _sendImage(File image) async {
    if (_status?.status != "friends") {
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Pending Request'),
          content: Text(
                'You cannot send another message until this request is accepted.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );

      return;
    }
    if (_sending) return;

    setState(() => _sending = true);

    try {
      final message = await ChatService.instance.sendMessage(
        conversationId:
          widget.conversationId,
        receiverId: widget.receiverId,
        message: "",
        messageType: "image",
        fileUrl: image.path,
        fileName: image.path.split(Platform.pathSeparator).last,
        fileSize: await image.length(),
      );
      _messages.add(message);

      if (widget.conversationId != null) {
        await ChatCacheService.instance.saveMessages(
  _conversationId!,
  _messages.map((e) => e.toJson()).toList(),
);
      }

      setState(() {
        _replyMessage = null;
      });

      _scrollToBottom();
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }

  Future<void> _sendFile(File file) async {
    if (_status?.status != "friends") {
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Pending Request'),
          content: Text(
                'You cannot send another message until this request is accepted.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );

      return;
    }
    if (_sending) return;

    setState(() => _sending = true);

    try {
      final message = await ChatService.instance.sendMessage(
        conversationId:
            widget.conversationId,
        receiverId: widget.receiverId,
        message: "",
        messageType: "file",
        fileUrl: file.path,
        fileName: file.path.split(Platform.pathSeparator).last,
        fileSize: await file.length(),
      );

      _messages.add(message);

      if (widget.conversationId != null) {
        await ChatCacheService.instance.saveMessages(
  _conversationId!,
  _messages.map((e) => e.toJson()).toList(),
);
      }

      setState(() {
        _replyMessage = null;
      });

      _scrollToBottom();
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }
  void _listenForRequestUpdates() {
  final socket = SocketService.instance.socket;

  socket?.on(
    "friend_request_accepted",
    (data) async {
      final conversationId =
          int.tryParse(
        data["conversationId"].toString(),
      );

      if (conversationId == null ||
          conversationId != _conversationId) {
        return;
      }

      await _loadConversationStatus();

      if (_conversationId != null) {
        await _loadMessages();
      }
    },
  );

  socket?.on(
    "friend_request_declined",
    (data) async {
      final conversationId =
          int.tryParse(
        data["conversationId"].toString(),
      );

      if (conversationId == null ||
          conversationId != _conversationId) {
        return;
      }

      if (!mounted) return;

      Navigator.of(context).pop();
    },
  );
}
  void _replyToMessage(MessageModel message) {
    setState(() {
      _replyMessage = ReplyMessageModel(
        messageId: message.id,
        sender: message.senderId.toString(),
        message: message.message ?? '',
      );
    });
  }

  // Removed unused _reactToMessage method

  Future<void> _deleteMessage(
    int messageId,
  ) async {
    await ChatService.instance.deleteMessage(
      messageId: messageId.toString(),
    );

    await _loadMessages();
    _messages.removeWhere((m) => m.id == messageId);

    if (widget.conversationId != null) {
      await ChatCacheService.instance.saveMessages(
  _conversationId!,
  _messages.map((e) => e.toJson()).toList(),
);
    }

    setState(() {});
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      centerTitle: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: widget.profileImage != null
                ? NetworkImage(widget.profileImage!)
                : null,
            child: widget.profileImage == null
                ? Text(
                    widget.chatName.isNotEmpty
                        ? widget.chatName[0].toUpperCase()
                        : "?",
                  )
                : null,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  widget.chatName,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  _typing
                      ? "typing..."
                      : (_isOnline
                          ? "Online"
                          : "Offline"),
                  style: TextStyle(
                    fontSize: 12,
                    color: _typing ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.call),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.videocam),
          onPressed: () {},
        ),
        PopupMenuButton<String>(
          onSelected: (value) {},
          itemBuilder: (_) => const [
            PopupMenuItem(
              value: "search",
              child: Text("Search"),
            ),
            PopupMenuItem(
              value: "media",
              child: Text("Media"),
            ),
            PopupMenuItem(
              value: "mute",
              child: Text("Mute"),
            ),
            PopupMenuItem(
              value: "clear",
              child: Text("Clear Chat"),
            ),
          ],
        ),
      ],
    );
  }
  
Widget buildPendingRequestWidget() {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.grey.shade100,
      border: const Border(
        top: BorderSide(
          color: Colors.grey,
        ),
      ),
    ),
    child: Row(
      children: [
        const Icon(
          Icons.lock_outline,
          color: Colors.grey,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            _status?.pendingMessage ??
                "You can't send more messages until this request is accepted.",
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
  );
}
Widget buildRelationshipBanner() {

  if (_status == null) {
    return const SizedBox.shrink();
  }

  switch (_status!.status) {

    case "pending_received":
  return RequestBanner(
    title: "${widget.chatName} wants to be your friend",
    subtitle: "Accept this request to continue chatting.",
    primaryText: "Accept",
    secondaryText: "Decline",

    onPrimary: () async {
  if (_status?.requestId == null) return;

  try {
    await ChatService.instance.acceptRequest(_status!.requestId!);

    await _loadConversationStatus();

    if (_conversationId != null) {
      await _loadMessages();
    }

    if (mounted) {
      setState(() {});
    }
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          e.toString(),
        ),
      ),
    );
  }
},

    onSecondary: () async {
  if (_status?.requestId == null) return;

  try {
    await ChatService.instance.declineRequest(
      _status!.requestId!,
    );

    if (!mounted) return;

    Navigator.of(context).pop();
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          e.toString(),
        ),
      ),
    );
  }
},
  );

    case "pending_sent":

      return RequestBanner(
        title: "Request sent",
        subtitle:
            "Waiting for ${widget.chatName} to accept.",
      );

    case "declined":

      return RequestBanner(
        title: "Request declined",
        subtitle:
            "You can send another request later.",
      );

    default:

      return const SizedBox.shrink();

  }

}
    Widget _buildMessagesList() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
if (_messages.isEmpty) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _status?.status == "none"
              ? "Start a conversation with ${widget.chatName}"
              : "No messages yet",
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      itemCount:
          _messages.length +
          (_typing ? 1 : 0) +
          (_loadingOlder ? 1 : 0),
      itemBuilder: (context, index) {
        if (_loadingOlder && index == 0) {
  return const Padding(
    padding: EdgeInsets.symmetric(vertical: 10),
    child: Center(
      child: SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      ),
    ),
  );
}
final messageIndex =
    _loadingOlder ? index - 1 : index;
        if (_typing &&
    messageIndex == _messages.length) {
          return Padding(
            padding: const EdgeInsets.only(
              left: 12,
              top: 8,
              bottom: 8,
            ),
            child: TypingIndicator(
              visible: _typing,
            ),
          );
        }

        final message = _messages[messageIndex];
        return _buildMessageBubble(message);
      },
    );
  }
    Widget _buildMessageBubble(MessageModel message) {
    final isMe =
        message.senderId == widget.currentUserId;

    if (message.messageType == "image") {
      return ImageMessageBubble(
        isMe: isMe,
        imageUrl: message.message ?? '',
        createdAt: message.createdAt,
      );
    }

    if (isMe) {
      return SenderMessageBubble(
        message: message.message ?? '',
        createdAt: message.createdAt,
        delivered: message.delivered,
        seen: message.seen,
        onReply: () => _replyToMessage(message),
        onDelete: () => _deleteMessage(message.id),
        onEdit: () {},
      );
    }

    return ReceiverMessageBubble(
      message: message.message ?? '',
      createdAt: message.createdAt,
      onReply: () => _replyToMessage(message),
    );
  }
    Widget _buildBottomSection() {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (_replyMessage != null)
        ReplyPreview(
          reply: _replyMessage!,
          onCancel: () {
            setState(() {
              _replyMessage = null;
            });
          },
        ),

      if (_status?.canReply == true)
        MessageInputBar(
          visible: true,
          reply: _replyMessage,
          onCancelReply: () {
            setState(() {
              _replyMessage = null;
            });
          },
          onSendText: _sendText,
          onSendImage: (image, caption) async {
            final file = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ImagePreviewScreen(
                  imageFile: image,
                ),
              ),
            );

            if (file != null) {
              await _sendImage(file);
            }
          },
          onSendFile: _sendFile,
          onSendVoice: (audio) async {},
        )
      else
        const SizedBox(height: 10),
    ],
  );
}
      @override
      Widget build(BuildContext context) {
        return Scaffold(
          appBar: _buildAppBar(),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: _buildMessagesList(),
                ),
                // Pending request / relationship banner
                if (_status?.status == "pending_received" ||
                    _status?.status == "pending_sent" ||
                    _status?.status == "declined")
                  buildRelationshipBanner(),
                _buildBottomSection(),
              ],
            ),
          ),
        );
      }
    }