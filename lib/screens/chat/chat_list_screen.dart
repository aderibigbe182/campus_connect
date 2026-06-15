import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../widgets/chat_tile.dart';

class ChatListScreen
    extends StatelessWidget {

  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Chats"),
      ),

      body:
          StreamBuilder<QuerySnapshot>(

        stream: FirebaseFirestore.instance
            .collection('chats')
            .snapshots(),

        builder: (context, snapshot) {

          if (!snapshot.hasData) {

            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          final chats =
              snapshot.data!.docs;

          if (chats.isEmpty) {

            return const Center(
              child: Text("No chats yet"),
            );
          }

          return ListView.builder(

            itemCount: chats.length,

            itemBuilder: (context, index) {

              final chat =
                  chats[index];

              return ChatTile(

                username:
                    "Student User",

                lastMessage:
                    chat['lastMessage'],

                isOnline: true,

                onTap: () {

                  Navigator.pushNamed(
                    context,
                    '/chat',
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}