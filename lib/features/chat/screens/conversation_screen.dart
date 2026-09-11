import 'package:flutter/material.dart';

import '../../../core/services/storage_service.dart';
import '../models/message_model.dart';
import '../services/chat_service.dart';

class ConversationScreen extends StatefulWidget {
  final int conversationId;
  final int recipientId;
  final String name;
  final String? profilePicture;

  const ConversationScreen({
    super.key,
    required this.conversationId,
    required this.recipientId,
    required this.name,
    this.profilePicture,
  });

  @override
  State<ConversationScreen> createState() =>
      _ConversationScreenState();
}

class _ConversationScreenState
    extends State<ConversationScreen> {
  final ChatService _chatService =
      ChatService.instance;

  final TextEditingController _controller =
      TextEditingController();

  final ScrollController _scrollController =
      ScrollController();

  List<MessageModel> _messages = [];

  int? _currentUserId;

  bool _loading = true;
  bool _sending = false;

  String? _error;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    _currentUserId =
        await StorageService.getUserId();

    await _loadMessages();
  }

  Future<void> _loadMessages() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final messages =
          await _chatService.getMessages(
        conversationId:
            widget.conversationId,
      );

      if (!mounted) return;

      setState(() {
        _messages = messages;
        _loading = false;
      });

      await _markUnreadMessagesAsRead();

      WidgetsBinding.instance
          .addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _markUnreadMessagesAsRead() async {
    if (_currentUserId == null) return;

    for (final message in _messages) {
      if (message.senderId != _currentUserId &&
          !message.isRead) {
        try {
          await _chatService.markRead(
            messageId: message.id,
          );
        } catch (_) {}
      }
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();

    if (text.isEmpty ||
        _sending ||
        _currentUserId == null) {
      return;
    }

    setState(() {
      _sending = true;
    });

    try {
      final message =
          await _chatService.sendMessage(
        receiverId: widget.recipientId,
        content: text,
      );

      if (!mounted) return;

      _controller.clear();

      setState(() {
        _messages.add(message);
        _sending = false;
      });

      WidgetsBinding.instance
          .addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _sending = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
    }
  }

  Future<void> _deleteForMe(
    MessageModel message,
  ) async {
    try {
      await _chatService.deleteForMe(
        messageId: message.id,
      );

      if (!mounted) return;

      setState(() {
        _messages.removeWhere(
          (item) => item.id == message.id,
        );
      });
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
  }

  Future<void> _deleteForEveryone(
    MessageModel message,
  ) async {
    try {
      await _chatService.deleteForEveryone(
        messageId: message.id,
      );

      await _loadMessages();
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
  }

  Future<void> _editMessage(
    MessageModel message,
  ) async {
    final controller =
        TextEditingController(
      text: message.content,
    );

    final newText = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit message'),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLines: 5,
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final value =
                    controller.text.trim();

                if (value.isNotEmpty) {
                  Navigator.pop(
                    context,
                    value,
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (newText == null ||
        newText.isEmpty ||
        newText == message.content) {
      return;
    }

    try {
      final updated =
          await _chatService.editMessage(
        messageId: message.id,
        content: newText,
      );

      if (!mounted) return;

      final index = _messages.indexWhere(
        (item) => item.id == message.id,
      );

      if (index != -1) {
        setState(() {
          _messages[index] = updated;
        });
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
  }

  void _showMessageActions(
    MessageModel message,
  ) {
    final isMine =
        message.senderId == _currentUserId;

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading:
                    const Icon(Icons.copy),
                title:
                    const Text('Copy'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              if (isMine)
                ListTile(
                  leading:
                      const Icon(Icons.edit),
                  title:
                      const Text('Edit'),
                  onTap: () {
                    Navigator.pop(context);
                    _editMessage(message);
                  },
                ),
              ListTile(
                leading:
                    const Icon(Icons.delete_outline),
                title:
                    const Text('Delete for me'),
                onTap: () {
                  Navigator.pop(context);
                  _deleteForMe(message);
                },
              ),
              if (isMine)
                ListTile(
                  leading:
                      const Icon(Icons.delete_forever),
                  title:
                      const Text('Delete for everyone'),
                  onTap: () {
                    Navigator.pop(context);
                    _deleteForEveryone(message);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) {
      return;
    }

    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration:
          const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  String _formatTime(DateTime time) {
    final local = time.toLocal();

    final hour = local.hour == 0
        ? 12
        : local.hour > 12
            ? local.hour - 12
            : local.hour;

    final minute =
        local.minute.toString().padLeft(2, '0');

    final period =
        local.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage:
                  widget.profilePicture != null &&
                          widget.profilePicture!
                              .isNotEmpty
                      ? NetworkImage(
                          widget.profilePicture!,
                        )
                      : null,
              child: widget.profilePicture ==
                          null ||
                      widget.profilePicture!.isEmpty
                  ? Text(
                      widget.name.isNotEmpty
                          ? widget.name[0]
                              .toUpperCase()
                          : '?',
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.name,
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _loadMessages,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildMessages(),
          ),
          _buildComposer(),
        ],
      ),
    );
  }

  Widget _buildMessages() {
    if (_loading && _messages.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null &&
        _messages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off,
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loadMessages,
                child:
                    const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_messages.isEmpty) {
      return const Center(
        child: Text(
          'Start the conversation',
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMessages,
      child: ListView.builder(
        controller: _scrollController,
        padding:
            const EdgeInsets.fromLTRB(
          12,
          16,
          12,
          16,
        ),
        itemCount: _messages.length,
        itemBuilder: (context, index) {
          final message =
              _messages[index];

          final isMine =
              message.senderId ==
                  _currentUserId;

          return _MessageBubble(
            message: message,
            isMine: isMine,
            time: _formatTime(
              message.createdAt,
            ),
            onLongPress: () =>
                _showMessageActions(
              message,
            ),
          );
        },
      ),
    );
  }

  Widget _buildComposer() {
    return SafeArea(
      top: false,
      child: Padding(
        padding:
            const EdgeInsets.fromLTRB(
          10,
          8,
          10,
          8,
        ),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.end,
          children: [
            IconButton(
              onPressed: () {},
              icon:
                  const Icon(Icons.attach_file),
            ),
            Expanded(
              child: TextField(
                controller: _controller,
                minLines: 1,
                maxLines: 5,
                textInputAction:
                    TextInputAction.newline,
                decoration:
                    InputDecoration(
                  hintText:
                      'Type a message...',
                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                      24,
                    ),
                  ),
                  contentPadding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 18,
                    vertical: 11,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            IconButton(
              onPressed: _sending
                  ? null
                  : _sendMessage,
              icon: _sending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(
                      Icons.send,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMine;
  final String time;
  final VoidCallback onLongPress;

  const _MessageBubble({
    required this.message,
    required this.isMine,
    required this.time,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final deleted =
        message.isDeleted ||
        message.deletedForEveryone;

    return Align(
      alignment: isMine
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: onLongPress,
        child: Container(
          constraints:
              BoxConstraints(
            maxWidth:
                MediaQuery.of(context)
                        .size
                        .width *
                    .78,
          ),
          margin:
              const EdgeInsets.only(
            bottom: 8,
          ),
          padding:
              const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 9,
          ),
          decoration:
              BoxDecoration(
            borderRadius:
                BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize:
                MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  deleted
                      ? 'This message was deleted'
                      : message.content,
                  style: TextStyle(
                    fontStyle: deleted
                        ? FontStyle.italic
                        : FontStyle.normal,
                  ),
                ),
              ),
              const SizedBox(width: 7),
              Text(
                time,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade600,
                ),
              ),
              if (isMine) ...[
                const SizedBox(width: 3),
                Icon(
                  message.isRead
                      ? Icons.done_all
                      : message.isDelivered
                          ? Icons.done_all
                          : Icons.done,
                  size: 15,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}