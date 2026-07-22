import 'package:flutter/material.dart';

class MessageActionSheet extends StatelessWidget {
  final VoidCallback onCopy;
  final VoidCallback onReply;
  final VoidCallback onForward;
  final VoidCallback? onEdit;
  final VoidCallback onDelete;

  const MessageActionSheet({
    super.key,
    required this.onCopy,
    required this.onReply,
    required this.onForward,
    this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.copy),
            title: const Text("Copy"),
            onTap: onCopy,
          ),

          ListTile(
            leading: const Icon(Icons.reply),
            title: const Text("Reply"),
            onTap: onReply,
          ),

          ListTile(
            leading: const Icon(Icons.forward),
            title: const Text("Forward"),
            onTap: onForward,
          ),

          if (onEdit != null)
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text("Edit"),
              onTap: onEdit,
            ),

          ListTile(
            leading: const Icon(
              Icons.delete,
              color: Colors.red,
            ),
            title: const Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
            onTap: onDelete,
          ),
        ],
      ),
    );
  }
}