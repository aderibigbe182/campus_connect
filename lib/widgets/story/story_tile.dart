import 'package:flutter/material.dart';

import '/widgets/story/story_avatar.dart';

class StoryTile extends StatelessWidget {
  final String? imageUrl;
  final String fullName;
  final bool hasUnseenStory;
  final bool isOnline;
  final VoidCallback? onTap;

  const StoryTile({
    super.key,
    this.imageUrl,
    required this.fullName,
    this.hasUnseenStory = false,
    this.isOnline = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 82,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            StoryAvatar(
              imageUrl: imageUrl,
              fullName: fullName,
              hasUnseenStory: hasUnseenStory,
              isOnline: isOnline,
              radius: 30,
            ),

            const SizedBox(height: 8),

            Text(
              fullName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}