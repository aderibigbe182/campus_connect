import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'chat_tile.dart';

class PinnedChatTile extends StatelessWidget {
  final String name;
  final String lastMessage;
  final String time;

  final String? avatarUrl;

  final bool isOnline;

  final bool isVerified;

  final int unreadCount;

  final VoidCallback? onTap;

  final VoidCallback? onLongPress;

  const PinnedChatTile({
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
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (unreadCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          const Icon(
            Icons.push_pin,
            size: 18,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}
