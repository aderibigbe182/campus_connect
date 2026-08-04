import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import '../models/message_model.dart';
import '../models/reply_message_model.dart';
import '../services/chat_service.dart';

import '../widgets/message_input_bar.dart';
import '../widgets/reply_preview.dart';
import '../widgets/typing_indicator.dart';
import '../widgets/sender_message_bubble.dart';
import '../widgets/receiver_message_bubble.dart';
import '../widgets/image_message_bubble.dart';

import 'image_preview_screen.dart';

class ConversationScreen extends StatefulWidget {
  final String? conversationId;
  final int receiverId;

  final int currentUserId;

  final String chatName;

  final String? profileImage;

  final bool isOnline;

  const ConversationScreen({
    super.key,
    required this.conversationId,
    required this.receiverId,
    required this.currentUserId,
    required this.chatName,
    this.profileImage,
    this.isOnline = false,
  });

  @override
  State<ConversationScreen> createState() =>
      _ConversationScreenState();
}
class _ConversationScreenState
    extends State<ConversationScreen> {
  final ChatService _chatService =
      ChatService.instance;

  final ScrollController _scrollController =
      ScrollController();

  final List<MessageModel> _messages = [];

  ReplyMessageModel? _replyMessage;

  bool _loading = true;

  bool _sending = false;

  bool _typing = false;

  StreamSubscription<List<MessageModel>>?
      _messageSubscription;

  StreamSubscription<bool>? _typingSubscription;
    @override
  void initState() {
    super.initState();

    _loadMessages();

    Stream<List<MessageModel>>? messageStream;
    Stream<bool>? typingStream;

    try {
      messageStream =
          (_chatService as dynamic).messageStream
              as Stream<List<MessageModel>>?;
    } catch (_) {
      messageStream = null;
    }

    try {
      typingStream =
          (_chatService as dynamic).typingStream
              as Stream<bool>?;
    } catch (_) {
      typingStream = null;
    }

    _messageSubscription =
        (messageStream ?? Stream<List<MessageModel>>.empty())
            .listen((messages) {
      if (!mounted) return;

      setState(() {
        _messages
          ..clear()
          ..addAll(messages);
      });

      _scrollToBottom();
    });

    _typingSubscription =
        (typingStream ?? Stream<bool>.empty()).listen((typing) {
      if (!mounted) return;

      setState(() {
        _typing = typing;
      });
    });
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    _typingSubscription?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  int? _parseConversationId(String? value) {
    if (value == null || value.isEmpty) return null;
    return int.tryParse(value);
  }
  Future<void> _loadMessages() async {
    setState(() => _loading = true);

    try {
      final messages =
          await (_chatService as dynamic).getMessages(
        _parseConversationId(widget.conversationId),
      );

      if (!mounted) return;

      setState(() {
        _messages
          ..clear()
          ..addAll(messages);

        _loading = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } catch (_) {
      if (!mounted) return;

      setState(() => _loading = false);
    }
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;

    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Future<void> _sendText(String text) async {
    if (_sending) return;

    setState(() => _sending = true);

    try {
      final sent = await ChatService.instance.sendMessage(
        conversationId: _parseConversationId(widget.conversationId),
        receiverId: widget.receiverId,
        message: text,
      );

      setState(() {
        _messages.add(sent);
        _replyMessage = null;
      });

      _scrollToBottom();
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }

  Future<void> _sendImage(File image) async {
    if (_sending) return;

    setState(() => _sending = true);

    try {
      await ChatService.instance.sendMessage(
        conversationId: _parseConversationId(widget.conversationId),
        receiverId: widget.receiverId,
        message: "",
        messageType: "image",
        fileUrl: image.path,
        fileName: image.path.split(Platform.pathSeparator).last,
        fileSize: await image.length(),
      );

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
    if (_sending) return;

    setState(() => _sending = true);

    try {
      await ChatService.instance.sendMessage(
        conversationId: _parseConversationId(widget.conversationId),
        receiverId: widget.receiverId,
        message: "",
        messageType: "file",
        fileUrl: file.path,
        fileName: file.path.split(Platform.pathSeparator).last,
        fileSize: await file.length(),
      );

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

  void _replyToMessage(MessageModel message) {
    setState(() {
      _replyMessage = ReplyMessageModel(
        messageId: message.id,
        sender: message.senderId.toString(),
        message: message.message,
      );
    });
  }

  // Removed unused _reactToMessage method

  Future<void> _deleteMessage(
    int messageId,
  ) async {
    await _chatService.deleteMessage(
      messageId: messageId.toString(),
    );

    await _loadMessages();
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
                      : (widget.isOnline
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
    Widget _buildMessagesList() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_messages.isEmpty) {
      return const Center(
        child: Text(
          "No messages yet.\nStart the conversation 👋",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      itemCount: _messages.length + (_typing ? 1 : 0),
      itemBuilder: (context, index) {
        if (_typing && index == _messages.length) {
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

        final message = _messages[index];
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
        imageUrl: message.message,
        createdAt: message.createdAt,
      );
    }

    if (isMe) {
      return SenderMessageBubble(
        message: message.message,
        createdAt: message.createdAt,
        delivered: message.delivered,
        seen: message.seen,
        onReply: () => _replyToMessage(message),
        onDelete: () => _deleteMessage(message.id),
        onEdit: () {},
      );
    }

    return ReceiverMessageBubble(
      message: message.message,
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
        ),
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
            _buildBottomSection(),
          ],
        ),
      ),
    );
  }
}