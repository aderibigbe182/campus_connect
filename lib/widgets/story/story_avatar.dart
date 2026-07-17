import 'package:flutter/material.dart';

import '../avatar_widget.dart';

class StoryAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? fullName;
  final bool hasUnseenStory;
  final bool isOnline;
  final double radius;
  final VoidCallback? onTap;

  const StoryAvatar({
    super.key,
    this.imageUrl,
    this.fullName,
    this.hasUnseenStory = false,
    this.isOnline = false,
    this.radius = 30,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AvatarWidget(
      imageUrl: imageUrl,
      fullName: fullName,
      radius: radius,
      isOnline: isOnline,
      showStoryRing: hasUnseenStory,
      onTap: onTap,
    );
  }
}