import 'package:flutter/material.dart';

import '../models/reaction_summary.dart';

class MessageReactions extends StatelessWidget {
  final List<String> reactions;
  final void Function(String emoji)? onTap;

  const MessageReactions({
    super.key,
    required this.reactions,
    this.onTap,
  });

  List<ReactionSummary> _group() {
    final map = <String, int>{};

    for (final emoji in reactions) {
      map[emoji] = (map[emoji] ?? 0) + 1;
    }

    return map.entries
        .map(
          (e) => ReactionSummary(
            emoji: e.key,
            count: e.value,
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    if (reactions.isEmpty) {
      return const SizedBox.shrink();
    }

    final grouped = _group();

    return Wrap(
      spacing: 6,
      children: grouped.map((reaction) {
        return InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            onTap?.call(reaction.emoji);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest,
              borderRadius:
                  BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  reaction.emoji,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  reaction.count.toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}