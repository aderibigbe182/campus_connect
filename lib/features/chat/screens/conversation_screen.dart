import 'package:flutter/material.dart';

import '../widgets/conversation_app_bar.dart';
import '../widgets/message_input_bar.dart';
import '../widgets/conversation_shimmer.dart';
import '/features/chat/services/conversation_service.dart';
import '/features/chat/models/message_model.dart';


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
    extends State<ConversationScreen> {
  final ScrollController _scrollController =
      ScrollController();

  bool _isLoading = true;
  List<MessageModel> messages = [];

 @override
void initState() {
  super.initState();
  loadMessages();
}
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
  } catch (e) {
    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });
  }
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
                  : ListView.builder(
                      controller:
                          _scrollController,
                      reverse: true,
                      padding:
                          const EdgeInsets.only(
                        top: 12,
                        bottom: 12,
                      ),
                      itemCount: messages.length,
                      itemBuilder:
                          (context, index) {
                        final message = messages[index];

return Padding(
  padding: const EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 4,
  ),
  child: Text(
    message.message,
  ),
);
                      },
                    ),
            ),

            const MessageInputBar(),
          ],
        ),
      ),
    );
  }
}
