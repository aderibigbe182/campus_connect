import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/chat_provider.dart';
import '../../widgets/chat/chat_app_bar.dart';
import '../../widgets/chat/message_bubble.dart';
import '../../widgets/chat/message_input.dart';
import '../../core/services/socket_service.dart';

class ConversationScreen extends StatefulWidget {

  final int conversationId;

  const ConversationScreen({

    super.key,

    required this.conversationId,

  });

  @override
  State<ConversationScreen> createState() =>
      _ConversationScreenState();

}

class _ConversationScreenState
    extends State<ConversationScreen> {

  @override
  void initState() {

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {

      final provider = context.read<ChatProvider>();

      provider.loadMessages(

        widget.conversationId,

      );
      for (final message in provider.messages) {

  SocketService.instance.messageSeen(

    conversationId: widget.conversationId,

    messageId: message.id,

  );

}

      provider.listenForMessages();
      provider.listenForDeliveredMessages();
      provider.listenForSeenMessages();

      SocketService.instance.joinConversation(

        widget.conversationId,

      );

    });

  }

  @override
  void dispose() {

    context.read<ChatProvider>().stopListening();

    SocketService.instance.leaveConversation(

      widget.conversationId,

    );

    super.dispose();

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: const PreferredSize(

        preferredSize: Size.fromHeight(60),

        child: ChatAppBar(),

      ),

      body: Consumer<ChatProvider>(

        builder: (

          context,

          provider,

          child,

        ) {

          if (provider.loading) {

            return const Center(

              child: CircularProgressIndicator(),

            );

          }

          return Column(

            children: [

              Expanded(

                child: ListView.builder(

                  reverse: true,

                  itemCount: provider.messages.length,

                  itemBuilder: (

                    context,

                    index,

                  ) {

                    final message = provider.messages[

                        provider.messages.length -

                            index -

                            1];

                    return MessageBubble(

                      message: message,

                    );

                  },

                ),

              ),

              MessageInput(

                conversationId:

                    widget.conversationId,

              ),

            ],

          );

        },

      ),

    );

  }

}