import 'package:flutter/material.dart';

import '../widgets/conversation_app_bar.dart';
import '../widgets/message_input_bar.dart';
import '../widgets/conversation_shimmer.dart';
import '/features/chat/services/conversation_service.dart';
import '/features/chat/models/message_model.dart';
import '/features/chat/widgets/sender_message_bubble.dart';
import '../widgets/receiver_message_bubble.dart';
import '/features/chat/widgets/date_separator.dart';
import '/core/utils/chat_date_utils.dart';
import '/features/chat/widgets/typing_indicator.dart';
import '/features/chat/widgets/empty_conversation.dart';
import '../services/send_message_service.dart';

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
  final List<LocalImageMessage> imageMessages = [];
}

class _ConversationScreenState
    extends State<ConversationScreen> {
  final ScrollController _scrollController =
      ScrollController();

  bool _isLoading = true;
  bool _isTyping = false;
  List<MessageModel> messages = [];
  final int currentUserId = 1;

 @override
void initState() {
  super.initState();
  loadMessages();
}
void _scrollToBottom() {
  if (!_scrollController.hasClients) return;

  _scrollController.animateTo(
    0,
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeOut,
  );
}
void _addLocalMessage(String text) {
  final temp = MessageModel(
    id: -DateTime.now().millisecondsSinceEpoch,
    senderId: currentUserId,
    message: text,
    createdAt: DateTime.now(),
    delivered: false,
    seen: false,
    sending: true,
  );

  setState(() {
    messages.insert(0, temp);
  });

  _scrollToBottom();
}
Future.delayed(
  const Duration(seconds: 1),
  () {
    if (!mounted) return;

    setState(() {
      final msg = messages.first;

      messages[0] = msg.copyWith(
        sending: false,
        delivered: true,
      );
    });
  },
);
Future.delayed(
  const Duration(seconds: 3),
  () {
    if (!mounted) return;

    setState(() {
      final msg = messages.first;

      messages[0] = msg.copyWith(
        seen: true,
      );
    });
  },
);
Future<void> loadMessages() async {
  try {
    final result =
        await ConversationService.getMessages(
      widget.conversationId,
    );

    if (!mounted) return;

    setState(() {
      messages = result;
      _isLoading = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
  _scrollToBottom();
});
  } catch (e) {
    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });
  }
}
Future<void> sendMessage(String text) async {
  final success = await SendMessageService.sendMessage(
    conversationId: widget.conversationId,
    message: text,
  );

  if (!success) return;

  await loadMessages();
}
 @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context)
          .colorScheme
          .surface,

      appBar: PreferredSize(
        preferredSize:
            const Size.fromHeight(70),
        child: ConversationAppBar(
          recipientName: widget.recipientName,
          profilePicture: widget.profilePicture,
          isOnline: widget.isOnline,
          lastSeen: "Last seen recently",
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _isLoading
                  ? const ConversationShimmer()
                  : messages.isEmpty
                      ? const EmptyConversation()
                      : ListView.builder(
                          controller: _scrollController,
                          reverse: true,
                          padding: const EdgeInsets.only(
                            top: 12,
                            bottom: 12,
                          ),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message = messages[index];

                            final isMe =
                                message.senderId == currentUserId;

                            final bool showDateSeparator =
                                index == messages.length - 1 ||
                                ChatDateUtils.format(message.createdAt) !=
                                    ChatDateUtils.format(
                                      messages[index + 1].createdAt,
                                    );

                            return Column(
                              children: [
                                if (showDateSeparator)
                                  DateSeparator(
                                    label: ChatDateUtils.format(
                                      message.createdAt,
                                    ),
                                  ),

                                isMe
                                    ? SenderMessageBubble(
                                        message: message.message,
                                        createdAt: message.createdAt,
                                        delivered: message.delivered,
                                        seen: message.seen,
                                      )
                                    : ReceiverMessageBubble(
                                        message: message.message,
                                        createdAt: message.createdAt,
                                      ),
                              ],
                            );
                          },
                        ),
                      ),
            if (_isTyping)
            TypingIndicator(
            username: widget.recipientName,
                  ),
            MessageInputBar(
  onSend: (text) async {
    _addLocalMessage(text);

    // backend comes next
  },
)
                                ],
                              ),
                            ),
                          );
                        }
                      }
