import 'package:flutter/material.dart';

class GroupChatScreen
    extends StatelessWidget {

  const GroupChatScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          "Group Chat",
        ),
      ),

      body: Column(

        children: [

          // MESSAGES
          const Expanded(

            child: Center(

              child: Text(
                "Group messages appear here",
              ),
            ),
          ),

          // MESSAGE INPUT
          Padding(

            padding:
                const EdgeInsets.all(10),

            child: Row(

              children: [

                Expanded(

                  child: TextField(

                    decoration:
                        InputDecoration(

                      hintText:
                          "Type message",

                      border:
                          OutlineInputBorder(

                        borderRadius:
                            BorderRadius
                                .circular(30),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                CircleAvatar(

                  backgroundColor:
                      Colors.blue,

                  child: IconButton(

                    onPressed: () {},

                    icon: const Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}