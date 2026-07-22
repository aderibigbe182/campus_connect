import 'package:flutter/material.dart';

import '../models/forward_chat_model.dart';

class ForwardMessageScreen extends StatelessWidget {
  final List<ForwardChatModel> chats;

  const ForwardMessageScreen({
    super.key,
    required this.chats,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Forward to"),
      ),
      body: ListView.builder(
        itemCount: chats.length,
        itemBuilder: (context, index) {
          final chat = chats[index];

          return ListTile(
            leading: CircleAvatar(
              backgroundImage:
                  chat.profilePicture != null
                      ? NetworkImage(chat.profilePicture!)
                      : null,
              child: chat.profilePicture == null
                  ? Text(chat.name[0])
                  : null,
            ),
            title: Text(chat.name),
            onTap: () {
              Navigator.pop(context, chat);
            },
          );
        },
      ),
    );
  }
}