import 'package:flutter/material.dart';

class StoryTile extends StatelessWidget {

  final String image;
  final String username;
  final VoidCallback onTap;

  const StoryTile({
    super.key,
    required this.image,
    required this.username,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    return GestureDetector(

      onTap: onTap,

      child: Column(

        children: [

          CircleAvatar(
            radius: 32,
            backgroundImage:
                NetworkImage(image),
          ),

          const SizedBox(height: 6),

          Text(username),
        ],
      ),
    );
  }
}