import 'package:flutter/material.dart';

import 'online_indicator.dart';

class ChatTile
    extends StatelessWidget {

  final String username;
  final String lastMessage;
  final bool isOnline;
  final VoidCallback onTap;

  const ChatTile({

    super.key,

    required this.username,

    required this.lastMessage,

    required this.isOnline,

    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    return ListTile(

      onTap: onTap,

      leading: Stack(

        children: [

          const CircleAvatar(
            radius: 24,
            child: Icon(Icons.person),
          ),

          Positioned(

            bottom: 0,
            right: 0,

            child: OnlineIndicator(
              isOnline: isOnline,
            ),
          ),
        ],
      ),

      title: Text(username),

      subtitle: Text(lastMessage),

      trailing: const Icon(
        Icons.chevron_right,
      ),
    );
  }
}