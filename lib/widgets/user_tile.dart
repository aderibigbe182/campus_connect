import 'package:flutter/material.dart';

class UserTile extends StatelessWidget {

  final String uid;
  final String name;
  final String username;
  final String image;
  final bool online;

  const UserTile({

    super.key,

    required this.uid,
    required this.name,
    required this.username,
    required this.image,
    required this.online,
  });

  @override
  Widget build(BuildContext context) {

    return ListTile(

      leading: Stack(

        children: [

          CircleAvatar(

            radius: 26,

            backgroundImage:
                image.isNotEmpty
                    ? NetworkImage(image)
                    : null,

            child: image.isEmpty
                ? const Icon(Icons.person)
                : null,
          ),

          Positioned(

            bottom: 0,
            right: 0,

            child: Container(

              width: 14,
              height: 14,

              decoration: BoxDecoration(

                color: online
                    ? Colors.green
                    : Colors.grey,

                shape: BoxShape.circle,

                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      ),

      title: Text(name),

      subtitle: Text("@$username"),

      onTap: () {

        // OPEN CHAT
      },
    );
  }
}