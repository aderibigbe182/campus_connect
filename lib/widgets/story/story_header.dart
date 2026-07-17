import 'package:flutter/material.dart';

import '/widgets/story/story_avatar.dart';

class StoryHeader extends StatelessWidget {
  final String? imageUrl;
  final String fullName;
  final String timeAgo;
  final bool isOnline;
  final VoidCallback? onClose;

  const StoryHeader({
    super.key,
    this.imageUrl,
    required this.fullName,
    required this.timeAgo,
    this.isOnline = false,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        child: Row(
          children: [

            StoryAvatar(
              imageUrl: imageUrl,
              fullName: fullName,
              hasUnseenStory: false,
              isOnline: isOnline,
              radius: 22,
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  Text(
                    fullName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    timeAgo,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            IconButton(
              onPressed: onClose,
              icon: const Icon(
                Icons.close,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}