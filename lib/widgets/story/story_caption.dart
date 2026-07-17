import 'package:flutter/material.dart';

class StoryCaption extends StatelessWidget {
  final String? caption;

  const StoryCaption({
    super.key,
    this.caption,
  });

  @override
  Widget build(BuildContext context) {
    // Hide the widget if there is no caption.
    if (caption == null || caption!.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        caption!,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          height: 1.4,
        ),
      ),
    );
  }
}