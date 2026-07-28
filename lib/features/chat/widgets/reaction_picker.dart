import 'package:flutter/material.dart';

class ReactionPicker extends StatelessWidget {
  final void Function(String emoji) onSelected;

  const ReactionPicker({
    super.key,
    required this.onSelected,
  });

  static const List<String> reactions = [
    "👍",
    "❤️",
    "😂",
    "😮",
    "😢",
    "🙏",
  ];

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 10,
      borderRadius: BorderRadius.circular(30),
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 8,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: reactions.map((emoji) {
            return InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => onSelected(emoji),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                ),
                child: Text(
                  emoji,
                  style: const TextStyle(
                    fontSize: 28,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}