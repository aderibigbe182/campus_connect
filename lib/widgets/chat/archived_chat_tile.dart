import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'chat_tile.dart';

class ArchivedChatTile extends StatelessWidget {
  final String name;
  final String lastMessage;
  final String time;

  final String? avatarUrl;

  final bool isOnline;

  final bool isVerified;

  final int unreadCount;

  final VoidCallback? onTap;

  final VoidCallback? onLongPress;

  const ArchivedChatTile({
    super.key,
    required this.name,
    required this.lastMessage,
    required this.time,
    this.avatarUrl,
    this.isOnline = false,
    this.isVerified = false,
    this.unreadCount = 0,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return ChatTile(
      name: name,
      lastMessage: lastMessage,
      time: time,
      avatarUrl: avatarUrl,
      isOnline: isOnline,
      isVerified: isVerified,
      unreadCount: unreadCount,
      onTap: onTap,
      onLongPress: onLongPress,

      trailing: const Icon(
        Icons.archive_outlined,
        color: AppColors.textSecondary,
      ),
    );
  }
}