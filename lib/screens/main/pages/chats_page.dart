import 'package:flutter/material.dart';

class ChatsPage extends StatelessWidget {

  const ChatsPage({super.key});

  @override
  Widget build(BuildContext context) {

    return ListView(

      padding: const EdgeInsets.all(20),

      children: [

        const SizedBox(height: 80),

        Column(

          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [

            Icon(
              Icons.chat_bubble_outline,
              size: 90,
              color: Colors.blue.shade200,
            ),

            const SizedBox(height: 20),

            const Text(

              "Start chatting",

              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(

              "Search and add students to begin conversations.",

              textAlign: TextAlign.center,

              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }
}