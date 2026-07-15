import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'chat_tile.dart';

class ChatSelectionTile extends StatelessWidget {
  final String name;
  final String lastMessage;
  final String time;

  final String? avatarUrl;

  final bool selected;

  final bool isOnline;

  final bool isVerified;

  final int unreadCount;

  final VoidCallback? onTap;

  final VoidCallback? onLongPress;

  const ChatSelectionTile({
    super.key,
    required this.name,
    required this.lastMessage,
    required this.time,
    this.avatarUrl,
    this.selected = false,
    this.isOnline = false,
    this.isVerified = false,
    this.unreadCount = 0,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: selected
          ? AppColors.primary.withOpacity(0.08)
          : Colors.transparent,

      child: ChatTile(
        name: name,
        lastMessage: lastMessage,
        time: time,
        avatarUrl: avatarUrl,
        isOnline: isOnline,
        isVerified: isVerified,
        unreadCount: unreadCount,
        onTap: onTap,
        onLongPress: onLongPress,

        trailing: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),

          child: selected
              ? const Icon(
                  Icons.check_circle,
                  key: ValueKey("selected"),
                  color: AppColors.primary,
                )
              : const Icon(
                  Icons.radio_button_unchecked,
                  key: ValueKey("unselected"),
                  color: AppColors.textSecondary,
                ),
        ),
      ),
    );
  }
}