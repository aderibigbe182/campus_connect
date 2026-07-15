import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../common/avatar_widget.dart';

class StoryAvatar extends StatelessWidget {
  final String name;
  final String? imageUrl;

  final bool hasStory;
  final bool viewed;

  final double radius;

  final VoidCallback? onTap;

  const StoryAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.hasStory = false,
    this.viewed = false,
    this.radius = 32,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor;

    if (!hasStory) {
      borderColor = Colors.transparent;
    } else if (viewed) {
      borderColor = Colors.grey.shade400;
    } else {
      borderColor = AppColors.primary;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: borderColor,
            width: 3,
          ),
        ),
        child: AvatarWidget(
          imageUrl: imageUrl,
          name: name,
          radius: radius,
        ),
      ),
    );
  }
}