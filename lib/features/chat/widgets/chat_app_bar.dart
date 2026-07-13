import 'package:flutter/material.dart';

class ChatAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const ChatAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      automaticallyImplyLeading: false,
      titleSpacing: 20,
      title: const Text(
        "Chats",
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.qr_code_scanner_rounded),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.camera_alt_outlined),
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: "archive",
              child: Text("Archived Chats"),
            ),
            PopupMenuItem(
              value: "requests",
              child: Text("Message Requests"),
            ),
            PopupMenuItem(
              value: "settings",
              child: Text("Chat Settings"),
            ),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
