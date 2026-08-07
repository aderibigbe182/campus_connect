import 'package:flutter/material.dart';
import '../models/conversation_model.dart';


class ChatTile extends StatelessWidget {
  final ConversationModel chat;
  final VoidCallback onTap;

  const ChatTile({
    super.key,
    required this.chat,
    required this.onTap,
  });
  String _formatTime(DateTime dateTime) {
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');

  return "$hour:$minute";
}

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: chat.profilePicture != null
                    ? NetworkImage(chat.profilePicture!)
                    : null,
                  child: chat.profilePicture == null
                      ? Text(
                          chat.fullName.isNotEmpty
                            ? chat.fullName
                            : "?"
                        )
                      : null,
                ),
                if (chat.isOnline)
                  Positioned(
                    right: 2,
                    bottom: 2,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chat.fullName,
                    style: TextStyle(
                      fontWeight:
                          chat.unreadCount > 0
                              ? FontWeight.bold
                              : FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat.lastMessage ??
                          "No messages yet",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight:
                                chat.unreadCount > 0
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                          )
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          Column(
  crossAxisAlignment: CrossAxisAlignment.end,
  children: [
    Text(
      chat.lastMessageTime == null
    ? ""
    : _formatTime(chat.lastMessageTime!),
      style: const TextStyle(
        fontSize: 11,
        color: Colors.grey,
      ),
    ),

    if (chat.relationshipStatus != "accepted")
  Container(
    margin: const EdgeInsets.only(top: 4),
    padding: const EdgeInsets.symmetric(
      horizontal: 8,
      vertical: 2,
    ),
    decoration: BoxDecoration(
      color: chat.relationshipStatus == "pending"
          ? Colors.orange
          : chat.relationshipStatus == "declined"
              ? Colors.red
              : Colors.grey,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      chat.relationshipStatus.toUpperCase(),
      style: const TextStyle(
        color: Colors.white,
        fontSize: 10,
      ),
    ),
  ),

    const SizedBox(height: 6),

    if (chat.unreadCount > 0)
      Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 7,
          vertical: 3,
        ),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          chat.unreadCount.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
  ],
)   
          ],
        ),
      ),
    );
  }
}