import 'package:flutter/material.dart';

import '/widgets/story/story_caption.dart';
import '/widgets/story/story_header.dart';
import '/widgets/story/story_progress_bar.dart';

class StoryView extends StatelessWidget {
  final Widget media;

  final String? imageUrl;

  final String fullName;

  final String timeAgo;

  final String? caption;

  final bool isOnline;

  final int totalStories;

  final int currentStoryIndex;

  final double currentProgress;

  final VoidCallback? onClose;

  const StoryView({
    super.key,
    required this.media,
    this.imageUrl,
    required this.fullName,
    required this.timeAgo,
    this.caption,
    this.isOnline = false,
    required this.totalStories,
    required this.currentStoryIndex,
    required this.currentProgress,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [

            // Progress Bars
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 8,
              ),
              child: Row(
                children: List.generate(
                  totalStories,
                  (index) {
                    double progress;

                    if (index < currentStoryIndex) {
                      progress = 1;
                    } else if (index ==
                        currentStoryIndex) {
                      progress = currentProgress;
                    } else {
                      progress = 0;
                    }

                    return StoryProgressBar(
                      progress: progress,
                    );
                  },
                ),
              ),
            ),

            // Header
            StoryHeader(
              imageUrl: imageUrl,
              fullName: fullName,
              timeAgo: timeAgo,
              isOnline: isOnline,
              onClose: onClose,
            ),

            // Story Media
            Expanded(
              child: media,
            ),

            // Caption
            StoryCaption(
              caption: caption,
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}