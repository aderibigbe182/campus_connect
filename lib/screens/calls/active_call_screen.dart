import 'package:flutter/material.dart';

class ActiveCallScreen extends StatelessWidget {

  final String userName;

  const ActiveCallScreen({
    super.key,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.black,

      body: SafeArea(

        child: Column(

          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [

            const CircleAvatar(
              radius: 50,
              child: Icon(
                Icons.person,
                size: 50,
              ),
            ),

            const SizedBox(height: 20),

            Text(

              userName,

              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
              ),
            ),

            const SizedBox(height: 10),

            const Text(

              "Calling...",

              style: TextStyle(
                color: Colors.white70,
              ),
            ),

            const SizedBox(height: 50),

            Row(

              mainAxisAlignment:
                  MainAxisAlignment.center,

              children: [

                CircleAvatar(

                  radius: 30,

                  backgroundColor:
                      Colors.red,

                  child: IconButton(

                    onPressed: () {

                      Navigator.pop(context);
                    },

                    icon: const Icon(
                      Icons.call_end,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}