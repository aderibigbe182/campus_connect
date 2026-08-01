import 'package:flutter/material.dart';

class RecentSearchTile extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const RecentSearchTile({
    super.key,
    required this.text,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        leading: const Icon(Icons.history),
        title: Text(text),
        trailing: IconButton(
          icon: const Icon(Icons.close),
          onPressed: onDelete,
        ),
        onTap: onTap,
      ),
    );
  }
}