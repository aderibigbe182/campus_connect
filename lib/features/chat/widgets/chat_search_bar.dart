import 'package:flutter/material.dart';

class ChatSearchBar extends StatelessWidget {
  final VoidCallback? onTap;

  const ChatSearchBar({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(
          16,
          12,
          16,
          12,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.search,
              color: Colors.grey.shade600,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "Search chats...",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 15,
                ),
              ),
            ),
            Icon(
              Icons.tune,
              color: Colors.grey.shade600,
            ),
          ],
        ),
      ),
    );
  }
}
