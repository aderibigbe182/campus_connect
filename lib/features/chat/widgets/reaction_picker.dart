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
            return AnimatedScale(
              duration: const Duration(milliseconds: 120),
              scale: 1,
              child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => onSelected(emoji),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                ),
                child: TweenAnimationBuilder<double>(
                tween: Tween(
                  begin: 0.8,
                  end: 1,
                ),
                duration: const Duration(
                  milliseconds: 180,
                ),
                curve: Curves.elasticOut,
                builder: (
                  context,
                  scale,
                  child,
                ) {
                  return Transform.scale(
                    scale: scale,
                    child: child,
                  );
                },
                child: Text(
                  emoji,
                  style: const TextStyle(
                    fontSize: 30,
                  ),
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