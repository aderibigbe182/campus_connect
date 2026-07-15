import 'package:flutter/material.dart';

import '../widgets/conversation_app_bar.dart';
import '../widgets/message_input_bar.dart';
import '../widgets/conversation_shimmer.dart';

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

  @override
  void initState() {
    super.initState();

    Future.delayed(
      const Duration(milliseconds: 800),
      () {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      },
    );
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
                      itemCount: 0,
                      itemBuilder:
                          (context, index) {
                        return const SizedBox();
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
