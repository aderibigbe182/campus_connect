import 'package:flutter/material.dart';

class RequestTile extends StatelessWidget {

  final String sender;
  final String message;
  final VoidCallback onAccept;

  const RequestTile({
    super.key,
    required this.sender,
    required this.message,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {

    return Card(

      child: ListTile(

        title: Text(sender),

        subtitle: Text(message),

        trailing: ElevatedButton(
          onPressed: onAccept,
          child: const Text("Accept"),
        ),
      ),
    );
  }
}