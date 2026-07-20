import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../common/avatar_widget.dart';
import '../common/online_indicator.dart';
import '../common/unread_badge.dart';

class ChatTile extends StatelessWidget {
  final String name;
  final String lastMessage;
  final String time;

  final String? avatarUrl;

  final bool isOnline;

  final bool isVerified;

  final int unreadCount;

  final VoidCallback? onTap;

  final VoidCallback? onLongPress;

  final Widget? trailing;

  const ChatTile({
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
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Stack(
              children: [
                AvatarWidget(
                    imageUrl: avatarUrl,
                    initials: name,
                    radius: 28,
                    ),
                if (isOnline)
                  const Positioned(
                    right: 0,
                    bottom: 0,
                    child: OnlineIndicator(),
                  ),
              ],
            ),

            const SizedBox(width: AppSpacing.md),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.titleMedium,
                        ),
                      ),
                      if (isVerified)
                        const Padding(
                          padding: EdgeInsets.only(left: 4),
                          child: Icon(
                            Icons.verified,
                            color: AppColors.primary,
                            size: 18,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  Text(
                    lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: AppSpacing.md),

            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  time,
                  style: AppTextStyles.bodySmall,
                ),

                const SizedBox(height: 6),

                if (trailing != null)
                  trailing!
                else if (unreadCount > 0)
                  UnreadBadge(
                    count: unreadCount,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}