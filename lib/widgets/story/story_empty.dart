import 'package:flutter/material.dart';

class StoryEmpty extends StatelessWidget {
  final String message;
  final VoidCallback? onAddStory;

  const StoryEmpty({
    super.key,
    this.message = "No stories available",
    this.onAddStory,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            const Icon(
              Icons.auto_stories_outlined,
              size: 60,
              color: Colors.grey,
            ),

            const SizedBox(height: 12),

            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            if (onAddStory != null)
              ElevatedButton.icon(
                onPressed: onAddStory,
                icon: const Icon(Icons.add),
                label: const Text("Add Story"),
              ),
          ],
        ),
      ),
    );
  }
}