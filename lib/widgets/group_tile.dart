import 'package:flutter/material.dart';

class GroupTile extends StatelessWidget {

  final String name;
  final String message;
  final String time;

  const GroupTile({

    super.key,

    required this.name,
    required this.message,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {

    return ListTile(

      leading: CircleAvatar(

        radius: 26,

        backgroundColor:
            Colors.blue.shade100,

        child: const Icon(
          Icons.groups,
          color: Colors.blue,
        ),
      ),

      title: Text(

        name,

        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),

      subtitle: Text(message),

      trailing: Text(
        time,
        style: const TextStyle(
          color: Colors.grey,
        ),
      ),

      onTap: () {

        Navigator.pushNamed(
          context,
          '/group-chat',
        );
      },
    );
  }
}